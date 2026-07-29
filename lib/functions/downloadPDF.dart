import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class DownloadPDFClass {
  static Future<String> downloadPDF(String name, String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Directory? directory;

        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        final filePath = '${directory!.path}/$name.pdf';
        final pdfFile = File(filePath);
        await pdfFile.writeAsBytes(response.bodyBytes);
        print('PDF downloaded to: $filePath');
        await OpenFile.open(pdfFile.path);

        return filePath;
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      return "";
    }
  }

  static Future<void> openPDF(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await OpenFile.open(filePath);
      } else {
        print('File does not exist: $filePath');
      }
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }
}