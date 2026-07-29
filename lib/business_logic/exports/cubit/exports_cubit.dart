import 'dart:io';
import 'dart:typed_data';

import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/functions/functions.dart';
import 'package:app/models/account_statement_model/AccountStatementModel/AccountStatementModel2.dart';
import 'package:app/models/invoice/invoice_model.dart';
import 'package:app/models/receipt/receipt_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

part 'exports_state.dart';

// ============================================================================
// 🎨 REFINED BRAND COLORS - Elegant Purple Theme
// ============================================================================
class PdfBrandColors {
  // ═══════════════════════════════════════════════════════════════════════
  // 💜 REFINED PURPLE PALETTE - Softer & More Elegant
  // ═══════════════════════════════════════════════════════════════════════
  static final PdfColor primary = PdfColor.fromInt(0xFF7C5CFC);          // Soft Purple
  static final PdfColor primaryLight = PdfColor.fromInt(0xFF9B85FC);     // Light Purple
  static final PdfColor primaryLighter = PdfColor.fromInt(0xFFBBA8FC);   // Lighter Purple
  static final PdfColor primaryPale = PdfColor.fromInt(0xFFEDE9FE);      // Very Light Purple
  static final PdfColor primaryMuted = PdfColor.fromInt(0xFF6B52D9);     // Muted Purple
  static final PdfColor primaryDeep = PdfColor.fromInt(0xFF5A3FBF);      // Deep Purple

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 ACCENT COLORS - Refined & Subtle
  // ═══════════════════════════════════════════════════════════════════════
  static final PdfColor accent = PdfColor.fromInt(0xFF5EEAD4);           // Soft Teal
  static final PdfColor accentMuted = PdfColor.fromInt(0xFF99F6E4);      // Muted Teal
  static final PdfColor gold = PdfColor.fromInt(0xFFFCD34D);             // Soft Gold
  static final PdfColor goldMuted = PdfColor.fromInt(0xFFFEF3C7);        // Light Gold
  static final PdfColor rose = PdfColor.fromInt(0xFFFDA4AF);             // Soft Rose
  static final PdfColor roseMuted = PdfColor.fromInt(0xFFFCE7F3);        // Light Rose

  // ═══════════════════════════════════════════════════════════════════════
  // ⚫ NEUTRAL COLORS - Refined Grays
  // ═══════════════════════════════════════════════════════════════════════
  static final PdfColor text = PdfColor.fromInt(0xFF1F2937);             // Dark Text
  static final PdfColor textSecondary = PdfColor.fromInt(0xFF4B5563);    // Secondary Text
  static final PdfColor textMuted = PdfColor.fromInt(0xFF9CA3AF);        // Muted Text
  static final PdfColor border = PdfColor.fromInt(0xFFE5E7EB);           // Subtle Border
  static final PdfColor borderLight = PdfColor.fromInt(0xFFF3F4F6);      // Light Border
  static final PdfColor background = PdfColor.fromInt(0xFFFAFAFB);       // Off-white
  static final PdfColor surface = PdfColors.white;                        // Pure White

  // ═══════════════════════════════════════════════════════════════════════
  // 🚦 STATUS COLORS - Soft & Elegant
  // ═══════════════════════════════════════════════════════════════════════
  static final PdfColor success = PdfColor.fromInt(0xFF34D399);          // Soft Green
  static final PdfColor successBg = PdfColor.fromInt(0xFFD1FAE5);        // Light Green Bg
  static final PdfColor warning = PdfColor.fromInt(0xFFFBBF24);          // Soft Amber
  static final PdfColor warningBg = PdfColor.fromInt(0xFFFEF3C7);        // Light Amber Bg
  static final PdfColor error = PdfColor.fromInt(0xFFF87171);            // Soft Red
  static final PdfColor errorBg = PdfColor.fromInt(0xFFFEE2E2);          // Light Red Bg
  static final PdfColor info = PdfColor.fromInt(0xFF60A5FA);             // Soft Blue
  static final PdfColor infoBg = PdfColor.fromInt(0xFFDBEAFE);           // Light Blue Bg
}

// ============================================================================
// 📄 EXPORTS CUBIT - REFINED VERSION
// ============================================================================
class ExportsCubit extends Cubit<ExportsState> {
  ExportsCubit() : super(ExportsInitial());

  static ExportsCubit get(BuildContext context) => BlocProvider.of(context);

  // ============================================================================
  // 📦 CACHED RESOURCES
  // ============================================================================
  pw.Font? _arFont;
  pw.Font? _enFont;
  pw.Font? _lightFont;
  Uint8List? _logoData;

  bool isExportingAccountStatement = false;
  bool isExportingPDF = false;

