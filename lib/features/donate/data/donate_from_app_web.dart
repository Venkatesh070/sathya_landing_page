import 'dart:html' as html;

const _storageKey = 'sathya_donate_from_app';

void markCameFromMobileApp() {
  html.window.localStorage[_storageKey] = '1';
}

bool peekCameFromMobileAppFlag() =>
    html.window.localStorage[_storageKey] == '1';

bool consumeCameFromMobileAppFlag() {
  final hit = peekCameFromMobileAppFlag();
  html.window.localStorage.remove(_storageKey);
  return hit;
}
