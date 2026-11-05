// ziesocial/flutter/ziesocial/lib/view/edit_post_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/model/post_model.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/viewmodel/post_viewmodel.dart';
import 'package:ziesocial/widget/app_button.dart';

class EditPostView extends StatefulWidget {
  final PostModel post;

  const EditPostView({super.key, required this.post});

  @override
  State<EditPostView> createState() => _EditPostViewState();
}

class _EditPostViewState extends State<EditPostView> {
  late TextEditingController _captionController;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;

    final file = File(image.path);
    final fileSize = await file.length();

    if (fileSize > 5 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ukuran gambar maksimal 5MB')),
      );
      return;
    }

    final extension = image.path.split('.').last.toLowerCase();
    if (extension != 'jpg' && extension != 'jpeg') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya gambar JPG/JPEG yang diperbolehkan'),
        ),
      );
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _updatePost() async {
    final currentUser = context.read<LoginViewModel>().user;
    if (currentUser == null) return;

    final userId = int.tryParse(currentUser.id);
    if (userId == null) return;

    final postViewModel = context.read<PostViewModel>();
    final success = await postViewModel.updatePost(
      postId: widget.post.id,
      userId: userId,
      caption: _captionController.text.trim(),
      newImagePath: _selectedImage?.path,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Postingan berhasil diperbarui.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    } else {
      final errorMsg =
          postViewModel.errorMessage ?? 'Gagal memperbarui postingan.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<PostViewModel>().isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Postingan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _selectedImage != null
                            ? Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.network(
                                widget.post.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                        Container(
                          color: Colors.black38,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                                color: Colors.white,
                              ),
                              Gap(6),
                              Text(
                                'Ketuk untuk mengubah foto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(16),
              TextField(
                controller: _captionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tulis caption...',
                  labelText: 'Caption',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(24),
              AppButton(
                text: 'Simpan Perubahan',
                isLoading: isSubmitting,
                onPressed: _updatePost,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
