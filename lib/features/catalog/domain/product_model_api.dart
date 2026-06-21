import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../master_data/domain/master_data_model.dart';

class ProductModel {
  final String id;
  final String productCode;
  final String productName;
  final double basePrice;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final MasterDataModel? category;
  final MasterDataModel? woodType;
  final MasterDataModel? uom;

  ProductModel({
    required this.id,
    required this.productCode,
    required this.productName,
    this.basePrice = 0.0,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.category,
    this.woodType,
    this.uom,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      productCode: json['product_code'] ?? '',
      productName: json['product_name'] ?? '',
      basePrice: (json['base_price'] ?? 0).toDouble(),
      description: json['description'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      category: json['category'] != null ? MasterDataModel.fromJson(json['category']) : null,
      woodType: json['wood_type'] != null ? MasterDataModel.fromJson(json['wood_type']) : null,
      uom: json['uom'] != null ? MasterDataModel.fromJson(json['uom']) : null,
    );
  }
}
