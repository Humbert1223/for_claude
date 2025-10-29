import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  final double? size;
  final Widget? sub;
  final Widget? icon;

  const EmptyPage({super.key, this.size, this.sub, this.icon});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ??
                Icon(
                  Icons.hourglass_empty_rounded,
                  size: size ?? 50,
                  color: Colors.grey[300],
                ),
            sub != null
                ? Container(child: sub)
                : const Text(
                  'Aucun élément',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                )
          ],
        ));
  }
}
