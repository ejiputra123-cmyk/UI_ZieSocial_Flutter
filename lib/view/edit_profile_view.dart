// ziesocial/flutter/ziesocial/lib/view/edit_profile_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/model/user_model.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/viewmodel/post_viewmodel.dart';
import 'package:ziesocial/viewmodel/profile_viewmodel.dart';
import 'package:ziesocial/widget/app_button.dart';
import 'package:ziesocial/widget/app_text_field.dart';

class EditProfileView extends StatefulWidget {
  final UserModel user;

  const EditProfileView({super.key, required this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedAvatar;

  static const primaryColor = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;

    final file = File(image.path);
    final fileSize = await file.length();

    if (fileSize > 5 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ukuran foto maksimal 5MB')));
      return;
    }

    final extension = image.path.split('.').last.toLowerCase();
    if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya format JPG, JPEG, atau PNG yang diperbolehkan'),
        ),
      );
      return;
    }

    setState(() {
      _selectedAvatar = image;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Username tidak boleh kosong.')),
      );
      return;
    }

    final userId = int.tryParse(widget.user.id);
    if (userId == null) return;

    final profileVM = context.read<ProfileViewModel>();
    final updatedUser = await profileVM.updateProfile(
      userId: userId,
      name: name,
      username: username,
      avatarFilePath: _selectedAvatar?.path,
    );

    if (!mounted) return;

    if (updatedUser != null) {
      // Update user di LoginViewModel & refresh feed di PostViewModel
      context.read<LoginViewModel>().updateUser(updatedUser);
      context.read<PostViewModel>().fetchPosts(currentUserId: userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } else {
      final errorMsg = profileVM.errorMessage ?? 'Gagal memperbarui profil.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = context.watch<ProfileViewModel>().isUpdating;
    final currentAvatarUrl = ApiConstants.getImageUrl(widget.user.avatar);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bagian Edit Foto Profil
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: const Color(0xFFE5E7EB),
                            backgroundImage: _selectedAvatar != null
                                ? FileImage(File(_selectedAvatar!.path))
                                      as ImageProvider
                                : NetworkImage(currentAvatarUrl),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),
                    TextButton(
                      onPressed: _pickAvatar,
                      child: const Text(
                        'Ganti Foto Profil',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(24),

              // Input Nama Lengkap
              const Text(
                'Nama Lengkap',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
              const Gap(8),
              AppTextField(
                controller: _nameController,
                labelText: '',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF6B7280),
                ),
                backgroundColor: const Color(0xFFF9FAFB),
                borderColor: const Color(0xFFE5E7EB),
                borderRadius: 12,
              ),

              const Gap(16),

              // Input Username
              const Text(
                'Username',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
              const Gap(8),
              AppTextField(
                controller: _usernameController,
                labelText: '',
                hintText: 'Masukkan username',
                prefixIcon: const Icon(
                  Icons.alternate_email,
                  color: Color(0xFF6B7280),
                ),
                backgroundColor: const Color(0xFFF9FAFB),
                borderColor: const Color(0xFFE5E7EB),
                borderRadius: 12,
              ),

              const Gap(32),

              AppButton(
                text: 'Simpan Perubahan',
                isLoading: isUpdating,
                onPressed: _saveProfile,
                backgroundColor: primaryColor,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
