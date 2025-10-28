import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/core/helpers/responsive_extensions.dart';
import 'package:tuya_app/src/core/helpers/spacing_extensions.dart';
import 'package:tuya_app/src/features/auth/presentation/manager/cubit/auth_cubit.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthCubitState>(
      builder: (context, authState) {
        if (authState is AuthCubitAuthenticated) {
          return _buildMeScreen(context, authState.user);
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildMeScreen(BuildContext context, user) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            20.height,

            // Profile Section
            _buildProfileSection(context, user),

            40.height,

            // Menu Items
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, user) {
    return Column(
      children: [
        // Profile Picture
        Container(
          width: context.isMobile ? 80 : 100,
          height: context.isMobile ? 80 : 100,
          decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
          child: Icon(Icons.person, size: context.isMobile ? 40 : 50, color: Colors.grey.shade600),
        ),

        16.height,

        // Name
        Text(
          user.name ?? 'User',
          style: TextStyle(fontSize: context.isMobile ? 20 : 24, fontWeight: FontWeight.w600, color: Colors.green),
        ),

        8.height,

        // Email
        Text(
          user.email ?? 'user@example.com',
          style: TextStyle(fontSize: context.isMobile ? 14 : 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isMobile ? 20 : context.responsivePadding.horizontal),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'General',
            onTap: () {
              // §TODO: Navigate to general settings
            },
          ),
          _buildDivider(),

          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'About Zero Tech',
            onTap: () {
              // TODO: Navigate to about screen
            },
          ),
          _buildDivider(),

          _buildMenuItem(
            context,
            icon: Icons.security,
            title: 'Privacy and Security',
            onTap: () {
              // TODO: Navigate to privacy screen
            },
          ),
          _buildDivider(),

          _buildMenuItem(
            context,
            icon: Icons.verified_user,
            title: 'Terms & Conditions',
            onTap: () {
              // TODO: Navigate to terms screen
            },
          ),
          _buildDivider(),

          _buildMenuItem(context, icon: Icons.logout, title: 'Logout', onTap: () => _showLogoutDialog(context), isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.isMobile ? 16 : 20),
        child: Row(
          children: [
            Icon(icon, size: context.isMobile ? 24 : 28, color: isLogout ? Colors.red : Colors.grey.shade700),

            16.width,

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: context.isMobile ? 16 : 18,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.red : Colors.grey.shade700,
                ),
              ),
            ),

            Icon(Icons.chevron_right, size: context.isMobile ? 24 : 28, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade200, thickness: 1);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Logout',
            style: TextStyle(fontSize: context.responsiveFontMultiplier * 20, fontWeight: FontWeight.w600),
          ),
          content: Text('Are you sure you want to logout?', style: TextStyle(fontSize: context.responsiveFontMultiplier * 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: context.responsiveFontMultiplier * 16, color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().logout();
              },
              child: Text(
                'Logout',
                style: TextStyle(fontSize: context.responsiveFontMultiplier * 16, color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
