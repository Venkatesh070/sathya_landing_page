import 'dart:html' as html;

Future<void> redirectToPayFast({
  required String paymentUrl,
  required Map<String, String> formFields,
}) async {
  final form = html.FormElement()
    ..method = 'POST'
    ..action = paymentUrl
    ..style.display = 'none'
    ..target = '_self';

  formFields.forEach((key, value) {
    form.append(
      html.HiddenInputElement()
        ..name = key
        ..value = value,
    );
  });

  html.document.body?.append(form);
  form.submit();
}
