import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final Widget title;
  final Color? color;
  final EdgeInsets? padding;

  const TagWidget({
    super.key,
    required this.title,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: title,
    );
  }
}
