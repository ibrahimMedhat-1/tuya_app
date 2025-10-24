import 'package:tuya_app/src/core/utils/app_imports.dart';

class ModernTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool enabled;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const ModernTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.enabled = true,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: context.isMobile ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        
        SizedBox(height: context.isMobile ? 8 : 12),
        
        // Text Field
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? _obscureText : false,
            enabled: widget.enabled,
            validator: widget.validator,
            onChanged: widget.onChanged,
            style: TextStyle(
              fontSize: context.isMobile ? 16 : 18,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: context.isMobile ? 16 : 18,
                color: const Color(0xFF999999),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.isMobile ? 12 : 16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.isMobile ? 12 : 16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.isMobile ? 12 : 16),
                borderSide: BorderSide(
                  color: _isFocused ? const Color(0xFF00C851) : Colors.transparent,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.isMobile ? 12 : 16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.isMobile ? 12 : 16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 16 : 20,
                vertical: context.isMobile ? 16 : 20,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF666666),
                        size: context.isMobile ? 20 : 24,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
