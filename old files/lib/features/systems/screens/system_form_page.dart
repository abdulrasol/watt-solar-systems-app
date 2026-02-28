import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/core/di/get_it.dart';
import '../../../../../lib/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/features/systems/controllers/systems_controller.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';
import 'package:solar_hub/features/compnay/controllers/auth_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/utils/toast_service.dart';

class SystemFormPage extends StatefulWidget {
  final SystemModel? system;
  final bool isUserView; // True if user is adding, false if company
  final String? companyId; // If company adding

  const SystemFormPage({super.key, this.system, this.isUserView = true, this.companyId});

  @override
  State<SystemFormPage> createState() => _SystemFormPageState();
}

class _SystemFormPageState extends State<SystemFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.put(SystemsController());
  // final _toast = ToastService(); // For potential non-static usage though show is static

  // Controllers
  late TextEditingController _userPhoneCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _cityCtrl;

  // Company Selection (User View)
  String? _selectedCompanyId;
  String? _selectedUserId;
  String? _selectedUserPhone;
  final TextEditingController _companySearchCtrl = TextEditingController();

  // PV
  late TextEditingController _pvCountCtrl;
  late TextEditingController _pvCapCtrl;
  late TextEditingController _pvMarkCtrl;

  // Battery
  late TextEditingController _battCountCtrl;
  late TextEditingController _battCapCtrl;
  late TextEditingController _battMarkCtrl;

  // Inverter
  late TextEditingController _invCountCtrl;
  late TextEditingController _invCapCtrl;
  late TextEditingController _invMarkCtrl;

  @override
  void initState() {
    super.initState();
    final system = widget.system;

    _userPhoneCtrl = TextEditingController(text: system?.userPhone ?? (widget.isUserView ? getIt<AuthController>().user.value?.phone : ''));
    _notesCtrl = TextEditingController(text: system?.notes ?? '');
    _cityCtrl = TextEditingController(text: system?.city ?? '');

    _selectedCompanyId = system?.installedBy ?? widget.companyId;
    _selectedUserId = system?.userId; // Initialize selected user ID
    _selectedUserPhone = system?.userPhone;

    // If we have a user ID but no display info, fetch it to show name
    if (_selectedUserId != null && !widget.isUserView) {
      if (system?.userPhone == null) {
        // Fetch
        _controller.getUser(_selectedUserId!).then((user) {
          if (user != null && mounted) {
            setState(() {
              _userPhoneCtrl.text = "${user['full_name']} (${user['phone_number']})";
              _selectedUserPhone = user['phone_number'];
            });
          }
        });
      } else {
        // If we have phone, assume we might not have name, but let's try to fetch name just in case or just show phone
        // Optimistically set text if possible, or fetch
        _userPhoneCtrl.text = system!.userPhone!;
        // Better to fetch to get full name for display
        _controller.getUser(_selectedUserId!).then((user) {
          if (user != null && mounted) {
            setState(() {
              _userPhoneCtrl.text = "${user['full_name']} (${user['phone_number']})";
            });
          }
        });
      }
    }

    if (_selectedCompanyId != null && widget.isUserView) {
      _controller.fetchCompanyById(_selectedCompanyId!).then((company) {
        if (company != null && mounted) {
          setState(() {
            _companySearchCtrl.text = company.name;
          });
        } else {
          _companySearchCtrl.text = "Company ID: $_selectedCompanyId";
        }
      });
    }

    _pvCountCtrl = TextEditingController(text: system?.pv.count.toString() ?? '0');
    _pvCapCtrl = TextEditingController(text: system?.pv.capacity.toString() ?? '0');
    _pvMarkCtrl = TextEditingController(text: system?.pv.mark ?? '');

    _battCountCtrl = TextEditingController(text: system?.battery.count.toString() ?? '0');
    _battCapCtrl = TextEditingController(text: system?.battery.capacity.toString() ?? '0');
    _battMarkCtrl = TextEditingController(text: system?.battery.mark ?? '');

    _invCountCtrl = TextEditingController(text: system?.inverter.count.toString() ?? '0');
    _invCapCtrl = TextEditingController(text: system?.inverter.capacity.toString() ?? '0');
    _invMarkCtrl = TextEditingController(text: system?.inverter.mark ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.system == null ? "Add System" : "Edit System")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIdentitySection(),
              const SizedBox(height: 16),

              _buildSectionHeader("PV Panels"),
              Row(
                children: [
                  Expanded(child: _buildNumField(_pvCountCtrl, "Count")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildNumField(_pvCapCtrl, "Watts/Panel")),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pvMarkCtrl,
                decoration: const InputDecoration(labelText: "Brand/Mark"),
              ),

              const SizedBox(height: 16),
              _buildSectionHeader("Batteries"),
              Row(
                children: [
                  Expanded(child: _buildNumField(_battCountCtrl, "Count")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildNumField(_battCapCtrl, "Capacity (Ah/kWh)")),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _battMarkCtrl,
                decoration: const InputDecoration(labelText: "Brand/Mark"),
              ),

              const SizedBox(height: 16),
              _buildSectionHeader("Inverter"),
              Row(
                children: [
                  Expanded(child: _buildNumField(_invCountCtrl, "Count")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildNumField(_invCapCtrl, "Capacity (kVA)")),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _invMarkCtrl,
                decoration: const InputDecoration(labelText: "Brand/Mark"),
              ),

              const SizedBox(height: 24),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: "City", prefixIcon: Icon(Icons.location_city)),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: "Notes"),
                maxLines: 3,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: _save, child: const Text("Save System")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildIdentitySection() {
    // If User View: Show Company Selector
    if (widget.isUserView) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _companySearchCtrl,
            readOnly: true,
            onTap: _showCompanySearchDialog,
            decoration: const InputDecoration(
              labelText: "Installed By (Company)",
              hintText: "Tap to search company",
              prefixIcon: Icon(Icons.business),
              suffixIcon: Icon(Icons.search),
              border: OutlineInputBorder(), // Explicit border to match user screenshot style expectation
            ),
          ),
          if (_selectedCompanyId != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 4),
              child: Text("Status: Pending Approval", style: TextStyle(color: Colors.orange, fontSize: 12)),
            ),
        ],
      );
    }

    // If Company View: Show User Search Input
    return Column(
      children: [
        TextFormField(
          controller: _userPhoneCtrl, // Reusing this controller for display name "userSearchCtrl"
          readOnly: true,
          onTap: _showUserSearchDialog,
          decoration: const InputDecoration(
            labelText: "Link to User",
            hintText: "Tap to search by name/phone",
            helperText: "Search registered users",
            prefixIcon: Icon(Icons.person_search),
            border: OutlineInputBorder(),
          ),
          validator: (v) => _selectedUserId == null ? "Required to link user" : null,
        ),
      ],
    );
  }

  Widget _buildNumField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }

  void _showCompanySearchDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _CompanySearchSheet(
        onSelect: (id, name) {
          setState(() {
            _selectedCompanyId = id;
            _companySearchCtrl.text = name;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final pv = SystemComponent(count: int.tryParse(_pvCountCtrl.text) ?? 0, capacity: double.tryParse(_pvCapCtrl.text) ?? 0, mark: _pvMarkCtrl.text);
    final batt = SystemComponent(count: int.tryParse(_battCountCtrl.text) ?? 0, capacity: double.tryParse(_battCapCtrl.text) ?? 0, mark: _battMarkCtrl.text);
    final inv = SystemComponent(count: int.tryParse(_invCountCtrl.text) ?? 0, capacity: double.tryParse(_invCapCtrl.text) ?? 0, mark: _invMarkCtrl.text);

    // Status Logic
    String uStatus = widget.system?.userStatus ?? 'pending';
    String cStatus = widget.system?.companyStatus ?? 'pending';
    String? installedBy = widget.system?.installedBy ?? (widget.isUserView ? _selectedCompanyId : widget.companyId);

    if (widget.isUserView) {
      // User Adding
      if (installedBy == null) {
        // Self-install
        uStatus = 'accepted';
        cStatus = 'pending';
      } else {
        // Linked to company -> waiting for company
        uStatus = 'accepted';
        cStatus = 'pending';
      }
    } else {
      // Company Adding
      cStatus = 'accepted';
      // Waiting for user to confirm
      uStatus = 'pending';
    }

    // If Company Adding, use selected user
    String? userIdToSave = widget.isUserView ? getIt<AuthController>().user.value?.id.toString() : _selectedUserId;
    String? userPhoneToSave;

    if (widget.isUserView) {
      userPhoneToSave = getIt<AuthController>().user.value?.phone;
    } else {
      // Ideally we just save userId, but if we want to save phone as fallback in 'user' column:
      // We can iterate _userSearchCtrl.text or store it separately.
      // For now let's assume 'user' column is legacy and we primarily rely on 'user_id'.
      // But keeping 'user' populated is good for viewing from raw DB or debugging.
      // We can extract it from the search result if we stored it, or just leave it null/empty if not critical.
      // OR: we can get it from the selected user map (need to store it).
      // Let's assume we don't have phone easily unless we store 'selectedUserPhone'.
      // I'll add a 'selectedUserPhone' var to state.
      userPhoneToSave = _selectedUserPhone;
    }

    final newSystem = SystemModel(
      id: widget.system?.id,
      userId: userIdToSave,
      userPhone: userPhoneToSave,
      installedBy: installedBy,
      pv: pv,
      battery: batt,
      inverter: inv,
      city: _cityCtrl.text,
      notes: _notesCtrl.text,
      userStatus: uStatus,
      companyStatus: cStatus,
      installedAt: widget.system?.installedAt ?? DateTime.now(),
      createdAt: widget.system?.createdAt ?? DateTime.now(),
    );

    bool result = false;
    if (newSystem.id == null) {
      if (widget.isUserView && userIdToSave != null) {
        if (getIt<AuthController>().isSigned.value == false) {
          ToastService.warning("Profile Incomplete", "Please complete your profile details first to add a system.");
          return;
        }
      }
      result = await _controller.createSystem(newSystem);
    } else {
      result = await _controller.updateSystem(newSystem);
    }

    if (result) {
      Get.back(result: true);
    } else {
      // result is handled in controller for create, but maybe not update?
      // controller.updateSystem also returns false on error.
      // Leave general error if needed, but controller usually toasts now.
    }
  }

  void _showUserSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _UserSearchSheet(
        onSelect: (id, name, phone) {
          setState(() {
            _selectedUserId = id;
            _selectedUserPhone = phone;
            _userPhoneCtrl.text = "$name ($phone)";
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _UserSearchSheet extends StatefulWidget {
  final Function(String id, String name, String? phone) onSelect;
  const _UserSearchSheet({required this.onSelect});

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final List<Map<String, dynamic>> _results = [];
  final _controller = Get.find<SystemsController>();
  final _textController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  bool _isValidPhone(String phone) {
    // Basic validation - just check if it contains digits and is reasonable length
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return cleanPhone.length >= 7;
  }

  void _search(String query) async {
    setState(() {
      _errorMessage = null;
      _results.clear();
    });

    if (!_isValidPhone(query)) {
      setState(() => _errorMessage = "Please enter a valid phone number");
      return;
    }

    setState(() => _loading = true);
    final res = await _controller.searchUsers(query);
    if (mounted) {
      setState(() {
        _results.clear();
        _results.addAll(res);
        _loading = false;
        if (res.isEmpty) {
          _errorMessage = "No user found with this phone number";
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      height: 600,
      child: Column(
        children: [
          Text("Select User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 10),
          TextField(
            controller: _textController,
            autofocus: true,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "Enter phone number and press Enter...",
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: _errorMessage,
            ),
            onSubmitted: (val) {
              if (val.isNotEmpty) _search(val);
            },
          ),
          SizedBox(height: 10),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? Center(child: Text(_errorMessage ?? "Enter a phone number and press Enter to search"))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) {
                      final u = _results[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (u['avatar_url'] != null && u['avatar_url'].toString().isNotEmpty)
                              ? CachedNetworkImageProvider(u['avatar_url'])
                              : null,
                          child: (u['avatar_url'] == null || u['avatar_url'].toString().isEmpty) ? Text((u['full_name'] ?? 'U')[0].toUpperCase()) : null,
                        ),
                        title: Text(u['full_name'] ?? 'Unknown'),
                        subtitle: Text(u['email'] ?? ''),
                        onTap: () => widget.onSelect(u['id'], u['full_name'] ?? 'Unknown', u['phone_number']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CompanySearchSheet extends StatefulWidget {
  final Function(String id, String name) onSelect;
  const _CompanySearchSheet({required this.onSelect});

  @override
  State<_CompanySearchSheet> createState() => _CompanySearchSheetState();
}

class _CompanySearchSheetState extends State<_CompanySearchSheet> {
  final List<Map<String, dynamic>> _results = [];
  final _controller = Get.find<SystemsController>();
  bool _loading = false;

  void _search(String query) async {
    setState(() => _loading = true);
    final res = await _controller.searchCompanies(query);
    if (mounted) {
      setState(() {
        _results.clear();
        _results.addAll(res);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 500,
      child: Column(
        children: [
          Text("Select Company", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              hintText: "Search company...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              if (val.length > 2) _search(val);
            },
          ),
          SizedBox(height: 10),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) {
                      final c = _results[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(c['name'][0])),
                        title: Text(c['name']),
                        onTap: () => widget.onSelect(c['id'], c['name']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
