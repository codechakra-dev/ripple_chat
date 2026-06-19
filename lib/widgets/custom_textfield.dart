import 'package:flutter/material.dart';
import 'package:ripple/core/constants/app_strings.dart';

// class CustomTextField extends StatefulWidget {
//   final TextEditingController controller;
//    bool? isObscureText;
//   final Widget? suffixIcon;
//    CustomTextField({super.key, required this.controller, this.isObscureText, this.suffixIcon});
//
//   @override
//   State<CustomTextField> createState() => _CustomTextFieldState();
// }
//
// class _CustomTextFieldState extends State<CustomTextField> {
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: widget.controller,
//       obscureText: widget.isObscureText ?? false,
//       decoration: InputDecoration(
//         labelText: 'Password',
//         prefixIcon: const Icon(Icons.lock_outlined),
//         suffixIcon: widget.suffixIcon,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
// }

class CustomTextField extends StatelessWidget {

  final TextEditingController controller;
  final bool isObscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String labelText;
  final TextInputType? keyboardInputType;

  const CustomTextField(
      {super.key, required this.controller, required this.isObscureText, this.suffixIcon, this.prefixIcon, required this.labelText, this.keyboardInputType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isObscureText,
      keyboardType: keyboardInputType,
      decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        fontFamily: AppStrings.poppins
      ),

      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),);
  }
}

