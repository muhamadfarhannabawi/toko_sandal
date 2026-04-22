import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:toko_sandal/core/contants/api_contants.dart';
import 'package:toko_sandal/core/services/dio_client.dart';
import 'package:toko_sandal/features/dashboard/data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  // Gunakan underscore (_) untuk private variable
  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  String? _error;

  // FIX: Getter yang benar agar bisa dibaca oleh UI (DashboardPage)
  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    _error = null; // Reset error sebelum fetching
    notifyListeners();

    try {
      final response = await DioClient.instance.get(ApiConstants.products);
      
      // Pastikan struktur response sesuai dengan API kamu
      final List<dynamic> data = response.data['data'];
      _products = data.map((e) => ProductModel.fromJson(e)).toList();

      _status = ProductStatus.loaded;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Gagal memuat produk';
      _status = ProductStatus.error;
    } catch (e) {
      // Menangkap error umum (misal: error parsing JSON)
      _error = 'Terjadi kesalahan sistem';
      _status = ProductStatus.error;
    }

    notifyListeners(); 
  }
}