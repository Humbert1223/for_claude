import 'package:flutter/material.dart';
import 'package:novacole/models/user_model.dart';

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
  HomeMenuWidgetState createState() {
    return HomeMenuWidgetState();
  }
}

class HomeMenuWidgetState extends State<HomeMenuWidget> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> filters = [];
  UserModel? user;

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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
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
    final effectiveColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () => widget.onTap(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIconContainer(context, effectiveColor),
            const SizedBox(height: 8),
            _buildTitle(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(BuildContext context, Color effectiveColor) {
    final size = MediaQuery.of(context).size.width * 0.20;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Container principal avec effet glassmorphism
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                effectiveColor.withValues(alpha:0.15),
                effectiveColor.withValues(alpha:0.05),
              ],
            ),
            border: Border.all(
              color: effectiveColor.withValues(alpha:0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha:_isPressed ? 0.3 : 0.15),
                blurRadius: _isPressed ? 12 : 20,
                offset: Offset(0, _isPressed ? 4 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Effet de brillance
                Positioned(
                  top: -size * 0.3,
                  right: -size * 0.3,
                  child: Container(
                    width: size * 0.8,
                    height: size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha:0.3),
                          Colors.white.withValues(alpha:0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Icône/Image
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: widget.image,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Badge "NEW"
        if (widget.isNew)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade500,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha:0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

        // Badge de notification (nombre)
        if (widget.badgeCount != null && widget.badgeCount! > 0)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(6),
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
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha:0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              child: Center(
                child: Text(
                  widget.badgeCount! > 99 ? '99+' : '${widget.badgeCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

        // Indicateur de pression (pulse effect)
        if (_isPressed)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: effectiveColor.withValues(alpha:0.1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        widget.title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          overflow: TextOverflow.ellipsis,
          letterSpacing: 0.5,
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
      ),
    );
  }

}