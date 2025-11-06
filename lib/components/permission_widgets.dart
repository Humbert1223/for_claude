import 'package:flutter/material.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Widget qui affiche son enfant uniquement si l'utilisateur a la permission
class PermissionGuard extends StatelessWidget {
  final String? permission;
  final List<String>? anyOf;
  final List<String>? allOf;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PermissionGuard({
    super.key,
    this.permission,
    this.anyOf,
    this.allOf,
    required this.child,
    this.fallback,
    this.showFallback = true,
  });

  @override
  Widget build(BuildContext context) {

    return Consumer<AuthProvider>(builder: (context, auth, child){
      bool hasAccess = _checkPermission(auth);

      if (hasAccess) {
        return this.child;
      } else {
        if(!showFallback){
          return SizedBox.shrink();
        }
        return fallback != null
            ? fallback!
            : Opacity(
          opacity: 0.3,
          child: Tooltip(
            message:
            'Vous n\'avez pas la permission d\'accéder à cette fonctionnalité',
            child: IgnorePointer(child: this.child),
          ),
        );
      }
    });
  }

  bool _checkPermission(AuthProvider controller) {
    if (permission != null) {
      return controller.hasPermission(permission!);
    } else if (anyOf != null) {
      return controller.hasAny(anyOf!);
    } else if (allOf != null) {
      return controller.hasAll(allOf!);
    }
    return false;
  }
}

/// Widget qui masque son enfant si l'utilisateur n'a pas la permission
class HideIfNoPermission extends StatelessWidget {
  final String permission;
  final Widget child;

  const HideIfNoPermission({
    super.key,
    required this.permission,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permission: permission,
      showFallback: false,
      child: child,
    );
  }
}

/// Widget qui désactive son enfant si l'utilisateur n'a pas la permission
class DisableIfNoPermission extends StatelessWidget {
  final String permission;
  final Widget child;
  final String? tooltip;

  const DisableIfNoPermission({
    super.key,
    required this.permission,
    required this.child,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {

    return Consumer<AuthProvider>(builder: (context, auth, child) {
      final hasPermission = auth.hasPermission(permission);

      Widget disabledChild = Opacity(
        opacity: 0.3,
        child: IgnorePointer(child: this.child),
      );

      if (tooltip != null && !hasPermission) {
        disabledChild = Tooltip(message: tooltip!, child: disabledChild);
      }

      return hasPermission ? this.child : disabledChild;
    });
  }
}

/// Builder qui fournit l'état de la permission
class PermissionBuilder extends StatelessWidget {
  final String? permission;
  final List<String>? anyOf;
  final List<String>? allOf;
  final Widget Function(BuildContext context, bool hasPermission) builder;

  const PermissionBuilder({
    super.key,
    this.permission,
    this.anyOf,
    this.allOf,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, child) {
      bool hasAccess = false;

      if (permission != null) {
        hasAccess = auth.hasPermission(permission!);
      } else if (anyOf != null) {
        hasAccess = auth.hasAny(anyOf!);
      } else if (allOf != null) {
        hasAccess = auth.hasAll(allOf!);
      }

      return builder(context, hasAccess);
    });
  }
}

/// Mixin pour faciliter la vérification des permissions dans les widgets
mixin PermissionMixin {

  bool hasPermission(String permission) {
    return authProvider.hasPermission(permission);
  }

  bool hasAny(List<String> permissions) {
    return authProvider.hasAny(permissions);
  }

  bool hasAll(List<String> permissions) {
    return authProvider.hasAll(permissions);
  }

  bool isAccountType(String type) {
    return authProvider.isAccountType(type);
  }
}

/// Extension pour faciliter l'accès aux permissions depuis n'importe où
extension PermissionExtension on BuildContext {
  bool hasPermission(String permission) {
    return authProvider.hasPermission(permission);
  }

  bool hasAny(List<String> permissions) {
    return authProvider.hasAny(permissions);
  }

  bool hasAll(List<String> permissions) {
    return authProvider.hasAll(permissions);
  }
}

/// Widget pour afficher un message d'erreur de permission
class NoPermissionWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onContactAdmin;

  const NoPermissionWidget({super.key, this.message, this.onContactAdmin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message ??
                  'Vous n\'avez pas la permission d\'accéder à cette fonctionnalité',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (onContactAdmin != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onContactAdmin,
                icon: const Icon(Icons.email),
                label: const Text('Contacter l\'administrateur'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
