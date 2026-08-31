import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<String?> pickPdfOrImageDocument() async {
  final completer = Completer<String?>();
  final uploadInput = html.FileUploadInputElement()
    ..accept = '.pdf,.png,.jpg,.jpeg,application/pdf';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      completer.complete(files[0].name);
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
