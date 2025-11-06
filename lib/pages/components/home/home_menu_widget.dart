import 'package:flutter/material.dart';

class HomeMenuWidget extends StatefulWidget {
  final String title;
  final Widget image;
  final Color? color;
  final Function onTap;
  final IconData? icon;
  final int? badgeCount;
  final bool isNew;

  const HomeMenuWidget({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
    this.color,
    this.icon,
    this.badgeCount,
    this.isNew = false,
  });

  @override
  HomeMenuWidgetState createState() => HomeMenuWidgetState();
}

class HomeMenuWidgetState extends State<HomeMenuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () => widget.onTap(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppIcon(context),
            const SizedBox(height: 8),
            _buildAppLabel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.20;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Icône principale style Android
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.22), // ~22% de rayon pour style Android
            color: widget.color?.withValues(alpha: 0.1) ??
                theme.colorScheme.surfaceContainerLow,
            boxShadow: _isPressed
                ? []
                : [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 1 : 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.22),
            child: Stack(
              children: [
                // Image/Icône
                Center(
                  child: SizedBox(
                    width: size * 0.95,
                    height: size * 0.95,
                    child: widget.image,
                  ),
                ),
                // Overlay lors du press
                if (_isPressed)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(size * 0.22),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Badge de notification (style Android)
        if (widget.badgeCount != null && widget.badgeCount! > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                widget.badgeCount! > 99 ? '99+' : '${widget.badgeCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Badge "NEW" (style Android discret)
        if (widget.isNew)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAppLabel(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      child: Text(
        widget.title.toString().toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.87),
          height: 1.3,
          letterSpacing: 0.1
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}