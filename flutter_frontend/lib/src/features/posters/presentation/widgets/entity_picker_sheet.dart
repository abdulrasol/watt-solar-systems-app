import 'dart:async';
import 'package:flutter/material.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/features/inventory/domain/entities/filter.dart';
import 'package:watt/src/features/inventory/domain/entities/product.dart';
import 'package:watt/src/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:watt/src/features/company_work/domain/entities/company_work.dart';
import 'package:watt/src/features/company_work/domain/repositories/company_work_repository.dart';

Future<PickerItem?> showProductPicker(BuildContext context, int companyId) {
  return showModalBottomSheet<PickerItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PickerSheetContent<Product>(
      title: AppLocalizations.of(context)!.products,
      fetch: (page, query) async {
        final repo = getIt<InventoryRepository>();
        final products = await repo.getProducts(
          companyId,
          filter: ProductsFilter(page: page, pageSize: 12, search: query),
        );
        return products;
      },
      itemName: (p) => p.name,
      itemSubtitle: (p) => '\$${p.displayPrice.toStringAsFixed(2)}',
      itemImage: (p) => p.images.isNotEmpty ? p.images.first : null,
      toItem: (p) => PickerItem(id: p.id, name: p.name),
    ),
  );
}

Future<PickerItem?> showWorkPicker(BuildContext context, int companyId) {
  return showModalBottomSheet<PickerItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PickerSheetContent<CompanyWork>(
      title: AppLocalizations.of(context)!.company_work_title,
      fetch: (page, query) async {
        final repo = getIt<CompanyWorkRepository>();
        final works = await repo.getCompanyWorks(companyId, page: page, pageSize: 12);
        return query == null || query.isEmpty
            ? works
            : works.where((w) => w.title.toLowerCase().contains(query.toLowerCase())).toList();
      },
      itemName: (w) => w.title,
      itemSubtitle: (_) => null,
      itemImage: (w) => w.coverImageUrl,
      toItem: (w) => PickerItem(id: w.id, name: w.title),
    ),
  );
}

class PickerItem {
  final int id;
  final String name;
  final String? subtitle;
  final String? imageUrl;

  const PickerItem({required this.id, required this.name, this.subtitle, this.imageUrl});
}

class _PickerSheetContent<T> extends StatefulWidget {
  final String title;
  final Future<List<T>> Function(int page, String? query) fetch;
  final String Function(T) itemName;
  final String? Function(T) itemSubtitle;
  final String? Function(T) itemImage;
  final PickerItem Function(T) toItem;

  const _PickerSheetContent({
    required this.title,
    required this.fetch,
    required this.itemName,
    required this.itemSubtitle,
    required this.itemImage,
    required this.toItem,
  });

  @override
  State<_PickerSheetContent<T>> createState() => _PickerSheetContentState<T>();
}

class _PickerSheetContentState<T> extends State<_PickerSheetContent<T>> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  List<T> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetch({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final items = await widget.fetch(_page, _query.isEmpty ? null : _query);
      setState(() {
        _items = refresh ? items : [..._items, ...items];
        _hasMore = items.length >= 12;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      setState(() => _isLoadingMore = true);
      _page++;
      _fetch();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _query = value.trim();
      _fetch(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title}',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildList(scrollController)),
          ],
        );
      },
    );
  }

  Widget _buildList(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(_error!, textAlign: TextAlign.center)));
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No ${widget.title.toLowerCase()} found', style: TextStyle(color: Colors.grey[600])),
          ]),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        if (i == _items.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        final item = _items[i];
        final imageUrl = widget.itemImage(item);
        return ListTile(
          leading: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, _, _) => _fallbackIcon()),
                )
              : _fallbackIcon(),
          title: Text(widget.itemName(item), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: widget.itemSubtitle(item) != null ? Text(widget.itemSubtitle(item)!, style: TextStyle(color: Colors.grey[600], fontSize: 13)) : null,
          onTap: () => Navigator.pop(context, widget.toItem(item)),
        );
      },
    );
  }

  Widget _fallbackIcon() {
    return Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.image, color: Colors.grey[400]));
  }
}
