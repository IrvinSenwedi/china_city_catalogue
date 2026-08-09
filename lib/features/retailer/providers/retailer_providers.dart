import 'package:china_city_catalogue/features/retailer/data/retaailer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalogue/models/product.dart';
import '../../catalogue/providers/catalogue_providers.dart';

final retailerRepositoryProvider = Provider<RetailerRepository>((ref) {
  return RetailerRepository(ref.watch(supabaseProvider));
});

final retailerProductsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(retailerRepositoryProvider).getMyProducts();
});
