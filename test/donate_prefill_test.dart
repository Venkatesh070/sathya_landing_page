import 'package:flutter_test/flutter_test.dart';

/// Mirrors DonatePage fragment/query parsing for mobile deep links.
Map<String, String> parseDonatePrefillParams({
  required String fragment,
  Map<String, String> queryParameters = const {},
  Map<String, String> getParameters = const {},
}) {
  final params = <String, String>{};

  void addAll(Map<String, String> source) {
    source.forEach((key, value) {
      final k = key.trim();
      final v = value.trim();
      if (k.isEmpty || v.isEmpty) return;
      params[k] = v;
    });
  }

  addAll(getParameters);
  addAll(queryParameters);
  final qIndex = fragment.indexOf('?');
  if (qIndex >= 0 && qIndex < fragment.length - 1) {
    addAll(Uri.splitQueryString(fragment.substring(qIndex + 1)));
  }
  return params;
}

void main() {
  test('parses email and name from hash fragment query', () {
    final params = parseDonatePrefillParams(
      fragment: '/donate?email=ada%40example.com&nameFirst=Ada&nameLast=Lovelace',
    );
    expect(params['email'], 'ada@example.com');
    expect(params['nameFirst'], 'Ada');
    expect(params['nameLast'], 'Lovelace');
  });

  test('ignores empty values', () {
    final params = parseDonatePrefillParams(
      fragment: '/donate?email=&nameFirst=Ada',
    );
    expect(params.containsKey('email'), isFalse);
    expect(params['nameFirst'], 'Ada');
  });
}