  // ============================================================================
  // 🔤 INITIALIZE FONTS
  // ============================================================================
  Future<void> _initializeFonts() async {
    _arFont ??= pw.Font.ttf(
      await rootBundle.load("assets/fonts/GraphikArabic-Bold.ttf"),
    );
    _enFont ??= pw.Font.ttf(
      await rootBundle.load("assets/fonts/LeagueSpartan-Medium.ttf"),
    );
  }

  Future<Uint8List> _loadLogo() async {
    _logoData ??= (await rootBundle.load(Assets.logo)).buffer.asUint8List();
    return _logoData!;
  }

  // ============================================================================
  // 🛠️ HELPER METHODS
  // ============================================================================
  bool _isEnglish(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);

  pw.Font _getFont(String text) => _isEnglish(text) ? _enFont! : _arFont!;

  pw.TextDirection _getTextDirection(BuildContext context) {
    return context.locale.languageCode == 'ar'
        ? pw.TextDirection.rtl
        : pw.TextDirection.ltr;
  }

  String _getCurrency(BuildContext context) => 'SAR';

  // ============================================================================
  // 🎨 ELEGANT STYLED PDF WIDGETS
  // ============================================================================

  /// 📌 Elegant Header - Clean & Minimal
  pw.Widget _buildElegantHeader({
    required Uint8List logoData,
    required String companyName,
    String? documentType,
    String? reference,
    String? date,
    required bool? isArabic,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: PdfBrandColors.surface,
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: PdfBrandColors.border, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfBrandColors.background,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Image(
                  pw.MemoryImage(logoData),
                  width: 140,
                  height: 32,
                ),
              ),

              // Document Info
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (documentType != null)
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfBrandColors.primaryPale,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        documentType,
                        style: pw.TextStyle(
                          font: _getFont(documentType),
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfBrandColors.primary,
                        ),
                      ),
                    ),
                  if (reference != null) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '#$reference',
                      style: pw.TextStyle(
                        font: isArabic==true ? _arFont : _enFont,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfBrandColors.text,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                  if (date != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      date,
                      style: pw.TextStyle(
                        font: isArabic==true ? _arFont : _enFont,
                        fontSize: 10,
                        color: PdfBrandColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // Company Info Bar
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [PdfBrandColors.primaryPale, PdfBrandColors.surface],
                begin: pw.Alignment.centerLeft,
                end: pw.Alignment.centerRight,
              ),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  companyName,
                  style: pw.TextStyle(
                    font: _arFont,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfBrandColors.primaryMuted,
                  ),
                ),
                pw.Row(
                  children: [
                    _buildInfoChip('Tax: 312696211500003'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Info Chip - Small Label
  pw.Widget _buildInfoChip(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfBrandColors.surface,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfBrandColors.border, width: 0.5),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: _enFont,
          fontSize: 8,
          color: PdfBrandColors.textMuted,
        ),
      ),
    );
  }

  /// 📌 Section Header - Minimal Style
  pw.Widget _buildSectionHeader(String title, {String? subtitle}) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 20, bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: PdfBrandColors.primary,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: _getFont(title),
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfBrandColors.text,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 4),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 16),
              child: pw.Text(
                subtitle,
                style: pw.TextStyle(
                  font: _getFont(subtitle),
                  fontSize: 9,
                  color: PdfBrandColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 📌 Elegant Card Container
  pw.Widget _buildElegantCard({
    required List<pw.Widget> children,
    String? title,
    PdfColor? accentColor,
    bool showAccent = true,
  }) {
    final accent = accentColor ?? PdfBrandColors.primary;

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfBrandColors.surface,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfBrandColors.border, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (title != null)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: pw.BoxDecoration(
                color: PdfBrandColors.background,
                borderRadius: const pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(11),
                  topRight: pw.Radius.circular(11),
                ),
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfBrandColors.border, width: 1),
                ),
              ),
              child: pw.Row(
                children: [
                  if (showAccent) ...[
                    pw.Container(
                      width: 3,
                      height: 14,
                      decoration: pw.BoxDecoration(
                        color: accent,
                        borderRadius: pw.BorderRadius.circular(2),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                  ],
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      font: _getFont(title),
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfBrandColors.text,
                    ),
                  ),
                ],
              ),
            ),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Key-Value Row - Clean Design
  pw.Widget _buildInfoRow(
      String label,
      String value, {
        bool isHighlight = false,
        PdfColor? valueColor,
      }) {
    final hasNumbers = RegExp(r'\d').hasMatch(value);

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfBrandColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: _getFont(label),
              fontSize: 10,
              color: PdfBrandColors.textMuted,
            ),
          ),
          pw.Container(
            padding: isHighlight
                ? const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                : null,
            decoration: isHighlight
                ? pw.BoxDecoration(
              color: PdfBrandColors.primaryPale,
              borderRadius: pw.BorderRadius.circular(6),
            )
                : null,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: hasNumbers ? _enFont : _getFont(value),
                fontSize: 10,
                fontWeight: isHighlight ? pw.FontWeight.bold : null,
                color: valueColor ?? (isHighlight ? PdfBrandColors.primary : PdfBrandColors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Elegant Table Header
  pw.TableRow _buildElegantTableHeader(List<String> headers) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: PdfBrandColors.background,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(10),
          topRight: pw.Radius.circular(10),
        ),
      ),
      children: headers.map((header) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: pw.Text(
            header,
            style: pw.TextStyle(
              font: _getFont(header),
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfBrandColors.textSecondary,
            ),
            textAlign: pw.TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  /// 📌 Elegant Table Row
  pw.TableRow _buildElegantTableRow(List<String> cells, {bool isAlternate = false}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isAlternate ? PdfBrandColors.background : PdfBrandColors.surface,
      ),
      children: cells.map((cell) {
        final hasNumbers = RegExp(r'\d').hasMatch(cell);
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: pw.Text(
            cell,
            style: pw.TextStyle(
              font: hasNumbers ? _enFont : _getFont(cell),
              fontSize: 9,
              color: PdfBrandColors.text,
            ),
            textAlign: pw.TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  /// 📌 Amount Display Card - Refined
  pw.Widget _buildAmountDisplay(
      String label,
      String amount, {
        bool isPrimary = false,
        bool isAccent = false,
        double width = 120,
      }) {
    PdfColor bgColor;
    PdfColor textColor;
    PdfColor labelColor;

    if (isPrimary) {
      bgColor = PdfBrandColors.primary;
      textColor = PdfBrandColors.surface;
      labelColor = PdfBrandColors.primaryLighter;
    } else if (isAccent) {
      bgColor = PdfBrandColors.goldMuted;
      textColor = PdfBrandColors.text;
      labelColor = PdfBrandColors.textSecondary;
    } else {
      bgColor = PdfBrandColors.background;
      textColor = PdfBrandColors.text;
      labelColor = PdfBrandColors.textMuted;
    }

    return pw.Container(
      width: width,
      padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(12),
        border: isPrimary ? null : pw.Border.all(color: PdfBrandColors.border, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: _getFont(label),
              fontSize: 8,
              color: labelColor,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            amount,
            style: pw.TextStyle(
              font: _enFont,
              fontSize: isPrimary ? 14 : 12,
              fontWeight: pw.FontWeight.bold,
              color: textColor,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📌 Status Badge - Refined
  pw.Widget _buildStatusChip(String status) {
    PdfColor bgColor;
    PdfColor textColor;

    switch (status.toLowerCase()) {
      case 'paid':
      case 'مدفوع':
      case 'approved':
        bgColor = PdfBrandColors.successBg;
        textColor = PdfBrandColors.success;
        break;
      case 'pending':
      case 'معلق':
        bgColor = PdfBrandColors.warningBg;
        textColor = PdfBrandColors.warning;
        break;
      case 'overdue':
      case 'متأخر':
      case 'cancelled':
        bgColor = PdfBrandColors.errorBg;
        textColor = PdfBrandColors.error;
        break;
      default:
        bgColor = PdfBrandColors.primaryPale;
        textColor = PdfBrandColors.primary;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Text(
        status,
        style: pw.TextStyle(
          font: _getFont(status),
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  /// 📌 Summary Box - Elegant
  pw.Widget _buildSummaryBox({
    required List<MapEntry<String, String>> items,
    required String totalLabel,
    required String totalValue,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfBrandColors.primary,
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Column(
        children: [
          ...items.map((item) => pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  item.key,
                  style: pw.TextStyle(
                    font: _getFont(item.key),
                    fontSize: 10,
                    color: PdfBrandColors.primaryLighter,
                  ),
                ),
                pw.Text(
                  item.value,
                  style: pw.TextStyle(
                    font: _enFont,
                    fontSize: 11,
                    color: PdfBrandColors.surface,
                  ),
                ),
              ],
            ),
          )),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfBrandColors.gold,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  totalLabel,
                  style: pw.TextStyle(
                    font: _getFont(totalLabel),
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfBrandColors.text,
                  ),
                ),
                pw.Text(
                  totalValue,
                  style: pw.TextStyle(
                    font: _enFont,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfBrandColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Elegant Footer
  pw.Widget _buildElegantFooter(String currentPage, String totalPages) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfBrandColors.border, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            DateTime.now().toString().substring(0, 10),
            style: pw.TextStyle(
              font: _enFont,
              fontSize: 8,
              color: PdfBrandColors.textMuted,
            ),
          ),
          pw.Text(
            'Diamond Engine Shields',
            style: pw.TextStyle(
              font: _enFont,
              fontSize: 8,
              color: PdfBrandColors.textMuted,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfBrandColors.primaryPale,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Text(
              '$currentPage / $totalPages',
              style: pw.TextStyle(
                font: _enFont,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfBrandColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Elegant Divider
  pw.Widget _buildDivider({double height = 1}) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 16),
      height: height,
      color: PdfBrandColors.border,
    );
  }

  /// 📌 Contact/Customer Card - Refined
  pw.Widget _buildContactCard({
    required String name,
    String? organization,
    String? phone,
    String? email,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfBrandColors.surface,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfBrandColors.border, width: 1),
      ),
      child: pw.Row(
        children: [
          // Avatar
          pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              color: PdfBrandColors.primaryPale,
              borderRadius: pw.BorderRadius.circular(24),
            ),
            child: pw.Center(
              child: pw.Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: pw.TextStyle(
                  font: _enFont,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfBrandColors.primary,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  name,
                  style: pw.TextStyle(
                    font: _getFont(name),
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfBrandColors.text,
                  ),
                ),
                if (organization != null && organization.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    organization,
                    style: pw.TextStyle(
                      font: _getFont(organization),
                      fontSize: 9,
                      color: PdfBrandColors.textMuted,
                    ),
                  ),
                ],
                if (phone != null && phone.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    phone,
                    style: pw.TextStyle(
                      font: _enFont,
                      fontSize: 9,
                      color: PdfBrandColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Product Item Card - Elegant Design
  pw.Widget _buildProductCard({
    required int index,
    required String name,
    required double quantity,
    required double unitPrice,
    required double discount,
    required double taxPercent,
    required String currency,
  }) {
    final totalBeforeTax = (unitPrice - discount) * quantity;
    final taxValue = totalBeforeTax * (taxPercent / 100);
    final total = totalBeforeTax + taxValue;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        color: PdfBrandColors.surface,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfBrandColors.border, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Product Header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: pw.BoxDecoration(
              color: PdfBrandColors.background,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(11),
                topRight: pw.Radius.circular(11),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 28,
                  height: 28,
                  decoration: pw.BoxDecoration(
                    color: PdfBrandColors.primaryPale,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '$index',
                      style: pw.TextStyle(
                        font: _enFont,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfBrandColors.primary,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Text(
                    name,
                    style: pw.TextStyle(
                      font: _getFont(name),
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfBrandColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Details Grid
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      _buildMiniInfoRow('Quantity'.tr(), '$quantity'),
                      pw.SizedBox(height: 8),
                      _buildMiniInfoRow('Discount'.tr(), '$discount $currency'),
                    ],
                  ),
                ),
                pw.Container(
                  width: 1,
                  height: 50,
                  color: PdfBrandColors.border,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 16),
                ),
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      _buildMiniInfoRow('Unit Price'.tr(), '$unitPrice $currency'),
                      pw.SizedBox(height: 8),
                      _buildMiniInfoRow('Tax ${taxPercent.toStringAsFixed(0)}%', '$taxValue $currency'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Total
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: pw.BoxDecoration(
              color: PdfBrandColors.primaryPale,
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(11),
                bottomRight: pw.Radius.circular(11),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Item Total'.tr(),
                  style: pw.TextStyle(
                    font: _getFont('Item Total'.tr()),
                    fontSize: 10,
                    color: PdfBrandColors.textSecondary,
                  ),
                ),
                pw.Text(
                  '${total.toStringAsFixed(2)} $currency',
                  style: pw.TextStyle(
                    font: _enFont,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfBrandColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Mini Info Row for Product Cards
  pw.Widget _buildMiniInfoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: _getFont(label),
            fontSize: 9,
            color: PdfBrandColors.textMuted,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: _enFont,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfBrandColors.text,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 📊 EXPORT ACCOUNT STATEMENT - REFINED
  // ============================================================================
  Future<void> exportAccountStatement(
      List<AccountStatementData> listAccountStatement,
      List<String> fromTo,
      BuildContext context,
      ) async {
    final isArabic = context.locale.languageCode == 'ar';

    if (isExportingAccountStatement) return;

    isExportingAccountStatement = true;
    emit(ExportLoading());

    try {
      await _initializeFonts();
      final logoData = await _loadLogo();
      final pdf = pw.Document();

      const int itemsPerPage = 20;
      final int totalPages = (listAccountStatement.length / itemsPerPage).ceil();

      for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        final startIndex = pageIndex * itemsPerPage;
        final endIndex = (startIndex + itemsPerPage).clamp(0, listAccountStatement.length);
        final pageData = listAccountStatement.sublist(startIndex, endIndex);

        pdf.addPage(
          pw.Page(
            textDirection: pw.TextDirection.rtl,
            theme: pw.ThemeData.withFont(base: _arFont),
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(24),
            build: (pdfContext) {
              return pw.Column(
                children: [
                  // Elegant Header
                  _buildElegantHeader(
                    logoData: logoData,
                    companyName: 'شركة دروع المحرك الماسية للتجارة',
                    documentType: 'Account Statement'.tr(),
                    date: '${"From".tr()} ${fromTo[0]} ${"To".tr()} ${fromTo[1]}',
                   isArabic:isArabic
                  ),

                  pw.SizedBox(height: 16),

                  // Customer Info
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfBrandColors.background,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: PdfBrandColors.border, width: 1),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Customer'.tr(),
                              style: pw.TextStyle(
                                font: _getFont('Customer'.tr()),
                                fontSize: 9,
                                color: PdfBrandColors.textMuted,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              ProfileCubit.get(context).userModel?.name ?? '',
                              style: pw.TextStyle(
                                font: _arFont,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfBrandColors.text,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 16),

                  // Data Table
                  pw.Expanded(
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(12),
                        border: pw.Border.all(color: PdfBrandColors.border, width: 1),
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 12,
                        verticalRadius: 12,
                        child: pw.Table(
                          border: pw.TableBorder(
                            horizontalInside: pw.BorderSide(
                              color: PdfBrandColors.border,
                              width: 0.5,
                            ),
                          ),
                          children: [
                            _buildElegantTableHeader([
                              'Creditor'.tr(),
                              'Debtor'.tr(),
                              'Ref'.tr(),
                              'Description Process'.tr(),
                              'Type'.tr(),
                              'Date'.tr(),
                            ]),
                            ...pageData.asMap().entries.map((entry) {
                              final e = entry.value;
                              return _buildElegantTableRow(
                                [
                                  e.credit.toString(),
                                  e.debit.toString(),
                                  e.reference ?? '',
                                  ProfileCubit.get(context).userModel?.name ?? '',
                                  e.type ?? '',
                                  e.date ?? '',
                                ],
                                isAlternate: entry.key.isOdd,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 12),
                  _buildElegantFooter('${pageIndex + 1}', '$totalPages'),

                  // Add outstanding amount and disclaimer on last page
                  if (pageIndex == totalPages - 1) ...[
                    pw.SizedBox(height: 20),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(18),
                      decoration: pw.BoxDecoration(
                        gradient: pw.LinearGradient(
                          colors: [
                            PdfBrandColors.primaryLight,
                            PdfColors.white,
                          ],
                        ),
                        borderRadius: pw.BorderRadius.circular(18),
                        border: pw.Border.all(
                          color: PdfBrandColors.primaryLight,
                          width: 1,
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          /// LEFT SIDE (ICON + TEXT)
                          pw.Row(
                            children: [
                              // pw.Container(
                              //   padding: const pw.EdgeInsets.all(10),
                              //   decoration: pw.BoxDecoration(
                              //     color: PdfBrandColors.primaryLight,
                              //     borderRadius: pw.BorderRadius.circular(12),
                              //   ),
                              //   child: pw.Icon(
                              //     pw.IconData(0xe227), // wallet icon (material)
                              //     color: PdfBrandColors.primary,
                              //     size: 22,
                              //   ),
                              // ),
                              // pw.SizedBox(width: 14),
                              pw.Text(
                                'Total Due'.tr(), // or .tr() if you handle translation before
                                style: pw.TextStyle(
                                  font: isArabic ? _arFont : _enFont,
                                  fontSize: 15,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          /// RIGHT SIDE (AMOUNT BADGE)
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: pw.BoxDecoration(
                              gradient: pw.LinearGradient(
                                colors: [
                                  PdfBrandColors.primary,
                                  PdfBrandColors.primaryLight,
                                ],
                              ),
                              borderRadius: pw.BorderRadius.circular(25),
                            ),
                            child: pw.Text(
                              '${ProfileCubit.get(context).userModel?.totalOutStanding ?? 0} ${"SAR".tr()}',
                              style: pw.TextStyle(
                                font: isArabic ? _arFont : _enFont,
                                fontSize: 15,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // pw.Container(
                    //   padding: const pw.EdgeInsets.symmetric(
                    //     horizontal: 18,
                    //     vertical: 10,
                    //   ),
                    //   decoration: pw.BoxDecoration(
                    //     gradient: pw.LinearGradient(
                    //       colors: [PdfBrandColors.primary, PdfBrandColors.primaryLight],
                    //     ),
                    //     borderRadius: pw.BorderRadius.circular(24),
                    //   ),
                    //   child: pw.Text(
                    //     '${ProfileCubit.get(context).userModel?.totalOutStanding ?? 0} ${'SAR'.tr()}',
                    //     style: pw.TextStyle(
                    //       font: isArabic ?_arFont:_enFont,
                    //       fontSize: 15,
                    //       fontWeight: pw.FontWeight.bold,
                    //       color: PdfColors.white,
                    //     ),
                    //     textAlign: pw.TextAlign.center,
                    //   ),
                    // ),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'This information is preliminary. For more details, please contact your account manager.'.tr(),
                      style: pw.TextStyle(
                        font: isArabic ? _arFont : _enFont,
                        fontSize: 10,
                        color: PdfBrandColors.textMuted,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ],
              );
            },
          ),
        );
      }

      await _saveFile(
        context: context,
        pdf: pdf,
        name: 'account_statement_${formatDate(context, DateTime.now())}',
      );

      isExportingAccountStatement = false;
      emit(ExportSuccess());
    } catch (e) {
      debugPrint('Export Error: $e');
      isExportingAccountStatement = false;
      emit(ExportError());
    }
  }

  // ============================================================================
  // 🧾 DOWNLOAD RECEIPT - REFINED
  // ============================================================================
  Future<void> downloadReceipt(
      BuildContext context,
      ReceiptModel receiptModel,
      ) async {
    if (isExportingPDF) return;

    isExportingPDF = true;
    emit(ExportLoading());
    final isArabic = context.locale.languageCode == 'ar';

    try {
      await _initializeFonts();
      final logoData = await _loadLogo();
      final pdf = pw.Document();
      final currency = _getCurrency(context);

      pdf.addPage(
        pw.Page(
          textDirection: _getTextDirection(context),
          theme: pw.ThemeData.withFont(base: _arFont),
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Elegant Header
                _buildElegantHeader(
                  logoData: logoData,
                  companyName: 'شركة دروع المحرك الماسية للتجارة',
                  documentType: '${"Receipt".tr()} ${receiptModel.kind}',
                  reference: receiptModel.reference,
                  date: receiptModel.date,
                 isArabic:isArabic
                ),

                pw.SizedBox(height: 20),

                // Main Content
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            _buildSectionHeader('received From'.tr()),
                            _buildContactCard(
                              name: receiptModel.contact.name,
                              organization: receiptModel.contact.organization,
                              phone: receiptModel.contact.phoneNumber,
                            ),

                            pw.SizedBox(height: 16),

                            _buildSectionHeader('Receipt Details'.tr()),
                            _buildElegantCard(
                              children: [
                                _buildInfoRow('Ref'.tr(), receiptModel.reference ?? ''),
                                _buildInfoRow('Date'.tr(), receiptModel.date ?? ''),
                                _buildInfoRow('Type'.tr(), receiptModel.kind),
                                _buildInfoRow('Account'.tr(), receiptModel.account?.nameEn ?? ''),
                              ],
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(width: 20),

                      // Right Column - Amounts
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            _buildSectionHeader('Amount Details'.tr()),
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: _buildAmountDisplay(
                                    'Amount'.tr(),
                                    '${receiptModel.amount} $currency',
                                    isPrimary: true,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 12),
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: _buildAmountDisplay(
                                    'allocated Amount'.tr(),
                                    '${receiptModel.amount} $currency',
                                    isAccent: true,
                                  ),
                                ),
                                pw.SizedBox(width: 8),
                                pw.Expanded(
                                  child: _buildAmountDisplay(
                                    'Unallocated Amount'.tr(),
                                    '${receiptModel.unAllocateAmount} $currency',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Allocations Table
                if (receiptModel.allocates?.isNotEmpty ?? false) ...[
                  _buildSectionHeader('Bond Assignments'.tr()),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: PdfBrandColors.border),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 12,
                      verticalRadius: 12,
                      child: pw.Table(
                        border: pw.TableBorder(
                          horizontalInside: pw.BorderSide(
                            color: PdfBrandColors.border,
                            width: 0.5,
                          ),
                        ),
                        children: [
                          _buildElegantTableHeader([
                            '#',
                            'Ref'.tr(),
                            'Amount'.tr(),
                            'Deserved Amount'.tr(),
                            'Date'.tr(),
                          ]),
                          ...receiptModel.allocates!.asMap().entries.map((entry) {
                            final index = entry.key;
                            final allocate = entry.value;
                            return _buildElegantTableRow(
                              [
                                '${index + 1}',
                                allocate.allocatee?[0].reference ?? '',
                                '${allocate.amount} $currency',
                                '${allocate.allocatee?[0].dueAmount ?? 0} $currency',
                                receiptModel.date ?? '',
                              ],
                              isAlternate: index.isOdd,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],

                pw.SizedBox(height: 16),
                _buildElegantFooter('1', '1'),
              ],
            );
          },
        ),
      );

      await _saveFile(
        context: context,
        pdf: pdf,
        name: 'receipt_${receiptModel.reference ?? formatDate(context, DateTime.now())}',
      );

      isExportingPDF = false;
      emit(ExportSuccess());
    } catch (e) {
      debugPrint('Receipt Export Error: $e');
      isExportingPDF = false;
      emit(ExportError());
    }
  }

  // ============================================================================
  // 📄 DOWNLOAD INVOICE - REFINED
  // ============================================================================
  Future<void> downloadInvoice(
      BuildContext context,
      InVoiceModel inVoiceModel,
      ) async {
    if (isExportingPDF) return;

    isExportingPDF = true;
    emit(ExportLoading());

    try {
      await _initializeFonts();
      final logoData = await _loadLogo();
      final pdf = pw.Document();
      final currency = _getCurrency(context);

      final isArabic = context.locale.languageCode == 'ar';
      final lineItems = inVoiceModel.lineItems ?? [];
      const itemsPerPage = 4;
      final itemPages = (lineItems.length / itemsPerPage).ceil();
      final totalPagesCount = 1 + itemPages;

      // ═══════════════════════════════════════════════════════════════════
      // 📄 PAGE 1 - Invoice Header & Summary
      // ═══════════════════════════════════════════════════════════════════
      pdf.addPage(
        pw.Page(
          textDirection: _getTextDirection(context),
          theme: pw.ThemeData.withFont(base: _arFont),
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Elegant Header
                _buildElegantHeader(
                  logoData: logoData,
                  companyName: 'شركة دروع المحرك الماسية للتجارة',
                  documentType: 'Invoice'.tr(),
                  reference: inVoiceModel.reference?.toString(),
                  date: inVoiceModel.createdAt?.toString().substring(0, 10),
                    isArabic:isArabic
                ),

                pw.SizedBox(height: 20),

                // Invoice Info & Customer in 2 columns
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column - Invoice Details
                    pw.Expanded(
                      child: _buildElegantCard(
                        title: 'Invoice Information'.tr(),
                        accentColor: PdfBrandColors.primary,
                        children: [
                          _buildInfoRow('Invoice Type'.tr(), inVoiceModel.type ?? '', isHighlight: true),
                          _buildInfoRow('Reference'.tr(), inVoiceModel.reference?.toString() ?? ''),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(vertical: 8),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'Status'.tr(),
                                  style: pw.TextStyle(
                                    font: _getFont('Status'.tr()),
                                    fontSize: 10,
                                    color: PdfBrandColors.textMuted,
                                  ),
                                ),
                                _buildStatusChip(inVoiceModel.status ?? ''),
                              ],
                            ),
                          ),
                          _buildInfoRow('Payment Method'.tr(), inVoiceModel.paymentMethod ?? ''),
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 16),

                    // Right Column - Dates
                    pw.Expanded(
                      child: _buildElegantCard(
                        title: 'Dates'.tr(),
                        accentColor: PdfBrandColors.accent,
                        children: [
                          _buildInfoRow('Release Date'.tr(), inVoiceModel.createdAt?.toString().substring(0, 10) ?? ''),
                          _buildInfoRow('Expiry Date'.tr(), inVoiceModel.dueDate?.toString() ?? ''),
                          _buildInfoRow('Date of Supply'.tr(), inVoiceModel.issueDate?.toString() ?? ''),
                          _buildInfoRow(
                            'From the Location'.tr(),
                            isArabic
                                ? (inVoiceModel.inventory?["ar_name"] ?? '')
                                : (inVoiceModel.inventory?["name"] ?? ''),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                // Customer Section
                _buildSectionHeader('Customer Information'.tr()),
                _buildContactCard(
                  name: inVoiceModel.contact?.name ?? '',
                  organization: inVoiceModel.contact?.organization,
                ),

                pw.Spacer(),

                // Summary Box
                _buildSummaryBox(
                  items: [
                    MapEntry('Total Before Tax'.tr(), '${calculateTotalUnitPrice(inVoiceModel.lineItems)} $currency'),
                    MapEntry('Tax Value'.tr(), '${calculateTotalTax(inVoiceModel.lineItems)} $currency'),
                    MapEntry('Deserved Amount'.tr(), '${inVoiceModel.paidAmount} $currency'),
                  ],
                  totalLabel: 'Total'.tr(),
                  totalValue: '${inVoiceModel.total} $currency',
                ),

                pw.SizedBox(height: 16),
                _buildElegantFooter('1', '$totalPagesCount'),
              ],
            );
          },
        ),
      );

      // ═══════════════════════════════════════════════════════════════════
      // 📄 PAGE 2+ - Line Items
      // ═══════════════════════════════════════════════════════════════════
      for (int pageIdx = 0; pageIdx < itemPages; pageIdx++) {
        final startIdx = pageIdx * itemsPerPage;
        final endIdx = (startIdx + itemsPerPage).clamp(0, lineItems.length);
        final pageItems = lineItems.sublist(startIdx, endIdx);

        pdf.addPage(
          pw.Page(
            textDirection: _getTextDirection(context),
            theme: pw.ThemeData.withFont(base: _arFont),
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(24),
            build: (pdfContext) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Mini Header
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfBrandColors.background,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: PdfBrandColors.border, width: 1),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Row(
                          children: [
                            pw.Container(
                              width: 4,
                              height: 20,
                              decoration: pw.BoxDecoration(
                                color: PdfBrandColors.primary,
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                            pw.SizedBox(width: 12),
                            pw.Text(
                              '${'Invoice'.tr()} #${inVoiceModel.reference}',
                              style: pw.TextStyle(
                                font: _enFont,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfBrandColors.text,
                              ),
                            ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfBrandColors.primaryPale,
                            borderRadius: pw.BorderRadius.circular(20),
                          ),
                          child: pw.Text(
                            'Products'.tr(),
                            style: pw.TextStyle(
                              font: _getFont('Products'.tr()),
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfBrandColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Products
                  pw.Expanded(
                    child: pw.Column(
                      children: pageItems.asMap().entries.map((entry) {
                        final item = entry.value;
                        final unitPrice = double.tryParse(item.unitPrice ?? '0') ?? 0;
                        final discount = double.tryParse(item.discount ?? '0') ?? 0;
                        final taxPercent = double.tryParse(item.taxPercent ?? '0') ?? 0;
                        final quantity = double.tryParse(item.quantity?.toString() ?? '1') ?? 1;

                        return _buildProductCard(
                          index: entry.key + 1 + (pageIdx * itemsPerPage),
                          name: item.name ?? '',
                          quantity: quantity,
                          unitPrice: unitPrice,
                          discount: discount,
                          taxPercent: taxPercent,
                          currency: currency,
                        );
                      }).toList(),
                    ),
                  ),

                  _buildElegantFooter('${pageIdx + 2}', '$totalPagesCount'),
                ],
              );
            },
          ),
        );
      }

      await _saveFile(
        context: context,
        pdf: pdf,
        name: 'invoice_${inVoiceModel.reference ?? formatDate(context, DateTime.now())}',
      );

      isExportingPDF = false;
      emit(ExportSuccess());
    } catch (e) {
      debugPrint('Invoice Export Error: $e');
      isExportingPDF = false;
      emit(ExportError());
    }
  }

  // ============================================================================
  // 🔢 CALCULATION HELPERS
  // ============================================================================
  double calculateTotalUnitPrice(List<dynamic>? lineItems) {
    if (lineItems == null || lineItems.isEmpty) return 0.0;

    return lineItems.fold<double>(0.0, (sum, item) {
      final unitPrice = double.tryParse(item.unitPrice?.toString() ?? '0') ?? 0;
      final discount = double.tryParse(item.discount?.toString() ?? '0') ?? 0;
      final quantity = double.tryParse(item.quantity?.toString() ?? '1') ?? 1;
      return sum + ((unitPrice - discount) * quantity);
    });
  }

  double calculateTotalTax(List<dynamic>? lineItems) {
    if (lineItems == null || lineItems.isEmpty) return 0.0;

    return lineItems.fold<double>(0.0, (sum, item) {
      final unitPrice = double.tryParse(item.unitPrice?.toString() ?? '0') ?? 0;
      final discount = double.tryParse(item.discount?.toString() ?? '0') ?? 0;
      final taxPercent = double.tryParse(item.taxPercent?.toString() ?? '0') ?? 0;
      final quantity = double.tryParse(item.quantity?.toString() ?? '1') ?? 1;
      final totalBeforeTax = (unitPrice - discount) * quantity;
      return sum + (totalBeforeTax * (taxPercent / 100));
    });
  }

  // ============================================================================
  // 💾 SAVE FILE
  // ============================================================================
  Future<String> _saveFile({
    required BuildContext context,
    required String name,
    required pw.Document pdf,
  }) async {
    Directory? path;

    if (Platform.isAndroid) {
      path = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      path = await getApplicationDocumentsDirectory();
    }

    if (path == null) {
      throw Exception('Unable to get storage directory');
    }

    final sanitizedName = name.replaceAll(RegExp(r'[^\w\-]'), '_');
    final file = File("${path.path}/$sanitizedName.pdf");
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);

    showMessage(context: context, message: 'تم حفظ الملف بنجاح ✓');

    return file.path;
  }

  // ============================================================================
  // 🔄 LEGACY METHOD ALIASES
  // ============================================================================
  Future<void> downloadRecipt(BuildContext context, ReceiptModel receiptModel) =>
      downloadReceipt(context, receiptModel);
}