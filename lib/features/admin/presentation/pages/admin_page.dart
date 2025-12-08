import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/core/utils/user_preferences.dart';
import 'package:kiosk/features/admin/presentation/pages/admin_products_page.dart';
import 'package:kiosk/features/admin/presentation/pages/admin_sales_page.dart';
import 'package:kiosk/features/admin/presentation/pages/admin_orders_page.dart';
import 'package:kiosk/features/auth/presentation/pages/login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminProductsPage(),
    const AdminSalesPage(),
    const AdminOrdersPage(),
  ];

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
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
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.brandBrown,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _handleLogout(context);
                    },
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Admin Panel',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      _handleLogout(context);
                    },
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _pages[_selectedIndex],
            ),
            // Bottom Navigation
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                selectedItemColor: AppColors.brandBrown,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2),
                    label: 'Products',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics),
                    label: 'Sales',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long),
                    label: 'Orders',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

