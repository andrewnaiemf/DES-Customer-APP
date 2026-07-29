import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// ============================================================================
// 📦 DELIVERY NOTE MODEL
// ============================================================================
class DeliveryNoteModel {
  final String? reference;
  final String? issueDate;
  final String? dueDate;
  final String? location;
  final CustomerModel? customer;
  final List<DeliveryItem>? items;
  final String? signatureImage;
  final String? senderSignature;

  DeliveryNoteModel({
    this.reference,
    this.issueDate,
    this.dueDate,
    this.location,
    this.customer,
    this.items,
    this.signatureImage,
    this.senderSignature,
  });
}

class CustomerModel {
  final String name;
  final String? taxNumber;
  final String? organization;
  final String? phone;

  CustomerModel({
    required this.name,
    this.taxNumber,
    this.organization,
    this.phone,
  });
}

class DeliveryItem {
  final String? sku;
  final String? name;
  final String? description;
  final String? barcode;
  final int quantity;

  DeliveryItem({
    this.sku,
    this.name,
    this.description,
    this.barcode,
    required this.quantity,
  });
}

// ============================================================================
// 🎨 DELIVERY NOTE TEST SCREEN
// ============================================================================
class DeliveryNoteTestScreen extends StatefulWidget {
  const DeliveryNoteTestScreen({super.key});

  @override
  State<DeliveryNoteTestScreen> createState() => _DeliveryNoteTestScreenState();
}

class _DeliveryNoteTestScreenState extends State<DeliveryNoteTestScreen> {
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isRTL => context.locale.languageCode == 'ar';

