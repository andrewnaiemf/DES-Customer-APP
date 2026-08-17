import 'dart:typed_data';

import 'download_bytes_stub.dart'
    if (dart.library.html) 'download_bytes_web.dart' as impl;

Future<void> downloadBytes(Uint8List bytes, String filename, String mime) {
  return impl.downloadBytes(bytes, filename, mime);
}
