import 'package:tuya_app/src/core/utils/app_imports.dart';

class RememberPasswordCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RememberPasswordCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<RememberPasswordCheckbox> createState() => _RememberPasswordCheckboxState();
}

class _RememberPasswordCheckboxState extends State<RememberPasswordCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => widget.onChanged(!widget.value),
          child: Container(
            width: context.isMobile ? 20 : 24,
            height: context.isMobile ? 20 : 24,
            decoration: BoxDecoration(
              color: widget.value ? const Color(0xFF00C851) : Colors.transparent,
              border: Border.all(
                color: widget.value ? const Color(0xFF00C851) : const Color(0xFFCCCCCC),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(context.isMobile ? 4 : 6),
            ),
            child: widget.value
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: context.isMobile ? 14 : 16,
                  )
                : null,
          ),
        ),
        
        SizedBox(width: context.isMobile ? 8 : 12),
        
        Text(
          'Remember Password',
          style: TextStyle(
            fontSize: context.isMobile ? 14 : 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
