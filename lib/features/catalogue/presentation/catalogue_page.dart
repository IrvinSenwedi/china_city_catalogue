import 'package:china_city_catalogue/features/profile/presentation/profile_page.dart';
import 'package:china_city_catalogue/features/search/presentation/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../../recommendations/providers/recommendation_providers.dart';
import '../../reservations/presentation/my_reservations_page.dart';
import '../providers/catalogue_providers.dart';
import 'widgets/catalogue_error_view.dart';
import 'widgets/catalogue_header.dart';

import 'widgets/catalogue_section_header.dart';
import 'widgets/category_filter.dart';
import 'widgets/empty_products.dart';
import 'widgets/for_you_section.dart';
import 'widgets/product_card.dart';

class CataloguePage extends ConsumerStatefulWidget {
  const CataloguePage({super.key});

  @override
  ConsumerState<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends ConsumerState<CataloguePage> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    final user = ref.watch(currentUserProvider);

    final personalisedAsync = user == null
        ? null
        : ref.watch(userRecommendationsProvider(user.id));

    return Scaffold(
      body: SafeArea(
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => CatalogueErrorView(
            onRetry: () {
              ref.invalidate(productsProvider);
            },
          ),
          data: (products) {
            final categories = [
              'All',
              ...products
                  .map((product) => product.categoryName)
                  .where((category) => category.isNotEmpty)
                  .toSet(),
            ];

            final filteredProducts = products.where((product) {
              final matchesCategory =
                  selectedCategory == 'All' ||
                  product.categoryName == selectedCategory;

              return matchesCategory;
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: CatalogueHeader(
                    onReservationsPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyReservationsPage(),
                        ),
                      );
                    },
                    onSignOutPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                    },
                    onProfilePressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchPage()),
                        );
                      },
                      child: IgnorePointer(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'What are you looking for?',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (personalisedAsync != null)
                  personalisedAsync.when(
                    loading: () => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (_, __) =>
                        const SliverToBoxAdapter(child: SizedBox.shrink()),
                    data: (recommendations) => SliverToBoxAdapter(
                      child: ForYouSection(
                        recommendations: recommendations,
                        products: products,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 28, 16, 10),
                    child: CatalogueSectionHeader(
                      title: 'Categories',
                      subtitle: 'Browse by category',
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: CategoryFilter(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onSelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CatalogueSectionHeader(
                          title: 'Products',
                          subtitle: 'Available in China City',
                        ),
                        Text(
                          '${filteredProducts.length}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                if (filteredProducts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyProducts(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ProductCard(product: filteredProducts[index]),
                        childCount: filteredProducts.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
