import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nexa_store/features/auth/providers/add_app_provider.dart';

class AddAppPage extends ConsumerStatefulWidget {
  const AddAppPage({super.key});

  @override
  ConsumerState<AddAppPage> createState() => _AddAppPageState();
}

class _AddAppPageState extends ConsumerState<AddAppPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _versionController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  File? _selectedIcon;
  File? _selectedApk;

  // 🟢 علم لمنع فتح المنتقي مرتين
  bool _isPicking = false;

  final List<String> _categories = [
    'Tools',
    'Utilities',
    'Games',
    'Education',
    'Social'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    // إذا كان المنتقي مفتوحاً بالفعل، لا تفعل شيئاً
    if (_isPicking) return;
    _isPicking = true;

    FilePickerResult? result;

    try {
      if (type == 'icon') {
        result = await FilePicker.platform.pickFiles(type: FileType.image);
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['apk'],
        );
      }

      if (result != null && result.files.single.path != null) {
        setState(() {
          if (type == 'icon') {
            _selectedIcon = File(result!.files.single.path!);
          } else {
            _selectedApk = File(result!.files.single.path!);
          }
        });
      }
    } catch (e) {
      // يمكنك التعامل مع الخطأ هنا إذا أردت
      print('Error picking file: $e');
    } finally {
      // تأكد من إعادة العلم إلى false بعد انتهاء العملية
      _isPicking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addAppProvider);
    final notifier = ref.read(addAppProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New App')),
      body: state.isSuccess
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 20),
                  const Text('App uploaded successfully!'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      notifier.reset();
                      _formKey.currentState?.reset();
                      setState(() {
                        _selectedIcon = null;
                        _selectedApk = null;
                      });
                    },
                    child: const Text('Add Another App'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'App Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _versionController,
                      decoration: const InputDecoration(
                          labelText: 'Version (e.g. 1.0.0)'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories
                          .map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _selectedIcon != null
                              ? Image.file(_selectedIcon!, height: 60)
                              : const Text('No icon selected'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () => _pickFile('icon'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(_selectedApk != null
                              ? 'APK: ${_selectedApk!.path.split('/').last}'
                              : 'No APK selected'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.folder_open),
                          onPressed: () => _pickFile('apk'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (state.error != null)
                      Text(state.error!,
                          style: const TextStyle(color: Colors.red)),
                    if (state.isLoading)
                      Column(
                        children: [
                          LinearProgressIndicator(value: state.uploadProgress),
                          const SizedBox(height: 8),
                          const Text(
                              'Uploading... (Large files may take time)'),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                _selectedIcon != null &&
                                _selectedApk != null) {
                              notifier.uploadApp(
                                name: _nameController.text,
                                version: _versionController.text,
                                description: _descriptionController.text,
                                category: _selectedCategory!,
                                iconFile: _selectedIcon!,
                                apkFile: _selectedApk!,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please fill all fields and select files.')),
                              );
                            }
                          },
                          child: const Text('Upload App'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
