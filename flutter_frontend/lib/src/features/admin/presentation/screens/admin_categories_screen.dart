import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/admin/domain/models/admin_global_category.dart';
import 'package:watt/src/features/admin/presentation/controllers/admin_categories_controller.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_content_layout.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:watt/src/utils/app_theme.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminCategoriesProvider.notifier).fetchCategories(isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminCategoriesProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCategoriesProvider);
    return AdminPageScaffold(
      actions: [
        FilledButton.icon(
          onPressed: () => _showCategoryDialog(),
          icon: const Icon(Iconsax.add),
          label: const Text('Add'),
        ),
      ],
      child: Builder(builder: (context) {
        final layout = AdminLayoutScope.of(context);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(layout.padding, 16, layout.padding, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Global Categories',
                          style: TextStyle(fontSize: layout.isMobile ? 20 : 24, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'System-wide product/service categories',
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: AppTheme.fontFamily),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.isLoading
                  ? const AdminLoadingState(message: 'Loading Categories...')
                  : state.error != null && state.categories.isEmpty
                  ? AdminErrorState(error: state.error!, onRetry: () => ref.read(adminCategoriesProvider.notifier).fetchCategories(isRefresh: true))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(adminCategoriesProvider.notifier).fetchCategories(isRefresh: true),
                      child: state.categories.isEmpty
                          ? const AdminEmptyState(icon: Iconsax.category, title: 'No Categories', subtitle: 'Add a global category to get started')
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                final columns = layout.isDesktop ? 3 : width >= 600 ? 2 : 1;
  
                                if (columns == 1) {
                                  return ListView.builder(
                                    controller: _scrollController,
                                    padding: EdgeInsets.fromLTRB(layout.padding, 0, layout.padding, 24),
                                    itemCount: state.categories.length + (state.isMoreLoading ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == state.categories.length) {
                                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                                      }
                                      return _CategoryCard(category: state.categories[index]);
                                    },
                                  );
                                }
  
                                return GridView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.fromLTRB(layout.padding, 0, layout.padding, 24),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: columns >= 3 ? 1.6 : 2.0,
                                  ),
                                  itemCount: state.categories.length + (state.isMoreLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == state.categories.length) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    return _CategoryCard(category: state.categories[index]);
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  void _showCategoryDialog({AdminGlobalCategory? category}) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(category: category),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final AdminGlobalCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: category.icon != null && category.icon!.isNotEmpty
                  ? Image.network(
                      category.icon!,
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) => const Icon(Iconsax.category, color: AppTheme.primaryColor, size: 24),
                    )
                  : const Icon(Iconsax.category, color: AppTheme.primaryColor, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                showDialog(
                  context: context,
                  builder: (context) => _CategoryDialog(category: category),
                );
              } else if (value == 'delete') {
                _confirmDelete(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete ${category.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminCategoriesProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CategoryDialog extends ConsumerStatefulWidget {
  final AdminGlobalCategory? category;
  const _CategoryDialog({this.category});

  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _iconController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _iconController = TextEditingController(text: widget.category?.icon);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Electronics'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _iconController,
              decoration: const InputDecoration(labelText: 'Icon URL', hintText: 'Optional'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final data = {'name': _nameController.text, 'icon': _iconController.text};
              if (widget.category == null) {
                ref.read(adminCategoriesProvider.notifier).createCategory(data);
              } else {
                ref.read(adminCategoriesProvider.notifier).updateCategory(widget.category!.id, data);
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
