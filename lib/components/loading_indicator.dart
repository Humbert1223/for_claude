import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator extends StatelessWidget {
  final double? size;
  final LoadingIndicatorType? type;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size,
    this.type,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingIndicatorType.progressiveDots:
        return Center(
          child: LoadingAnimationWidget.progressiveDots(
            color: color ?? Theme.of(context).colorScheme.primary,
            size: size ?? 40,
          ),
        );
      case LoadingIndicatorType.staggeredDotsWave:
        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: color ?? Theme.of(context).colorScheme.primary,
            size: size ?? 40,
          ),
        );
      case LoadingIndicatorType.inkDrop:
        return Center(
          child: LoadingAnimationWidget.inkDrop(
            color: color ?? Theme.of(context).colorScheme.primary,
            size: size ?? 40,
          ),
        );
      case LoadingIndicatorType.discreteCircle:
        return Center(
          child: LoadingAnimationWidget.discreteCircle(
            color: color ?? Theme.of(context).colorScheme.primary,
            size: size ?? 40,
          ),
        );
      case LoadingIndicatorType.waveDot:
        return Center(
          child: LoadingAnimationWidget.waveDots(
            color: color ?? Theme.of(context).colorScheme.primary,
            size: size ?? 40,
          ),
        );
      default:
        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: color ?? Theme.of(context).colorScheme.primary,
            size: size ?? 40,
          ),
        );
    }
  }
}

enum LoadingIndicatorType {
  discreteCircle,
  progressiveDots,
  staggeredDotsWave,
  inkDrop,
  waveDot,
}
