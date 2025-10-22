import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasePopUpDialog extends StatelessWidget {
  final String question;
  final String yesText;
  final String noText;
  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;
  final bool autoPopOnPressed;

  const BasePopUpDialog({
    super.key,
    required this.question,
    required this.yesText,
    required this.noText,
    required this.onYesPressed,
    required this.onNoPressed,
    this.autoPopOnPressed = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titlePadding: EdgeInsets.only(top: 20.w),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),

      title: Center(
        child: Text(
          "Konfirmasi",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
        ),
      ),

      content: Text(
        question,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
      ),

      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        SizedBox(
          height: 38.w,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              foregroundColor: Colors.grey.shade600,
              textStyle: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              onNoPressed();
              if (autoPopOnPressed) {
                Navigator.of(context).pop();
              }
            },
            child: Text(noText),
          ),
        ),
        SizedBox(
          height: 38.w,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              foregroundColor: Colors.white,
              textStyle: TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              onYesPressed();
              Navigator.of(context).pop();
            },
            child: Text(yesText),
          ),
        ),
      ],
    );
  }
}
