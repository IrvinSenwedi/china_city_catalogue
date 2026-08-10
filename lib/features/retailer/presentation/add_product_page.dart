import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalogue/providers/catalogue_providers.dart';
import '../providers/retailer_providers.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  String? selectedCategoryId;

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    final price = double.tryParse(priceController.text.trim());

    final stock = int.tryParse(stockController.text.trim());

    if (name.isEmpty) {
      _showMessage('Enter a product name.');
      return;
    }

    if (description.isEmpty) {
      _showMessage('Enter a product description.');
      return;
    }

    if (price == null || price < 0) {
      _showMessage('Enter a valid price.');
      return;
    }

    if (stock == null || stock < 0) {
      _showMessage('Enter a valid stock quantity.');
      return;
    }

    if (selectedCategoryId == null) {
      _showMessage('Select a category.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ref
          .read(retailerRepositoryProvider)
          .addProduct(
            name: name,
            description: description,
            price: price,
            stockQuantity: stock,
            categoryId: selectedCategoryId!,
          );

      // Refresh retailer product list.
      ref.invalidate(retailerProductsProvider);

      // Refresh customer catalogue too.
      ref.invalidate(productsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully.')),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      _showMessage('Failed to add product: $error');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load categories.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),

          data: (categories) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Product Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      hintText: 'e.g. Bluetooth Speaker',
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter product description',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select category'),
                    items: categories.map((category) {
                      final id = category['id'] as String;

                      final name = category['name'] as String;

                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) {
                            setState(() {
                              selectedCategoryId = value;
                            });
                          },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: '0.00',
                      prefixText: 'R ',
                      prefixIcon: Icon(Icons.payments_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity',
                      hintText: '0',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Stock status is calculated automatically:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '0 = Out of Stock\n'
                    '1–5 = Low Stock\n'
                    '6+ = In Stock',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: isSaving ? null : saveProduct,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(
                        isSaving ? 'Adding Product...' : 'Add Product',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
