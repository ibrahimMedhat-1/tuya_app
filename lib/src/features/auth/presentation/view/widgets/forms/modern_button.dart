import 'package:tuya_app/src/core/utils/app_imports.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? Colors.black;
    final effectiveTextColor = textColor ?? Colors.white;
    final isButtonEnabled = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: context.isMobile ? 56 : 64,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled 
              ? effectiveBackgroundColor 
              : const Color(0xFFCCCCCC),
          foregroundColor: effectiveTextColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.isMobile ? 12 : 16),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.isMobile ? 16 : 20,
            vertical: context.isMobile ? 16 : 20,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: context.isMobile ? 20 : 24,
                height: context.isMobile ? 20 : 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: context.isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: isButtonEnabled ? effectiveTextColor : const Color(0xFF666666),
                ),
              ),
      ),
    );
  }
}
