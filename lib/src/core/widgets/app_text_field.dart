import 'package:tuya_app/src/core/utils/app_imports.dart';

/// A reusable text field widget with customizable styling
class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final VoidCallback? onSuffixIconTap;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 12,
    this.contentPadding,
    this.labelStyle,
    this.hintStyle,
    this.onSuffixIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
        ),
        8.height,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius!),
            border: Border.all(color: borderColor ?? const Color(0xFFE5E7EB)),
            color: fillColor ?? const Color(0xFFF9FAFB),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            enabled: enabled,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  hintStyle ?? TextStyle(color: Colors.grey[400], fontSize: 16),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: Colors.grey[600], size: 20)
                  : null,
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixIconTap,
                      child: Icon(
                        suffixIcon,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              counterText: '', // Hide character counter
            ),
          ),
        ),
      ],
    );
  }
}
