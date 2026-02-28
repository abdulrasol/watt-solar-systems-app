import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/community/controllers/community_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/utils/toast_service.dart';

class CreatePostSheet extends StatefulWidget {
  final List<Map<String, dynamic>>? userSystems;
  final Function(String content, String type, String? systemId)? onCreatePost;
  final String? initialSystemId;

  const CreatePostSheet({super.key, this.userSystems, this.onCreatePost, this.initialSystemId});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final CommunityController controller = Get.find<CommunityController>();
  final CompanyController companyController = Get.find<CompanyController>(); // Ensure this is loaded

  final _contentController = TextEditingController();
  String _postType = 'general'; // 'general' (Discussion) or 'issue' (Problem)
  String? _selectedSystemId;

  @override
  void initState() {
    super.initState();
    // Default system selection
    if (widget.initialSystemId != null) {
      _selectedSystemId = widget.initialSystemId;
    } else if (widget.userSystems != null && widget.userSystems!.isNotEmpty) {
      _selectedSystemId = widget.userSystems!.first['id'] as String?;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine height based on keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('create_post'.tr, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Post Type Selector
                  Text('write_something'.tr, style: Theme.of(context).textTheme.titleSmall), // "?What do you want to share"
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _TypeSelectionCard(
                          title: "Discussion", // Localize later if needed
                          icon: Iconsax.message_bold,
                          isSelected: _postType == 'general',
                          color: Colors.blue,
                          onTap: () => setState(() => _postType = 'general'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TypeSelectionCard(
                          title: "Problem / Issue", // Localize later
                          icon: Iconsax.warning_2_bold,
                          isSelected: _postType == 'issue',
                          color: Colors.red,
                          onTap: () => setState(() => _postType = 'issue'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Inputs
                  TextField(
                    controller: _contentController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Share your experience or ask a question...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Company Toggle (Only if user has company)
                  Obx(() {
                    if (companyController.company.value == null) return const SizedBox();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.store, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(child: Text('${'post_as'.tr} ${companyController.company.value?.name ?? "Company"}')),
                          Switch(
                            value: controller.postAsCompany.value,
                            activeThumbColor: Colors.blue,
                            onChanged: (val) => controller.postAsCompany.value = val,
                          ),
                        ],
                      ),
                    );
                  }),

                  // System Link
                  Obx(() {
                    final systemsList = widget.userSystems ?? controller.mySystems;
                    if (systemsList.isEmpty) return const SizedBox();

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.link, size: 16, color: Colors.blueGrey),
                              const SizedBox(width: 8),
                              Text(
                                "link_system_optional".tr,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSystemId,
                                hint: Text("select_your_system".tr, style: const TextStyle(fontSize: 14)),
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('none'.tr, style: const TextStyle(color: Colors.grey)),
                                  ),
                                  ...systemsList.map(
                                    (system) => DropdownMenuItem(
                                      value: system['id'] as String,
                                      child: Text(
                                        '${system['notes']?.toString().split('\n').first ?? 'System'} - ${system['pv']?['capacity'] ?? 0}kW',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) => setState(() => _selectedSystemId = value),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Image Picker Preview
                  Obx(() {
                    if (controller.selectedImages.isEmpty) return const SizedBox();
                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedImages.length,
                        itemBuilder: (ctx, i) {
                          // For web/checking implementation specifics, assuming local file path valid or bytes
                          // Since XFile, mostly handled.
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image), // Minimal preview for now or use Image.file
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              IconButton(
                onPressed: controller.pickImages,
                icon: const Icon(Icons.image, size: 28, color: Colors.green),
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isPosting.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: controller.isPosting.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('create_post'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_contentController.text.trim().isEmpty && controller.selectedImages.isEmpty) {
      ToastService.warning('Error', 'write_something'.tr);
      return;
    }
    if (widget.onCreatePost != null) {
      widget.onCreatePost!(_contentController.text, _postType, _selectedSystemId);
    } else {
      controller.createPost(_contentController.text, postType: _postType, systemId: _selectedSystemId);
    }
  }
}

class _TypeSelectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeSelectionCard({required this.title, required this.icon, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