  // ============================================================================
  // 📊 SAMPLE DATA
  // ============================================================================
  late DeliveryNoteModel _sampleDeliveryNote;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _sampleDeliveryNote = DeliveryNoteModel(
      reference: 'DN-2026-001234',
      issueDate: '2026-01-28',
      dueDate: '2026-02-15',
      location: 'الرياض، حي السليمانية',
      customer: CustomerModel(
        name: 'شركة التقنية المتطورة',
        taxNumber: '312696211500003',
        organization: 'مؤسسة الأعمال الرقمية',
        phone: '+966 50 123 4567',
      ),
      items: [
        DeliveryItem(
          sku: 'PROD-001',
          name: 'جهاز كمبيوتر محمول',
          description: 'HP Pavilion 15 - Intel Core i7, 16GB RAM',
          barcode: '123456789012',
          quantity: 5,
        ),
        DeliveryItem(
          sku: 'PROD-002',
          name: 'شاشة LED 27 بوصة',
          description: 'Samsung 4K Ultra HD Monitor',
          barcode: '987654321098',
          quantity: 10,
        ),
        DeliveryItem(
          sku: 'PROD-003',
          name: 'طابعة ليزر ملونة',
          description: 'Canon imageCLASS MF445dw',
          barcode: '456789123456',
          quantity: 3,
        ),
        DeliveryItem(
          sku: 'PROD-004',
          name: 'لوحة مفاتيح لاسلكية',
          description: 'Logitech MX Keys',
          barcode: '789123456789',
          quantity: 15,
        ),
        DeliveryItem(
          sku: 'PROD-005',
          name: 'ماوس لاسلكي',
          description: 'Logitech MX Master 3',
          barcode: '321654987321',
          quantity: 15,
        ),
      ],
      signatureImage: null, // في التطبيق الفعلي، يمكن إضافة توقيع
      senderSignature: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF15172A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _isDark ? const Color(0xFF1D1D25) : Colors.white,
        title: Text(
          'Delivery Note Preview'.tr(),
          style: TextStyle(
            color: _isDark ? Colors.white : const Color(0xFF1D1D25),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: _isDark ? Colors.white : const Color(0xFF1D1D25),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.picture_as_pdf_rounded,
              color: _isDark ? const Color(0xFF6842E2) : const Color(0xFF6842E2),
            ),
            onPressed: () {
              // هنا يمكن تصدير PDF
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Generating PDF...'.tr()),
                  backgroundColor: const Color(0xFF6842E2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildDeliveryNotePreview(),
      ),
    );
  }

  // ============================================================================
  // 📄 DELIVERY NOTE PREVIEW
  // ============================================================================
  Widget _buildDeliveryNotePreview() {
    return Container(
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1D1D25) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          const Divider(height: 1),

          // Document Info
          _buildDocumentInfo(),

          const Divider(height: 1),

          // Customer Info
          _buildCustomerInfo(),

          const Divider(height: 1),

          // Items Table
          _buildItemsTable(),

          const Divider(height: 1),

          // Signatures Section
          _buildSignaturesSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================================
  // 📋 HEADER SECTION
  // ============================================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6842E2),
            const Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'DELIVERY NOTE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'سند تسليم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 📝 DOCUMENT INFO SECTION
  // ============================================================================
  Widget _buildDocumentInfo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document Information'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : const Color(0xFF1D1D25),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.tag_rounded,
                  label: 'Reference'.tr(),
                  value: _sampleDeliveryNote.reference ?? '-',
                  color: const Color(0xFF6842E2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.calendar_today_rounded,
                  label: 'Issue Date'.tr(),
                  value: _sampleDeliveryNote.issueDate ?? '-',
                  color: const Color(0xFF28E6C5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.event_rounded,
                  label: 'Due Date'.tr(),
                  value: _sampleDeliveryNote.dueDate ?? '-',
                  color: const Color(0xFFFF9F43),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.location_on_rounded,
                  label: 'Location'.tr(),
                  value: _sampleDeliveryNote.location ?? '-',
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: (_isDark ? Colors.white : const Color(0xFF1D1D25))
                      .withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : const Color(0xFF1D1D25),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 👤 CUSTOMER INFO SECTION
  // ============================================================================
  Widget _buildCustomerInfo() {
    final customer = _sampleDeliveryNote.customer;
    if (customer == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF28E6C5).withOpacity(0.1),
            const Color(0xFF6842E2).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6842E2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: const Color(0xFF6842E2),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Customer Information'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDark ? Colors.white : const Color(0xFF1D1D25),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCustomerDetailRow(
            icon: Icons.person_rounded,
            label: 'Name'.tr(),
            value: customer.name,
          ),
          if (customer.organization != null) ...[
            const SizedBox(height: 12),
            _buildCustomerDetailRow(
              icon: Icons.business_center_rounded,
              label: 'Organization'.tr(),
              value: customer.organization!,
            ),
          ],
          if (customer.taxNumber != null) ...[
            const SizedBox(height: 12),
            _buildCustomerDetailRow(
              icon: Icons.numbers_rounded,
              label: 'Tax Number'.tr(),
              value: customer.taxNumber!,
            ),
          ],
          if (customer.phone != null) ...[
            const SizedBox(height: 12),
            _buildCustomerDetailRow(
              icon: Icons.phone_rounded,
              label: 'Phone'.tr(),
              value: customer.phone!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6842E2),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: (_isDark ? Colors.white : const Color(0xFF1D1D25))
                  .withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isDark ? Colors.white : const Color(0xFF1D1D25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 📦 ITEMS TABLE SECTION
  // ============================================================================
  Widget _buildItemsTable() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF28E6C5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: const Color(0xFF28E6C5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Items List'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDark ? Colors.white : const Color(0xFF1D1D25),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6842E2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_sampleDeliveryNote.items?.length ?? 0} items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6842E2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_sampleDeliveryNote.items ?? []).asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildItemCard(item, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildItemCard(DeliveryItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xFF2A2A3E).withOpacity(0.5)
            : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6842E2).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6842E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name ?? '-',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : const Color(0xFF1D1D25),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF28E6C5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(
                    color: Color(0xFF28E6C5),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (item.description != null) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: TextStyle(
                fontSize: 13,
                color: (_isDark ? Colors.white : const Color(0xFF1D1D25))
                    .withOpacity(0.6),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (item.sku != null)
                _buildItemDetail(
                  icon: Icons.qr_code_rounded,
                  label: 'SKU',
                  value: item.sku!,
                ),
              if (item.barcode != null) ...[
                const SizedBox(width: 12),
                _buildItemDetail(
                  icon: Icons.barcode_reader,
                  label: 'Barcode',
                  value: item.barcode!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6842E2)),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: (_isDark ? Colors.white : const Color(0xFF1D1D25))
                  .withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : const Color(0xFF1D1D25),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ✍️ SIGNATURES SECTION
  // ============================================================================
  Widget _buildSignaturesSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Signatures'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : const Color(0xFF1D1D25),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSignatureBox(
                  title: 'Sender Signature'.tr(),
                  icon: Icons.person_outline_rounded,
                  color: const Color(0xFF6842E2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSignatureBox(
                  title: 'Receiver Signature'.tr(),
                  icon: Icons.how_to_reg_rounded,
                  color: const Color(0xFF28E6C5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureBox({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to sign'.tr(),
            style: TextStyle(
              fontSize: 11,
              color: (_isDark ? Colors.white : const Color(0xFF1D1D25))
                  .withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
