// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

/// Gradient hero banner used at the top of all auth screens.
/// [height] defaults to 200. Sign-in uses 300.
class AuthHeroWidget extends StatelessWidget {
  const AuthHeroWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.height = 200,
    this.showBackButton = false,
    this.showLogo = false,
  });

  final String title;
  final String subtitle;
  final double height;
  final bool showBackButton;
  final bool showLogo;

  // Brand gradient: 135deg, #7C3AED 0%, #6750A4 55%, #4A3580 100%
  static const _heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(2.356), // ~135 degrees
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF6750A4),
      Color(0xFF4A3580),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(gradient: _heroGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBackButton)
                _GlassButton(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              if (showLogo) ...[
                _LogoWidget(),
                const SizedBox(height: 16),
              ] else if (showBackButton)
                const SizedBox(height: 8)
              else
                const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xA6FFFFFF), // rgba(255,255,255,0.65)
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF), // rgba(255,255,255,0.15)
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0x33FFFFFF), // rgba(255,255,255,0.2)
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0x2DFFFFFF), // rgba(255,255,255,0.18)
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0x4DFFFFFF), // rgba(255,255,255,0.3)
        ),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.white,
        size: 36,
      ),
    );
  }
}
