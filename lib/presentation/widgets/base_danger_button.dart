import 'package:flutter/material.dart';

class BaseDangerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final double? width;

  const BaseDangerButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.width
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xffF32013),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 6),
              ],
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
