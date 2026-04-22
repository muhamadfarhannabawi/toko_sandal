import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
    required this.isActive,
  });

  // fromJson: mengubah Map<String, dynamic> → ProductModel
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        // Menangani ID kapital maupun kecil
        id: json['ID'] as int? ?? json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        // Pastikan harga dikonversi dengan aman ke double
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        stock: json['stock'] as int? ?? 0,
        category: json['category'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
      );

  // WAJIB: Daftarkan semua field di props agar Equatable bisa membandingkan objek
  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        stock,
        category,
        imageUrl,
        isActive,
      ];
}