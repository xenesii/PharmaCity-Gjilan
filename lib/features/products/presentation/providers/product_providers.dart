import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) => ProductRepository());

final productsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productRepositoryProvider).getProducts();
});

final featuredProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productRepositoryProvider).getProducts(featured: true);
});

final productsByCategoryProvider = Provider.family<Stream<List<ProductModel>>, String>((ref, category) {
  return ref.read(productRepositoryProvider).getProducts(category: category);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider.family<Stream<List<ProductModel>>, String>((ref, query) {
  if (query.isEmpty) {
    final cachedProducts = ref.read(productsProvider).valueOrNull;
    if (cachedProducts != null) {
      return Stream.value(cachedProducts);
    }
    return ref.read(productRepositoryProvider).getProducts();
  }
  return ref.read(productRepositoryProvider).getProducts(searchQuery: query);
});

/// Hardcoded categories — no longer fetched from Firestore.
/// Admin selects from these when adding products.
final List<CategoryModel> hardcodedCategories = [
  CategoryModel(id: 'cat_medicines', name: 'Medikamente', sortOrder: 1, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&q=80'),
  CategoryModel(id: 'cat_vitamins', name: 'Vitamina & Suplemente', sortOrder: 2, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=400&q=80'),
  CategoryModel(id: 'cat_personal_care', name: 'Kujdes Personal', sortOrder: 3, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&q=80'),
  CategoryModel(id: 'cat_beauty_skin', name: 'Bukuri & Kujdes për Lëkurë', sortOrder: 4, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400&q=80'),
  CategoryModel(id: 'cat_baby_care', name: 'Kujdes për Foshnja', sortOrder: 5, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&q=80'),
  CategoryModel(id: 'cat_medical_devices', name: 'Pajisje Mjekësore', sortOrder: 6, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=400&q=80'),
  CategoryModel(id: 'cat_wellness', name: 'Mirëqenie', sortOrder: 7, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&q=80'),
  CategoryModel(id: 'cat_first_aid', name: 'Ndihmë e Parë', sortOrder: 8, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&q=80'),
  CategoryModel(id: 'cat_fitness', name: 'Fitness & Ushqim', sortOrder: 9, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80'),
  CategoryModel(id: 'cat_offers', name: 'Oferta', sortOrder: 10, createdAt: DateTime(2024),
      imageUrl: 'https://images.unsplash.com/photo-1607082349566-187342175e2f?w=400&q=80'),
];

final categoriesProvider = Provider<List<CategoryModel>>((ref) => hardcodedCategories);

final selectedProductProvider = FutureProvider.family<ProductModel?, String>((ref, id) async {
  return ref.read(productRepositoryProvider).getProductById(id);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  if (category != null && category.isNotEmpty) {
    return ref.watch(productsByCategoryProvider(category));
  }
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.valueOrNull != null
      ? Stream.value(productsAsync.valueOrNull!)
      : ref.read(productRepositoryProvider).getProducts();
});

// Favorites using SharedPreferences
final favoriteIdsProvider = StateNotifierProvider<FavoriteIdsNotifier, Set<String>>((ref) => FavoriteIdsNotifier());

class FavoriteIdsNotifier extends StateNotifier<Set<String>> {
  FavoriteIdsNotifier() : super({});

  void toggle(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
  }

  bool isFavorite(String productId) => state.contains(productId);
}
