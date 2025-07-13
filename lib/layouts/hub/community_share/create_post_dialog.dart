// --- New Widget for Create Post Dialog ---
import 'package:flutter/material.dart'
    show
        AlertDialog,
        BuildContext,
        Column,
        DropdownButtonFormField,
        DropdownMenuItem,
        ElevatedButton,
        Form,
        InputDecoration,
        MainAxisSize,
        OutlineInputBorder,
        SingleChildScrollView,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextButton,
        TextEditingController,
        TextField,
        Widget;
import 'package:get/get.dart'
    show ExtensionSnackbar, Get, GetNavigation, SnackPosition;

class CreatePostDialog extends StatefulWidget {
  final List<Map<String, dynamic>> userSystems;
  final Function(
    String title,
    String content,
    String type,
    Map<String, dynamic>? selectedSystem,
  )
  onCreatePost;

  const CreatePostDialog({
    super.key,
    required this.userSystems,
    required this.onCreatePost,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _postType = 'post'; // Default to 'post'
  Map<String, dynamic>? _selectedSystem;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Post"),
      content: SingleChildScrollView(
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _postType,
                decoration: const InputDecoration(
                  labelText: 'Post Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'post', child: Text('Post')),
                  DropdownMenuItem(value: 'issue', child: Text('Problem')),
                ],
                onChanged: (value) {
                  setState(() {
                    _postType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedSystem,
                hint: const Text('Select a System'),
                decoration: const InputDecoration(
                  labelText: 'System (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...widget.userSystems.map(
                    (system) => DropdownMenuItem(
                      value: system,
                      child: Text(
                        '${system['user_name']} - ${system['inverterBrand']} ${system['inverterSize']}kW',
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSystem = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _contentController.text.isNotEmpty) {
              widget.onCreatePost(
                _titleController.text,
                _contentController.text,
                _postType,
                _selectedSystem,
              );
            } else {
              Get.snackbar(
                'Error',
                'Please fill in both title and content.',
                snackPosition: SnackPosition.TOP,
              );
            }
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
