import 'package:flutter/material.dart';

/// Modèle de données pour un élément de menu
class SubMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? badge;
  final bool isNew;

  const SubMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.badge,
    this.isNew = false,
  });
}

/// Widget de sous-menu moderne et réutilisable - Compatible dark mode
class SubMenuWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final Widget? badge;
  final bool isNew;
  final bool enabled;

  const SubMenuWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.badge,
    this.isNew = false,
    this.enabled = true,
  });

  @override
  State<SubMenuWidget> createState() => _SubMenuWidgetState();
}

class _SubMenuWidgetState extends State<SubMenuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Couleurs adaptatives selon le thème
    final effectiveIconColor = widget.iconColor ?? colorScheme.primary;
    final effectiveBackgroundColor = widget.backgroundColor ??
        (isDark ? colorScheme.primaryContainer : colorScheme.surface);

    // Couleurs de texte adaptatives
    final titleColor = widget.enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.4);

    final subtitleColor = widget.enabled
        ? (isDark
        ? colorScheme.onSurface.withValues(alpha: 0.7)
        : colorScheme.onSurface.withValues(alpha: 0.6))
        : colorScheme.onSurface.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: widget.enabled
                      ? [
                    BoxShadow(
                      color: effectiveIconColor.withValues(alpha: 0.08),
                      blurRadius: _isPressed ? 8 : 12,
                      offset: Offset(0, _isPressed ? 2 : 4),
                    ),
                  ]
                      : null,
                ),
                child: Card(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  color: isDark
                      ? effectiveBackgroundColor
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isDark
                          ? colorScheme.outline.withValues(alpha: 0.2)
                          : colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: GestureDetector(
                    onTapDown: _handleTapDown,
                    onTapUp: _handleTapUp,
                    onTapCancel: _handleTapCancel,
                    onTap: widget.enabled ? widget.onTap : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: !isDark && widget.enabled
                            ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            effectiveBackgroundColor,
                            effectiveBackgroundColor
                                .withValues(alpha: 0.95),
                          ],
                        )
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // Icône principale
                            _buildIconContainer(
                              effectiveIconColor,
                              isDark,
                            ),
                            const SizedBox(width: 16),
                            // Contenu texte
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: titleColor,
                                            letterSpacing: 0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (widget.isNew) ...[
                                        const SizedBox(width: 8),
                                        _buildNewBadge(),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subtitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subtitleColor,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Badge ou chevron
                            if (widget.badge != null)
                              widget.badge!
                            else
                              _buildChevronContainer(
                                effectiveIconColor,
                                isDark,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color iconColor, bool isDark) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 1, end: _isPressed ? 0.9 : 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              iconColor.withValues(alpha: isDark ? 0.2 : 0.15),
              iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: iconColor.withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1.5,
          ),
          boxShadow: widget.enabled
              ? [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Icon(
          widget.icon,
          color: iconColor,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildChevronContainer(Color iconColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: iconColor,
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
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
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}