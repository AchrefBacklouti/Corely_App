from __future__ import annotations

import argparse
import json
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

API_BASE = "https://oss.exercisedb.dev/api/v1/exercises"
DEFAULT_OUTPUT = Path("exercisedb_snapshot.json")
DEFAULT_CHECKPOINT = Path("exercisedb_checkpoint.json")


@dataclass
class FetchResult:
    data: list[dict[str, Any]]
    next_cursor: str | None
    has_next_page: bool
    total: int | None


def build_url(cursor: str | None, limit: int) -> str:
    params: dict[str, Any] = {"limit": limit}
    if cursor:
        params["cursor"] = cursor
    return f"{API_BASE}?{urlencode(params)}"


def fetch_page(cursor: str | None, limit: int, timeout: float) -> FetchResult:
    url = build_url(cursor, limit)
    request = Request(url, headers={"Accept": "application/json"})

    with urlopen(request, timeout=timeout) as response:
        payload = json.loads(response.read().decode("utf-8"))

    meta = payload.get("meta") or {}
    data = payload.get("data") or []

    return FetchResult(
        data=data if isinstance(data, list) else [],
        next_cursor=meta.get("nextCursor"),
        has_next_page=bool(meta.get("hasNextPage")),
        total=meta.get("total"),
    )


def load_json_file(path: Path, fallback: Any) -> Any:
    if not path.exists():
        return fallback
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return fallback


def save_json_file(path: Path, payload: Any) -> None:
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")


def load_checkpoint(path: Path) -> dict[str, Any]:
    checkpoint = load_json_file(path, {})
    if not isinstance(checkpoint, dict):
        return {}
    return checkpoint


def normalize_snapshot(snapshot: Any) -> dict[str, Any]:
    if not isinstance(snapshot, dict):
        return {"source": API_BASE, "savedAt": None, "meta": {}, "data": []}
    snapshot.setdefault("source", API_BASE)
    snapshot.setdefault("meta", {})
    snapshot.setdefault("data", [])
    snapshot.setdefault("savedAt", None)
    return snapshot


def merge_unique(existing: list[dict[str, Any]], new_items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    seen_ids: set[str] = set()
    merged: list[dict[str, Any]] = []

    for item in existing + new_items:
      exercise_id = str(item.get("exerciseId", ""))
      if not exercise_id or exercise_id in seen_ids:
          continue
      seen_ids.add(exercise_id)
      merged.append(item)

    merged.sort(key=lambda item: str(item.get("name", "")).lower())
    return merged


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Fetch ExerciseDB v1 data one page at a time and save after each step."
    )
    parser.add_argument("--limit", type=int, default=25, help="Page size to request from the API.")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT, help="Path to the JSON snapshot file.")
    parser.add_argument(
        "--checkpoint",
        type=Path,
        default=DEFAULT_CHECKPOINT,
        help="Path to the checkpoint file used to resume later.",
    )
    parser.add_argument("--timeout", type=float, default=30.0, help="HTTP timeout in seconds.")
    parser.add_argument("--sleep", type=float, default=0.0, help="Optional delay between page requests.")
    parser.add_argument("--max-pages", type=int, default=0, help="Optional safety stop after N pages; 0 means no limit.")
    parser.add_argument("--reset", action="store_true", help="Ignore existing output and checkpoint files.")
    args = parser.parse_args()

    output_path: Path = args.output
    checkpoint_path: Path = args.checkpoint

    if args.reset:
        if output_path.exists():
            output_path.unlink()
        if checkpoint_path.exists():
            checkpoint_path.unlink()

    snapshot = normalize_snapshot(load_json_file(output_path, {}))
    checkpoint = load_checkpoint(checkpoint_path)

    existing_data = snapshot.get("data", [])
    if not isinstance(existing_data, list):
        existing_data = []

    cursor = checkpoint.get("nextCursor") if isinstance(checkpoint.get("nextCursor"), str) else None
    page_count = int(checkpoint.get("pageCount", 0) or 0)
    if not cursor and checkpoint.get("hasNextPage") is False:
        print("No more pages to fetch. The checkpoint already says the dataset is complete.")
        return 0

    if not cursor and output_path.exists() and existing_data:
        print(f"Resuming from existing snapshot with {len(existing_data)} items.")
    else:
        print("Starting a new fetch session.")

    while True:
        if args.max_pages and page_count >= args.max_pages:
            print(f"Stopped after reaching --max-pages={args.max_pages}.")
            break

        try:
            result = fetch_page(cursor, args.limit, args.timeout)
        except HTTPError as exc:
            print(f"HTTP error while fetching cursor={cursor!r}: {exc.code} {exc.reason}", file=sys.stderr)
            return 1
        except URLError as exc:
            print(f"Network error while fetching cursor={cursor!r}: {exc.reason}", file=sys.stderr)
            return 1
        except TimeoutError:
            print(f"Request timed out while fetching cursor={cursor!r}", file=sys.stderr)
            return 1
        except json.JSONDecodeError as exc:
            print(f"Invalid JSON received from API: {exc}", file=sys.stderr)
            return 1

        page_count += 1

        normalized_page: list[dict[str, Any]] = []
        for item in result.data:
            if not isinstance(item, dict):
                continue
            normalized_page.append(item)

        existing_data = merge_unique(existing_data, normalized_page)

        snapshot = {
            "source": API_BASE,
            "savedAt": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
            "meta": {
                "total": result.total if result.total is not None else len(existing_data),
                "hasNextPage": result.has_next_page,
                "nextCursor": result.next_cursor,
                "pageCount": page_count,
                "pageSize": args.limit,
            },
            "data": existing_data,
        }

        save_json_file(output_path, snapshot)
        save_json_file(
            checkpoint_path,
            {
                "nextCursor": result.next_cursor,
                "hasNextPage": result.has_next_page,
                "pageCount": page_count,
                "itemsSaved": len(existing_data),
                "lastSaved": snapshot["savedAt"],
            },
        )

        print(
            f"Saved page {page_count}: {len(normalized_page)} new items, total saved {len(existing_data)}."
        )

        if not result.has_next_page or not result.next_cursor:
            print("Done. No more pages left.")
            break

        cursor = result.next_cursor
        if args.sleep > 0:
            time.sleep(args.sleep)

    print(f"Snapshot written to: {output_path.resolve()}")
    print(f"Checkpoint written to: {checkpoint_path.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
