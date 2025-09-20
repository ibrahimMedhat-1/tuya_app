import 'package:tuya_app/src/core/utils/app_imports.dart';

/// A reusable button widget with customizable styling
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final List<Color>? gradientColors;
  final bool isEnabled;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.width,
    this.height = 56,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
    this.gradientColors,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = isEnabled && !isLoading && onPressed != null;

    return Container(
      width: width,
      height: height,
      decoration: _getDecoration(isButtonEnabled),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isButtonEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius!),
          child: Container(
            padding: padding ?? EdgeInsets.zero,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(isButtonEnabled),
                        ),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: _getTextColor(isButtonEnabled),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(bool isEnabled) {
    if (!isEnabled) {
      return BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius!),
      );
    }

    switch (type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: gradientColors != null
              ? LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(borderRadius!),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case ButtonType.secondary:
        return BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius!),
          border: Border.all(color: const Color(0xFF667eea), width: 2),
        );
      case ButtonType.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius!),
          border: Border.all(
            color: backgroundColor ?? const Color(0xFF667eea),
            width: 1,
          ),
        );
    }
  }

  Color _getTextColor(bool isEnabled) {
    if (!isEnabled) {
      return Colors.grey[600]!;
    }

    switch (type) {
      case ButtonType.primary:
        return textColor ?? Colors.white;
      case ButtonType.secondary:
        return textColor ?? const Color(0xFF667eea);
      case ButtonType.outline:
        return textColor ?? const Color(0xFF667eea);
    }
  }
}

enum ButtonType { primary, secondary, outline }
