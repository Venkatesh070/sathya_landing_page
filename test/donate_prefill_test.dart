import 'package:flutter_test/flutter_test.dart';
import 'package:sathya_landing/features/donate/data/donate_from_app.dart';

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
  test('parses email and name from path query parameters', () {
    final params = parseDonatePrefillParams(
      fragment: '',
      queryParameters: {
        'email': 'ada@example.com',
        'nameFirst': 'Ada',
        'nameLast': 'Lovelace',
      },
    );
    expect(params['email'], 'ada@example.com');
    expect(params['nameFirst'], 'Ada');
    expect(params['nameLast'], 'Lovelace');
  });

  test('parses email and name from legacy hash fragment query', () {
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

  test('detects from=app on path and legacy hash URLs', () {
    expect(
      urlIndicatesDonateFromMobileApp(
        queryParameters: {'from': 'app'},
      ),
      isTrue,
    );
    expect(
      urlIndicatesDonateFromMobileApp(
        fragment: '/donate/success?from=app',
      ),
      isTrue,
    );
    expect(
      urlIndicatesDonateFromMobileApp(
        queryParameters: {'email': 'a@b.com'},
      ),
      isFalse,
    );
  });

  test('appendDonateFromAppQuery preserves existing params', () {
    final out = appendDonateFromAppQuery(
      'https://www.sathya.co.za/donate/success',
    );
    expect(out, 'https://www.sathya.co.za/donate/success?from=app');
  });
}
