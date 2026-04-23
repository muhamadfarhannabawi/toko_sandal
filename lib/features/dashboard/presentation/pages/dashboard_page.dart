import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_sandal/core/routes/app_router.dart';
import 'package:toko_sandal/features/auth/presentation/provider/auth_provider.dart';
import 'package:toko_sandal/features/dashboard/presentation/providers/product_provider.dart';
import 'package:toko_sandal/features/dashboard/data/models/product_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProv = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              'Halo, ${auth.firebaseUser?.displayName ?? 'Pelanggan'}!',
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              final navigator = Navigator.of(context);
               auth.logout();
              navigator.pushReplacementNamed(AppRouter.login);
            },
          ),
        ],
      ),
      body: _buildBody(productProv),
    );
  }

  Widget _buildBody(ProductProvider provider) {
    switch (provider.status) {
      case ProductStatus.initial:
      case ProductStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat produk...'),
            ],
          ),
        );

      case ProductStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(provider.error ?? 'Gagal mengambil data', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchProducts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );

      case ProductStatus.loaded:
        if (provider.products.isEmpty) {
          return const Center(child: Text('Belum ada produk yang tersedia.'));
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchProducts(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68, 
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: provider.products.length,
            itemBuilder: (context, i) => ProductCard(product: provider.products[i]),
          ),
        );
    }
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // KOREKSI: Format mata uang Indonesia
    // final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias, // KOREKSI: Agar gambar mengikuti lekukan kartu
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {}, // Tambahkan navigasi detail di sini nanti
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // currencyFormatter.format(product.price),
                    'Rp ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      product.category,
                      style: TextStyle(fontSize: 9, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}