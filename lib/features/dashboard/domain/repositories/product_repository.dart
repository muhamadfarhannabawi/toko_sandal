import 'package:toko_sandal/features/dashboard/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10, String? category});
  Future<ProductModel> getProductById(int id);
}
