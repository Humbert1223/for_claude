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
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutCubic),
    );
    _elevationAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutCubic),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = widget.color ?? theme.colorScheme.primary;

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
          children: [
            _buildModernIconContainer(context, effectiveColor, isDark),
            const SizedBox(height: 10),
            _buildModernTitle(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModernIconContainer(
      BuildContext context,
      Color effectiveColor,
      bool isDark,
      ) {
    final size = MediaQuery.of(context).size.width * 0.18;

    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Container principal avec design moderne
            Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [
                    effectiveColor.withValues(alpha: 0.25),
                    effectiveColor.withValues(alpha: 0.15),
                  ]
                      : [
                    effectiveColor.withValues(alpha: 0.12),
                    effectiveColor.withValues(alpha: 0.06),
                  ],
                ),
                border: Border.all(
                  color: _isPressed
                      ? effectiveColor.withValues(alpha: 0.4)
                      : effectiveColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: effectiveColor.withValues(
                      alpha: _isPressed ? 0.25 : 0.15 * _elevationAnimation.value,
                    ),
                    blurRadius: _isPressed ? 8 : 16,
                    offset: Offset(0, _isPressed ? 2 : 6),
                    spreadRadius: 0,
                  ),
                  if (!_isPressed)
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Stack(
                  children: [
                    // Effet de brillance subtil en haut à droite
                    Positioned(
                      top: -size * 0.15,
                      right: -size * 0.15,
                      child: Container(
                        width: size * 0.6,
                        height: size * 0.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: isDark ? 0.08 : 0.25),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Icône/Image avec padding
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(size * 0.2),
                        child: widget.image,
                      ),
                    ),
                    // Overlay subtil lors du press
                    if (_isPressed)
                      Container(
                        decoration: BoxDecoration(
                          color: effectiveColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(19),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Badge "NEW" moderne
            if (widget.isNew)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.deepOrange.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      height: 1,
                    ),
                  ),
                ),
              ),

            // Badge de notification moderne
            if (widget.badgeCount != null && widget.badgeCount! > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade500,
                        Colors.red.shade700,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      widget.badgeCount! > 99 ? '99+' : '${widget.badgeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildModernTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        widget.title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.3,
          color: theme.colorScheme.onSurface,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}