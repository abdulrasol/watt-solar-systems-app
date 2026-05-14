import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_city.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_country.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_address_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminAddressScreen extends ConsumerStatefulWidget {
  const AdminAddressScreen({super.key});

  @override
  ConsumerState<AdminAddressScreen> createState() => _AdminAddressScreenState();
}

class _AdminAddressScreenState extends ConsumerState<AdminAddressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _cityScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(adminAddressProvider.notifier).fetchCountries();
      ref.read(adminAddressProvider.notifier).fetchCities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cityScrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      child: Column(
        children: [
          _buildHeader(),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Countries'),
              Tab(text: 'Cities'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCountriesTab(),
                _buildCitiesTab(),
              ],
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
                  'Addresses',
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                ),
                Text(
                  'Manage Countries and Cities',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(),
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

  void _showAddDialog() {
    if (_tabController.index == 0) {
      showDialog(context: context, builder: (context) => const _CountryDialog());
    } else {
      showDialog(context: context, builder: (context) => const _CityDialog());
    }
  }

  Widget _buildCountriesTab() {
    final state = ref.watch(adminAddressProvider);
    if (state.isCountriesLoading) return const AdminLoadingState();
    if (state.countries.isEmpty) {
      return const AdminEmptyState(icon: Iconsax.global_bold, title: 'No Countries');
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: state.countries.length,
      itemBuilder: (context, index) => _CountryCard(country: state.countries[index]),
    );
  }

  Widget _buildCitiesTab() {
    final state = ref.watch(adminAddressProvider);
    if (state.isCitiesLoading) return const AdminLoadingState();
    if (state.cities.isEmpty) {
      return const AdminEmptyState(icon: Iconsax.building_bold, title: 'No Cities');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminAddressProvider.notifier).fetchCities(),
      child: ListView.builder(
        controller: _cityScrollController,
        padding: EdgeInsets.all(20.w),
        itemCount: state.cities.length,
        itemBuilder: (context, index) {
          return _CityCard(city: state.cities[index]);
        },
      ),
    );
  }
}

class _CountryCard extends ConsumerWidget {
  final AdminCountry country;
  const _CountryCard({required this.country});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: const Icon(Iconsax.global_bold),
        title: Text(country.name),
        subtitle: Text(country.code),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => showDialog(context: context, builder: (context) => _CountryDialog(country: country)),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Country'),
        content: Text('Are you sure you want to delete ${country.name}? This may affect cities associated with it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminAddressProvider.notifier).deleteCountry(country.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CityCard extends ConsumerWidget {
  final AdminCity city;
  const _CityCard({required this.city});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: const Icon(Iconsax.building_bold),
        title: Text(city.name),
        subtitle: Text('${city.country.name} (${city.code})'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => showDialog(context: context, builder: (context) => _CityDialog(city: city)),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete City'),
        content: Text('Are you sure you want to delete ${city.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminAddressProvider.notifier).deleteCity(city.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CountryDialog extends ConsumerStatefulWidget {
  final AdminCountry? country;
  const _CountryDialog({this.country});

  @override
  ConsumerState<_CountryDialog> createState() => _CountryDialogState();
}

class _CountryDialogState extends ConsumerState<_CountryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.country?.name);
    _codeController = TextEditingController(text: widget.country?.code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.country == null ? 'Add Country' : 'Edit Country'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code (e.g. US)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final data = {'name': _nameController.text, 'code': _codeController.text};
              if (widget.country == null) {
                ref.read(adminAddressProvider.notifier).createCountry(data);
              } else {
                ref.read(adminAddressProvider.notifier).updateCountry(widget.country!.id, data);
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

class _CityDialog extends ConsumerStatefulWidget {
  final AdminCity? city;
  const _CityDialog({this.city});

  @override
  ConsumerState<_CityDialog> createState() => _CityDialogState();
}

class _CityDialogState extends ConsumerState<_CityDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  int? _selectedCountryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.city?.name);
    _codeController = TextEditingController(text: widget.city?.code);
    _selectedCountryId = widget.city?.country.id;
  }

  @override
  Widget build(BuildContext context) {
    final countries = ref.watch(adminAddressProvider).countries;

    return AlertDialog(
      title: Text(widget.city == null ? 'Add City' : 'Edit City'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _selectedCountryId,
              decoration: const InputDecoration(labelText: 'Country'),
              items: countries.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedCountryId = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'City Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                'code': _codeController.text,
                'country_id': _selectedCountryId,
              };
              if (widget.city == null) {
                ref.read(adminAddressProvider.notifier).createCity(data);
              } else {
                ref.read(adminAddressProvider.notifier).updateCity(widget.city!.id, data);
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
