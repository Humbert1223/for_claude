import 'package:flutter/material.dart';

// ============================================================================
// BOUTON DE JEU MODERNE (QuizGameButton amélioré)
// ============================================================================
class ModernGameButton extends StatefulWidget {
  final Widget? child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final bool isEnabled;
  final IconData? icon;

  const ModernGameButton({
    super.key,
    this.child,
    required this.onPressed,
    this.backgroundColor,
    this.isEnabled = true,
    this.icon,
  });

  @override
  State<ModernGameButton> createState() => _ModernGameButtonState();
}

class _ModernGameButtonState extends State<ModernGameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.primary;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isEnabled
                  ? [
                bgColor,
                bgColor.withValues(alpha: 0.8),
              ]
                  : [
                Colors.grey.shade400,
                Colors.grey.shade500,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? bgColor.withValues(alpha: 0.3)
                    : bgColor.withValues(alpha: 0.4),
                blurRadius: _isPressed ? 8 : 16,
                offset: Offset(0, _isPressed ? 2 : 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Effet de brillance
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Contenu
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 3,
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CARTE DE SÉLECTION MODERNE (pour disciplines, niveaux, séries)
// ============================================================================
class ModernSelectionCard extends StatefulWidget {
  final String title;
  final String? imageUrl;
  final AssetImage? assetImage;
  final VoidCallback onTap;
  final Color? overlayColor;

  const ModernSelectionCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.assetImage,
    required this.onTap,
    this.overlayColor,
  });

  @override
  State<ModernSelectionCard> createState() => _ModernSelectionCardState();
}

class _ModernSelectionCardState extends State<ModernSelectionCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: _isPressed ? 8 : 12,
                offset: Offset(0, _isPressed ? 2 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image de fond
                if (widget.imageUrl != null)
                  Image.network(
                    widget.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      );
                    },
                  )
                else if (widget.assetImage != null)
                  Image(
                    image: widget.assetImage!,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
                // Overlay avec dégradé
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        (widget.overlayColor ?? Colors.black)
                            .withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Effet de press
                if (_isPressed)
                  Container(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                // Bordure animée
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isPressed
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                ),
                // Titre
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CARTE DE SCORE MODERNE (Game Over)
// ============================================================================
class ModernScoreCard extends StatelessWidget {
  final int score;
  final int total;
  final double rating;
  final VoidCallback onPlayAgain;
  final VoidCallback onQuit;

  const ModernScoreCard({
    super.key,
    required this.score,
    required this.total,
    required this.rating,
    required this.onPlayAgain,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total * 100).round();
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge de performance
            _buildPerformanceBadge(percentage, theme),
            const SizedBox(height: 24),
            // Étoiles
            _buildStarRating(rating),
            const SizedBox(height: 24),
            // Score
            Text(
              'SCORE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    height: 1,
                  ),
                ),
                Text(
                  ' / $total',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.close,
                    label: 'Quitter',
                    color: Colors.red,
                    onTap: onQuit,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.refresh,
                    label: 'Rejouer',
                    color: theme.colorScheme.primary,
                    onTap: onPlayAgain,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBadge(int percentage, ThemeData theme) {
    String message;
    Color color;
    IconData icon;

    if (percentage >= 90) {
      message = 'EXCELLENT !';
      color = Colors.amber;
      icon = Icons.emoji_events;
    } else if (percentage >= 70) {
      message = 'TRÈS BIEN !';
      color = Colors.green;
      icon = Icons.thumb_up;
    } else if (percentage >= 50) {
      message = 'BIEN !';
      color = Colors.blue;
      icon = Icons.check_circle;
    } else {
      message = 'CONTINUE !';
      color = Colors.orange;
      icon = Icons.psychology;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            starValue <= rating
                ? Icons.star
                : (starValue - 0.5 <= rating
                ? Icons.star_half
                : Icons.star_border),
            color: Colors.amber,
            size: 36,
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CARTE UTILISATEUR MODERNE
// ============================================================================
class ModernUserCard extends StatelessWidget {
  final String userName;
  final int gamesCount;
  final int achievementsCount;
  final VoidCallback? onChangeUser;

  const ModernUserCard({
    super.key,
    required this.userName,
    required this.gamesCount,
    this.achievementsCount = 0,
    this.onChangeUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Avatar avec bordure
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info utilisateur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.gamepad,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$gamesCount ${gamesCount <= 1 ? "partie" : "parties"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Badge succès
            if (achievementsCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$achievementsCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            // Bouton changer
            if (onChangeUser != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onChangeUser,
                icon: const Icon(Icons.swap_horiz, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BOUTON FLOATING MODERNE
// ============================================================================
class ModernFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;

  const ModernFloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      child: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.primary,
        size: 24,
      ),
    );
  }
}