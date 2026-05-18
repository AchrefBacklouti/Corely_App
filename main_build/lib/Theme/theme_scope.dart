import 'package:flutter/widgets.dart';
import 'package:main_build/Theme/theme_provider.dart';

class ThemeScope extends InheritedNotifier<ThemeProvider> {
  final ThemeProvider controller;

  const ThemeScope({super.key, required this.controller, required super.child})
    : super(notifier: controller);

  static ThemeProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope not found in context');
    return scope!.controller;
  }
}
