// import 'dart:developer';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
//
// Future<File?> selectImage() async {
//   try {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowedExtensions: ['jpg', 'png'],
//       type: FileType.custom,
//     );
//
//     if (result != null) {
//       return File(result.files.single.path!);
//     } else {
//       log('File Not Selected');
//       return null;
//     }
//   } catch (e) {
//     log('$e');
//     return null;
//   }
// }
//
// Future<File?> selectPDF() async {
//   try {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowedExtensions: ['pdf'],
//       type: FileType.custom,
//       allowMultiple: false,
//     );
//
//     if (result != null) {
//       return File(result.files.single.path!);
//     } else {
//       log('File Not Selected');
//       return null;
//     }
//   } catch (e) {
//     log('$e');
//     return null;
//   }
// }
