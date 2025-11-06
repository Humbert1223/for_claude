import 'package:flutter/material.dart';

  class MyTextField extends StatelessWidget{
    final TextEditingController controller;
    final String hintText;
    final bool obscureText;
    final Widget? suffixIcon;
    final Widget? prefixIcon;
    const MyTextField({
      super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      this.suffixIcon,
      this.prefixIcon,
    });

    @override
    Widget build(BuildContext context){
      return TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          suffixIcon: suffixIcon??const SizedBox(),
          prefixIcon: prefixIcon??const SizedBox(),
          hintText: hintText,
        ),
      );

    }
  }