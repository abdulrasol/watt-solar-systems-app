import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_currency.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_currency_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminCurrencyScreen extends ConsumerStatefulWidget {
  const AdminCurrencyScreen({super.key});

  @override
  ConsumerState<AdminCurrencyScreen> createState() => _AdminCurrencyScreenState();
}

class _AdminCurrencyScreenState extends ConsumerState<AdminCurrencyScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminCurrencyProvider.notifier).fetchCurrencies(isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminCurrencyProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCurrencyProvider);

    return AdminPageScaffold(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: state.isLoading
                ? const AdminLoadingState(message: 'Loading Currencies...')
                : state.error != null && state.currencies.isEmpty
                ? AdminErrorState(error: state.error!, onRetry: () => ref.read(adminCurrencyProvider.notifier).fetchCurrencies(isRefresh: true))
                : RefreshIndicator(
                    onRefresh: () => ref.read(adminCurrencyProvider.notifier).fetchCurrencies(isRefresh: true),
                    child: state.currencies.isEmpty
                        ? const AdminEmptyState(icon: Iconsax.money, title: 'No Currencies', subtitle: 'Add a currency to get started')
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(20.w),
                            itemCount: state.currencies.length + (state.isMoreLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.currencies.length) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.h),
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              }
                              return _CurrencyCard(currency: state.currencies[index]);
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currencies',
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                ),
                Text(
                  'Manage system-wide monetary units',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCurrencyDialog(),
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

  void _showCurrencyDialog({AdminCurrency? currency}) {
    showDialog(
      context: context,
      builder: (context) => _CurrencyDialog(currency: currency),
    );
  }
}

class _CurrencyCard extends ConsumerWidget {
  final AdminCurrency currency;
  const _CurrencyCard({required this.currency});

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
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Center(
              child: Text(
                currency.symbol,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency.name,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  currency.code,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (currency.isDefault)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
              child: Text(
                'Default',
                style: TextStyle(fontSize: 10.sp, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                showDialog(
                  context: context,
                  builder: (context) => _CurrencyDialog(currency: currency),
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
        title: const Text('Delete Currency'),
        content: Text('Are you sure you want to delete ${currency.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminCurrencyProvider.notifier).deleteCurrency(currency.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CurrencyDialog extends ConsumerStatefulWidget {
  final AdminCurrency? currency;
  const _CurrencyDialog({this.currency});

  @override
  ConsumerState<_CurrencyDialog> createState() => _CurrencyDialogState();
}

class _CurrencyDialogState extends ConsumerState<_CurrencyDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _symbolController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currency?.name);
    _codeController = TextEditingController(text: widget.currency?.code);
    _symbolController = TextEditingController(text: widget.currency?.symbol);
    _isDefault = widget.currency?.isDefault ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.currency == null ? 'Add Currency' : 'Edit Currency'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. US Dollar'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code', hintText: 'e.g. USD'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _symbolController,
                decoration: const InputDecoration(labelText: 'Symbol', hintText: r'e.g. $'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              SwitchListTile(title: const Text('Default Currency'), value: _isDefault, onChanged: (v) => setState(() => _isDefault = v)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final data = {'name': _nameController.text, 'code': _codeController.text, 'symbol': _symbolController.text, 'is_default': _isDefault};
              if (widget.currency == null) {
                ref.read(adminCurrencyProvider.notifier).createCurrency(data);
              } else {
                ref.read(adminCurrencyProvider.notifier).updateCurrency(widget.currency!.id, data);
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
