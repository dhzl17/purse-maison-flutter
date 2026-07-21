import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LandingBreakpoints {
  LandingBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
}

class LandingNavBar extends StatelessWidget {
  final bool isMobile;
  final double horizontalPadding;
  final VoidCallback onLoginTap;
  final VoidCallback? onHomeTap;

  final String activeLabel;

  const LandingNavBar({
    super.key,
    required this.isMobile,
    required this.horizontalPadding,
    required this.onLoginTap,
    this.onHomeTap,
    this.activeLabel = 'HOME',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldUseCompactLayout = isMobile || constraints.maxWidth < 540;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LandingLogo(),
              if (!shouldUseCompactLayout)
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _NavItem(
                      label: 'HOME',
                      active: activeLabel == 'HOME',
                      onTap: onHomeTap ?? () {},
                    ),
                    _NavItem(
                      label: 'ABOUT US',
                      active: activeLabel == 'ABOUT US',
                      onTap: () {},
                    ),
                    _NavItem(
                      label: 'CONTACT',
                      active: activeLabel == 'CONTACT',
                      onTap: () {},
                    ),
                    _NavItem(
                      label: 'LOG IN',
                      active: activeLabel == 'LOG IN',
                      onTap: onLoginTap,
                    ),
                  ],
                )
              else
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: AppColors.sidebarBg,
                      size: 28,
                    ),
                    onPressed: () => _showMobileMenu(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panelBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _MobileMenuItem(
                label: 'HOME',
                onTap: () => Navigator.pop(context),
              ),
              _MobileMenuItem(
                label: 'ABOUT US',
                onTap: () => Navigator.pop(context),
              ),
              _MobileMenuItem(
                label: 'CONTACT',
                onTap: () => Navigator.pop(context),
              ),
              _MobileMenuItem(
                label: 'LOG IN',
                onTap: () {
                  Navigator.pop(context);
                  onLoginTap();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _MobileMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MobileMenuItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.sidebarBg,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.sidebarBg,
              fontSize: 13,
              letterSpacing: 1.2,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (active)
            Container(height: 2, width: 36, color: AppColors.sidebarBg),
        ],
      ),
    );
  }
}

class LandingLogo extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const LandingLogo({
    super.key,
    this.assetPath = 'assets/images/LOGO_PURSE_MAISON-removebg-preview.png',
    this.width = 100,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        errorBuilder: (context, error, stackTrace) =>
            _LogoPlaceholder(width: width, height: height),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _LogoPlaceholder({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.sidebarBg.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PURSE',
            style: TextStyle(
              color: AppColors.sidebarBg,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          Text(
            'MAISON',
            style: TextStyle(
              color: AppColors.sidebarBg.withValues(alpha: 0.75),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
            ),
          ),
        ],
      ),
    );
  }
}


class LandingGraphicPanel extends StatelessWidget {

  final Widget? overlay;

  const LandingGraphicPanel({super.key, this.overlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardNavyDark,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GlowArcsPainter(), child: Container()),
          ),
          if (overlay != null) Positioned.fill(child: overlay!),
        ],
      ),
    );
  }
}

class _GlowArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = AppColors.chartBlueDark);

    void drawGlowCircle(Offset center, double radius, List<Color> colors) {
      final gradient = RadialGradient(colors: colors, stops: const [0.0, 1.0]);
      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        );
      canvas.drawCircle(center, radius, paint);
    }

    drawGlowCircle(
      Offset(size.width * 0.2, size.height * 0.2),
      size.width * 1.1,
      [AppColors.chartBlueLight.withValues(alpha: 0.5), Colors.transparent],
    );
    drawGlowCircle(
      Offset(size.width * 0.8, size.height * 0.55),
      size.width * 0.9,
      [AppColors.chartBlueMed.withValues(alpha: 0.5), Colors.transparent],
    );
    drawGlowCircle(
      Offset(size.width * 0.3, size.height * 0.85),
      size.width * 0.8,
      [AppColors.chartBlueMed.withValues(alpha: 0.35), Colors.transparent],
    );

    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5),
        size.width * 0.3 * i,
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LandingDiagonalStripes extends StatelessWidget {
  const LandingDiagonalStripes({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DiagonalStripesPainter(), child: Container());
  }
}

class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderLight.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    const stripeWidth = 80.0;
    final diagonalOffset = size.height;

    for (
      double x = -diagonalOffset;
      x < size.width + diagonalOffset;
      x += stripeWidth * 2
    ) {
      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x + stripeWidth, 0);
      path.lineTo(x + stripeWidth - diagonalOffset, size.height);
      path.lineTo(x - diagonalOffset, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
