import 'package:tuya_app/src/core/utils/app_imports.dart';

enum AuthTab { login, register }

class AuthTabs extends StatelessWidget {
  final AuthTab selectedTab;
  final ValueChanged<AuthTab> onTabChanged;

  const AuthTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.isMobile ? 48 : 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(context.isMobile ? 12 : 16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              'Login',
              AuthTab.login,
              selectedTab == AuthTab.login,
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              'Register',
              AuthTab.register,
              selectedTab == AuthTab.register,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    AuthTab tab,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onTabChanged(tab),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(context.isMobile ? 10 : 14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.isMobile ? 16 : 18,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.black : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }
}
