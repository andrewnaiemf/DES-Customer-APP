import 'dart:typed_data';

import 'package:app/data/constants/account_agreement.dart';
import 'package:app/data/constants/assets.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AccountAgreementPdf {
  static const PdfColor _purple = PdfColor.fromInt(0xFF6842E2);
  static const PdfColor _ink = PdfColor.fromInt(0xFF1B1F2A);
  static const PdfColor _muted = PdfColor.fromInt(0xFF4A4F5C);
  static const PdfColor _band = PdfColor.fromInt(0xFFF4F1FF);

  static Future<Uint8List> build({
    required AccountAgreementData data,
    required List<int> signatureBytes,
    required List<int> stampBytes,
  }) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/GraphikArabic-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/GraphikArabic-Bold.ttf'),
    );
    pw.Font medium = regular;
    try {
      medium = pw.Font.ttf(
        await rootBundle.load('assets/fonts/GraphikArabic-Medium.ttf'),
      );
    } catch (_) {}

    pw.ImageProvider? logo;
    for (final path in [Assets.logo, Assets.newLogo]) {
      try {
        final bytes = (await rootBundle.load(path)).buffer.asUint8List();
        if (bytes.isNotEmpty) {
          logo = pw.MemoryImage(bytes);
          break;
        }
      } catch (_) {}
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(34, 26, 34, 34),
          theme: pw.ThemeData.withFont(
            base: regular,
            bold: bold,
            italic: medium,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
        header: (_) => pw.Directionality(
          textDirection: pw.TextDirection.ltr,
          child: pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: logo == null
                ? pw.SizedBox(height: 28)
                : pw.Image(logo, width: 96, height: 38, fit: pw.BoxFit.contain),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(
              data.title,
              style: pw.TextStyle(
                font: bold,
                fontSize: 18,
                color: _ink,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Container(
              width: 68,
              height: 2.4,
              color: _purple,
            ),
          ),
          pw.SizedBox(height: 14),
          _p(data.intro, font: medium),
          pw.SizedBox(height: 8),
          _partyBox(data.partyOne, font: regular),
          pw.SizedBox(height: 7),
          _partyBox(data.partyTwo, font: regular),
          pw.SizedBox(height: 8),
          _p(
            'وقد اتفق الطرفان، وهما بكامل أهليتهما الشرعية والنظامية، على ما يلي:',
            font: medium,
          ),
          for (final clause in data.clauses) ...[
            pw.SizedBox(height: 11),
            pw.Text(
              clause['title']!,
              style: pw.TextStyle(
                font: bold,
                fontSize: 11.6,
                color: _purple,
              ),
            ),
            pw.SizedBox(height: 4),
            _p(clause['body']!, font: regular),
          ],
          pw.SizedBox(height: 22),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _signBlock(
                  title: 'الطرف الأول',
                  lines: const [
                    'شركة دروع المحرك الماسية للتجارة',
                    'الاسم: أحمد محمد الغول',
                    'الصفة: المدير',
                    'التوقيع:',
                    'الختم:',
                  ],
                  font: regular,
                  boldFont: bold,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _signBlock(
                  title: 'الطرف الثاني',
                  lines: [
                    'الشركة/المؤسسة: ${data.companyName}',
                    'الاسم: ${data.signerName}',
                    'الصفة: ${data.signerTitle}',
                    'التوقيع:',
                  ],
                  font: regular,
                  boldFont: bold,
                  signature: pw.MemoryImage(Uint8List.fromList(signatureBytes)),
                  stamp: pw.MemoryImage(Uint8List.fromList(stampBytes)),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'تاريخ الاعتماد الإلكتروني: ${data.dateY}/${data.dateM}/${data.dateD}',
            style: pw.TextStyle(font: regular, fontSize: 9, color: _muted),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _p(String text, {required pw.Font font}) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        font: font,
        fontSize: 10.4,
        lineSpacing: 2.6,
        color: _ink,
      ),
      textAlign: pw.TextAlign.justify,
    );
  }

  static pw.Widget _partyBox(String text, {required pw.Font font}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _band,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: _p(text, font: font),
    );
  }

  static pw.Widget _signBlock({
    required String title,
    required List<String> lines,
    required pw.Font font,
    required pw.Font boldFont,
    pw.ImageProvider? signature,
    pw.ImageProvider? stamp,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(font: boldFont, fontSize: 11.5, color: _purple),
        ),
        pw.SizedBox(height: 4),
        for (final line in lines) _p(line, font: font),
        if (signature != null) ...[
          pw.SizedBox(height: 4),
          pw.Image(signature, width: 140, height: 52, fit: pw.BoxFit.contain),
        ],
        if (stamp != null) ...[
          pw.SizedBox(height: 8),
          _p('الختم:', font: font),
          pw.SizedBox(height: 4),
          pw.Image(stamp, width: 90, height: 90, fit: pw.BoxFit.contain),
        ],
      ],
    );
  }
}
