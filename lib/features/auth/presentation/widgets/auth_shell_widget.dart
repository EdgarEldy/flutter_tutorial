// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/app/theme/app_theme.dart';

/// Shared layout shell for authentication screens.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-28
/// Project: flutter_tutorial
class AuthShellWidget extends StatelessWidget {
  const AuthShellWidget({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    this.heroHeight = 200,
    this.showLogo = false,
    this.showBackButton = false,
    this.onBack,
  });

  final Widget child;
  final String title;
  final String subtitle;
  final double heroHeight;
  final bool showLogo;
  final bool showBackButton;
  final VoidCallback? onBack;

  static const _heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(2.792),
    colors: [Color(0xFF7C3AED), Color(0xFF6750A4), Color(0xFF4A3580)],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: LayoutBuilder(
              builder: (context, constraints) {
                const overlap = 28.0;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: heroHeight,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: _heroGradient,
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              16,
                              24,
                              showLogo ? 48 : 40,
                            ),
                            child: showLogo
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: const Color(0x2DFFFFFF),
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          border: Border.all(
                                            color: const Color(0x4DFFFFFF),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _HeroText(
                                        title: title,
                                        subtitle: subtitle,
                                        titleSize: 28,
                                        subtitleSize: 14,
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (showBackButton)
                                        _GlassBackButton(onTap: onBack),
                                      const Spacer(),
                                      _HeroText(
                                        title: title,
                                        subtitle: subtitle,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: heroHeight - overlap,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: ColoredBox(
                          color: colorScheme.surface,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    constraints.maxHeight -
                                    heroHeight +
                                    overlap -
                                    64,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.title,
    required this.subtitle,
    this.titleSize = 26,
    this.subtitleSize = 13,
  });

  final String title;
  final String subtitle;
  final double titleSize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xA6FFFFFF),
            fontSize: subtitleSize,
          ),
        ),
      ],
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    );
  }
}
