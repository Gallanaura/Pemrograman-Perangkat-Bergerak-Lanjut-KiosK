import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/core/utils/user_preferences.dart';
import 'package:kiosk/features/auth/data/repositories/auth_repository.dart';
import 'package:kiosk/features/auth/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepository _authRepository = AuthRepository();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = await UserPreferences.getUserId();
    if (userId != null) {
      final user = await _authRepository.getUserById(userId);
      setState(() {
        _userData = user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.brandBrown,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            // Profile Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.brandBrown.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.brandBrown,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.brandBrown,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Profile Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          // Nama
                          _ProfileField(
                            icon: Icons.person_outline,
                            label: 'Nama',
                            value: _userData?['username'] ?? 'Guest',
                            onEdit: () => _showEditDialog('Nama', 'username', _userData?['username'] ?? ''),
                          ),
                          const Divider(height: 32),
                          // Email
                          _ProfileField(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: _userData?['email'] ?? '-',
                            onEdit: () => _showEditDialog('Email', 'email', _userData?['email'] ?? ''),
                          ),
                          const Divider(height: 32),
                          // Nomor HP
                          _ProfileField(
                            icon: Icons.phone_outlined,
                            label: 'Nomor HP',
                            value: _userData?['phone']?.toString().isEmpty ?? true 
                                ? '-' 
                                : _userData!['phone'],
                            onEdit: () => _showEditDialog('Nomor HP', 'phone', _userData?['phone'] ?? ''),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Logout',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(String fieldLabel, String fieldKey, String currentValue) async {
    final controller = TextEditingController(text: currentValue);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $fieldLabel'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: fieldLabel,
            border: const OutlineInputBorder(),
            hintText: 'Masukkan $fieldLabel',
          ),
          keyboardType: fieldKey == 'email' 
              ? TextInputType.emailAddress
              : fieldKey == 'phone'
                  ? TextInputType.phone
                  : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final userId = await UserPreferences.getUserId();
                if (userId != null) {
                  final updateData = <String, String>{};
                  updateData[fieldKey] = controller.text.trim();
                  
                  final success = await _authRepository.updateUser(
                    userId: userId,
                    username: fieldKey == 'username' ? controller.text.trim() : null,
                    email: fieldKey == 'email' ? controller.text.trim() : null,
                    phone: fieldKey == 'phone' ? controller.text.trim() : null,
                  );
                  
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    _loadUserData(); // Reload user data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$fieldLabel berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memperbarui $fieldLabel'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandBrown,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            FilledButton(
              onPressed: () async {
                // Close dialog first
                Navigator.pop(dialogContext);
                
                // Clear user session
                await UserPreferences.clearUser();
                
                // Wait a bit to ensure dialog is closed
                await Future.delayed(const Duration(milliseconds: 100));
                
                // Navigate to login page and remove all previous routes
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.brandBrown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.brandBrown,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.brandBrown,
            onPressed: onEdit,
            tooltip: 'Edit $label',
          ),
      ],
    );
  }
}

