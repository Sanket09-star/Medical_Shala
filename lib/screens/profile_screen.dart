import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _specialization = '';
  String _hospitalName = '';
  // Password fields are handled by controllers
  File? _profileImage;
  String _avatarUrl = '';
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Text editing controllers for better form control
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  late TextEditingController _hospitalNameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchProfile();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _specializationController = TextEditingController();
    _hospitalNameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _hospitalNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        
        setState(() {
          _fullName = data?['fullName'] ?? '';
          _email = data?['email'] ?? user.email ?? '';
          _phone = data?['phone'] ?? '';
          _specialization = data?['specialization'] ?? '';
          _hospitalName = data?['hospitalname'] ?? '';
          _avatarUrl = data?['avatarUrl'] ?? '';
          _isLoading = false;
        });

        // Update controllers
        _fullNameController.text = _fullName;
        _emailController.text = _email;
        _phoneController.text = _phone;
        _specializationController.text = _specialization;
        _hospitalNameController.text = _hospitalName;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Prepare data to save
        final userData = {
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'specialization': _specializationController.text.trim(),
          'hospitalname': _hospitalNameController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Handle password update if provided
        if (_passwordController.text.isNotEmpty) {
          if (_passwordController.text != _confirmPasswordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Passwords do not match!')),
            );
            setState(() {
              _isSaving = false;
            });
            return;
          }
          
          // Update password in Firebase Auth
          await user.updatePassword(_passwordController.text);
          userData['password'] = _passwordController.text; // Store hashed version
        }

        // Check if document exists, if not create it
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final doc = await docRef.get();
        
        if (doc.exists) {
          await docRef.update(userData);
        } else {
          userData['createdAt'] = FieldValue.serverTimestamp();
          await docRef.set(userData);
        }

        // Update local state
        setState(() {
          _fullName = _fullNameController.text.trim();
          _email = _emailController.text.trim();
          _phone = _phoneController.text.trim();
          _specialization = _specializationController.text.trim();
          _hospitalName = _hospitalNameController.text.trim();
          _isEditing = false;
          _isSaving = false;
        });

        // Clear password fields
        _passwordController.clear();
        _confirmPasswordController.clear();

        // Refresh provider
        ref.invalidate(userProfileProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    
    setState(() {
      _isPickingImage = true;
    });

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        await _uploadAvatar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  Future<void> _uploadAvatar() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');
        await storageRef.putFile(_profileImage!);
        final url = await storageRef.getDownloadURL();
        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'avatarUrl': url,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        setState(() {
          _avatarUrl = url;
        });
        
        ref.invalidate(userProfileProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    // Reset controllers to original values
    _fullNameController.text = _fullName;
    _emailController.text = _email;
    _phoneController.text = _phone;
    _specializationController.text = _specialization;
    _hospitalNameController.text = _hospitalName;
    _passwordController.clear();
    _confirmPasswordController.clear();
    
    setState(() {
      _isEditing = false;
      _profileImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _isEditing ? _buildEditForm() : _buildProfileView(),
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Photo Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (_avatarUrl.isNotEmpty
                        ? NetworkImage(_avatarUrl)
                        : const NetworkImage('https://img.freepik.com/free-icon/user_318-159711.jpg')) as ImageProvider,
                backgroundColor: AppColors.surface,
              ),
              const SizedBox(height: 16),
              Text(
                _fullName.isNotEmpty ? _fullName : 'No Name Set',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (_specialization.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _specialization,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (_hospitalName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _hospitalName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Profile Information Cards
        _buildInfoCard(
          title: 'Contact Information',
          children: [
            _buildInfoRow('Email', _email.isNotEmpty ? _email : 'Not set', Icons.email),
            _buildInfoRow('Phone', _phone.isNotEmpty ? _phone : 'Not set', Icons.phone),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildInfoCard(
          title: 'Professional Information',
          children: [
            _buildInfoRow('Specialization', _specialization.isNotEmpty ? _specialization : 'Not set', Icons.medical_services),
            _buildInfoRow('Hospital/Clinic', _hospitalName.isNotEmpty ? _hospitalName : 'Not set', Icons.local_hospital),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Action Buttons
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            child: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: Text(
              'Log Out',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Profile Photo Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_avatarUrl.isNotEmpty
                              ? NetworkImage(_avatarUrl)
                              : const NetworkImage('https://img.freepik.com/free-icon/user_318-159711.jpg')) as ImageProvider,
                      backgroundColor: AppColors.surface,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _isPickingImage ? null : _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: _isPickingImage
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to change photo',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Personal Information
          _buildFormSection(
            title: 'Personal Information',
            children: [
              _buildFormField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Professional Information
          _buildFormSection(
            title: 'Professional Information',
            children: [
              _buildFormField(
                controller: _specializationController,
                label: 'Specialization',
                icon: Icons.medical_services,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your specialization';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _hospitalNameController,
                label: 'Hospital/Clinic Name',
                icon: Icons.local_hospital,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your hospital/clinic name';
                  }
                  return null;
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Password Section
          _buildFormSection(
            title: 'Change Password (Optional)',
            children: [
              _buildFormField(
                controller: _passwordController,
                label: 'New Password',
                icon: Icons.lock,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (_passwordController.text.isNotEmpty && value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.primary),
                  ),
                  onPressed: _isSaving ? null : _cancelEdit,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFormSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textSecondary,
        ),
      ),
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
    );
  }
} 