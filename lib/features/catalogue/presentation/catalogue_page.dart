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
              return selectedCategory == 'All' ||
                  product.categoryName == selectedCategory;
            }).toList();

            return CustomScrollView(
              slivers: [
                // HEADER
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

                    onProfilePressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },

                    onSignOutPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                    },
                  ),
                ),

                // SEARCH
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SearchPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 58,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE9E2DF)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.primary,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  'What are you looking for?',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  size: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // PERSONALISED AI
                if (personalisedAsync != null)
                  personalisedAsync.when(
                    loading: () => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(28),
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

                // CATEGORIES TITLE
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 30, 16, 10),
                    child: CatalogueSectionHeader(
                      title: 'Categories',
                      subtitle: 'Browse what is available',
                    ),
                  ),
                ),

                // CATEGORY FILTER
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

                // PRODUCTS TITLE
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: CatalogueSectionHeader(
                            title: 'Products',
                            subtitle: 'Available across China City',
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${filteredProducts.length}',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // PRODUCTS
                if (filteredProducts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyProducts(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return ProductCard(product: filteredProducts[index]);
                      }, childCount: filteredProducts.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
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
