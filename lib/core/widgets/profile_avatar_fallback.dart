import 'package:flutter/material.dart';

class ProfileAvatarFallback extends StatelessWidget {
  const ProfileAvatarFallback({
    this.size = 72,
    this.signedIn = false,
    super.key,
  });

  final double size;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.28),
            scheme.surfaceContainerHighest,
          ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      child: Icon(
        signedIn ? Icons.verified_user_outlined : Icons.person_outline_rounded,
        size: size * 0.42,
        color: scheme.primary,
      ),
    );
  }
}
