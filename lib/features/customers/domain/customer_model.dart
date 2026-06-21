import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../master_data/domain/master_data_model.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? addressLine1;
  final String? addressLine2;
  final String? zipCode;
  final String? taxId;
  final double creditLimit;
  final bool isActive;
  final MasterDataModel? customerType;
  final MasterDataModel? country;
  final MasterDataModel? state;
  final MasterDataModel? city;

  CustomerModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.zipCode,
    this.taxId,
    this.creditLimit = 0.0,
    this.isActive = true,
    this.customerType,
    this.country,
    this.state,
    this.city,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      zipCode: json['zip_code'],
      taxId: json['tax_id'],
      creditLimit: (json['credit_limit'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
      customerType: json['customer_type'] != null ? MasterDataModel.fromJson(json['customer_type']) : null,
      country: json['country'] != null ? MasterDataModel.fromJson(json['country']) : null,
      state: json['state'] != null ? MasterDataModel.fromJson(json['state']) : null,
      city: json['city'] != null ? MasterDataModel.fromJson(json['city']) : null,
    );
  }
}
