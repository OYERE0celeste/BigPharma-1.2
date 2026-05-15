// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

html.DivElement? _ariaAlertRegion;

void announceAriaAlert(String message) {
  final trimmedMessage = message.trim();
  if (trimmedMessage.isEmpty) {
    return;
  }

  final region = _ariaAlertRegion ??= _createAriaAlertRegion();
  region.text = '';

  scheduleMicrotask(() {
    region.text = trimmedMessage;
  });
}

html.DivElement _createAriaAlertRegion() {
  final region = html.DivElement()
    ..id = 'bigpharma-aria-alert-region'
    ..setAttribute('role', 'alert')
    ..setAttribute('aria-live', 'assertive')
    ..setAttribute('aria-atomic', 'true');

  final style = region.style;
  style.position = 'fixed';
  style.width = '1px';
  style.height = '1px';
  style.margin = '-1px';
  style.padding = '0';
  style.border = '0';
  style.overflow = 'hidden';
  style.clip = 'rect(0 0 0 0)';
  style.whiteSpace = 'nowrap';

  final host = html.document.body ?? html.document.documentElement;
  host?.append(region);

  return region;
}
