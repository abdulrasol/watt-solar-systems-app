import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_global_category.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_categories_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

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
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: state.isLoading
                ? const AdminLoadingState(message: 'Loading Categories...')
                : state.error != null && state.categories.isEmpty
                    ? AdminErrorState(
                        error: state.error!,
                        onRetry: () => ref.read(adminCategoriesProvider.notifier).fetchCategories(isRefresh: true),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(adminCategoriesProvider.notifier).fetchCategories(isRefresh: true),
                        child: state.categories.isEmpty
                            ? const AdminEmptyState(
                                icon: Iconsax.category_bold,
                                title: 'No Categories',
                                subtitle: 'Add a global category to get started',
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.all(20.w),
                                itemCount: state.categories.length + (state.isMoreLoading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.categories.length) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20.h),
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  return _CategoryCard(category: state.categories[index]);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Global Categories',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
              ),
              Text(
                'System-wide product/service categories',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showCategoryDialog(),
            icon: Icon(Icons.add, size: 20.sp),
            label: const Text('Add New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
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
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: category.icon != null && category.icon!.isNotEmpty
                  ? Image.network(category.icon!, width: 30.w, height: 30.w, errorBuilder: (_, _, _) => Icon(Iconsax.category_bold, color: AppTheme.primaryColor, size: 24.sp))
                  : Icon(Iconsax.category_bold, color: AppTheme.primaryColor, size: 24.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                showDialog(context: context, builder: (context) => _CategoryDialog(category: category));
              } else if (value == 'delete') {
                _confirmDelete(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
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
              final data = {
                'name': _nameController.text,
                'icon': _iconController.text,
              };
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
