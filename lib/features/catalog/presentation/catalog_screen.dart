import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/product_api_provider.dart';
import '../domain/product_model_api.dart';
import '../../../core/utils/shared_dialogs.dart';
import '../../../core/routing/permission_guard.dart';
import 'package:go_router/go_router.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  bool _isGridView = true;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final asyncProducts = ref.watch(productsApiProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Catalog', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${asyncProducts.value?.length ?? 0} items available', style: theme.textTheme.bodyMedium),
                  ],
                ),
                Row(
                  children: [
                    PermissionGuard(
                      requiredPermission: 'CAT.CAT_CAT.VIEW',
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/catalog/categories'),
                        icon: const Icon(Icons.category, size: 18),
                        label: const Text('Categories'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    PermissionGuard(
                      requiredPermission: 'CAT.CAT_PROD.CREATE',
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/catalog/create'),
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: const Text('Add Product'),
                      ),
                    ),
                  ],
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
          ),
          
          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search products by name or SKU...',
                        prefixIcon: const Icon(LucideIcons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => SharedDialogs.showFilterDialog(context),
                  icon: const Icon(LucideIcons.filter, size: 18),
                  label: const Text('Filter'),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.layoutGrid, size: 20),
                        color: _isGridView ? theme.colorScheme.primary : theme.iconTheme.color,
                        onPressed: () => setState(() => _isGridView = true),
                      ),
                      Container(width: 1, height: 24, color: theme.dividerColor),
                      IconButton(
                        icon: const Icon(LucideIcons.list, size: 20),
                        color: !_isGridView ? theme.colorScheme.primary : theme.iconTheme.color,
                        onPressed: () => setState(() => _isGridView = false),
                      ),
                    ],
                  ),
                )
              ],
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
          ),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child: asyncProducts.when(
              data: (data) {
                final products = data.where((p) => 
                  p.productName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                  p.productCode.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();
                
                if (products.isEmpty) return _buildEmptyState(theme);
                return _isGridView ? _buildGridView(products, isDesktop) : _buildListView(products);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.packageSearch, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text('No products found', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Try adjusting your search or filters', style: theme.textTheme.bodyMedium),
        ],
      ),
    ).animate().fade();
  }

  Widget _buildGridView(List<ProductModel> products, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isDesktop ? 4 : (constraints.maxWidth > 600 ? 3 : 1);
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _buildGridCard(products[index]).animate().fade(delay: (100 * (index % 6)).ms).slideY(begin: 0.1);
          },
        );
      }
    );
  }

  Widget _buildGridCard(ProductModel product) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(product.isActive ? 'Active' : 'Archived');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showProductDetailsDialog(context, product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: const Icon(LucideIcons.imageOff, size: 48, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.isActive ? 'Active' : 'Archived',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.productCode,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.basePrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(LucideIcons.boxes, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              '-',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<ProductModel> products) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        final statusColor = _getStatusColor(product.isActive ? 'Active' : 'Archived');
        
        return Card(
          child: InkWell(
            onTap: () => context.go('/catalog/view/${product.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl ?? '',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80, height: 80,
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.productName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(product.productCode, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                            const SizedBox(width: 8),
                            Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey)),
                            const SizedBox(width: 8),
                            Text(product.category?.name ?? '-', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${product.basePrice.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.isActive ? 'Active' : 'Archived',
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text('- in stock', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  IconButton(icon: const Icon(LucideIcons.moreVertical), onPressed: () => context.go('/catalog/edit/${product.id}')),
                ],
              ),
            ),
          ),
        ).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.teal;
      case 'Draft': return Colors.orange;
      case 'Archived': return Colors.grey;
      default: return Colors.blue;
    }
  }

  void _showProductDetailsDialog(BuildContext context, ProductModel product) {
    context.go('/catalog/view/${product.id}');
  }
}
