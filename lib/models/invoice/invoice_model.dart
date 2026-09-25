import 'package:app/models/line_items/line_items_model.dart';
import 'package:app/models/owner/owner_model.dart';
import 'package:app/models/payment/payments_model.dart';
import 'package:app/models/user/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoice_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class InVoiceModel {
  late int? id;
  late int? contactId;
  late String? reference;
  late String? description;
  late String? issueDate;
  late String? dueDate;
  late String? status;
  late String? dueAmount;
  late String? paidAmount;
  late String? total;
  late String? notes;
  late String? pdf;
  late dynamic termsConditions;
  late String? qrcodeString;
  late String? paymentMethod;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late dynamic inventory;
  late String? type;
  late List<PaymentsModel>? payments;
  late List<LineItemsModel>? lineItems;
  late UserModel? contact;
  late OwnerModel? owner;

  InVoiceModel({
    this.id,
    this.contactId,
    this.reference,
    this.description,
    this.issueDate,
    this.dueDate,
    this.status,
    this.dueAmount,
    this.paidAmount,
    this.total,
    this.notes,
    this.pdf,
    this.termsConditions,
    this.qrcodeString,
    this.paymentMethod,
    this.createdAt,
    this.inventory,
    this.type,
    this.payments,
    this.lineItems,
    this.contact,
    this.owner,
  });

  factory InVoiceModel.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic value) => value == null ? null : value.toString();
    final normalized = Map<String, dynamic>.from(json);
    for (final key in ['due_amount', 'paid_amount', 'total', 'payment_method', 'issue_date', 'due_date']) {
      if (normalized.containsKey(key)) {
        normalized[key] = asString(normalized[key]);
      }
    }

    final rawItems = normalized['line_items'];
    if (rawItems is List) {
      normalized['line_items'] = rawItems.whereType<Map>().map((item) {
        final mapped = Map<String, dynamic>.from(item);
        for (final key in [
          'quantity',
          'unit_price',
          'discount',
          'tax_percent',
          'description',
          'name',
          'discount_type',
        ]) {
          if (mapped[key] != null) {
            mapped[key] = mapped[key].toString();
          }
        }
        mapped['product_id'] ??= 0;
        return mapped;
      }).toList();
    }

    try {
      return _$InVoiceModelFromJson(normalized);
    } catch (_) {
      final fallback = _$InVoiceModelFromJson({
        ...normalized,
        'line_items': null,
        'contact': null,
        'owner': null,
        'payments': null,
      });
      if (rawItems is List) {
        fallback.lineItems = [];
        for (final item in rawItems) {
          if (item is! Map) continue;
          try {
            fallback.lineItems!.add(
              LineItemsModel.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (_) {}
        }
      }
      return fallback;
    }
  }

  Map<String, dynamic> toJson() => _$InVoiceModelToJson(this);
}
