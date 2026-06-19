import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:ripple/widgets/custom_text.dart';

class SnackBarHelper {
  static void showSnackBar(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          spacing: 7,
          children: [
            Expanded(child: CustomText(text: title)),
            Expanded(child: CustomText(text: message)),
          ],
        ),

        backgroundColor: Colors.grey,
      ),
    );
  }
}
