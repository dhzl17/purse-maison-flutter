import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  static const _fadeInDuration = Duration(milliseconds: 800);

  static const _dismissThreshold = 120.0;
 
  static const _flingVelocityThreshold = 600.0;

  bool _visible = false;
  bool _navigating = false;


  double _dragOffset = 0;

  late final AnimationController _snapController;
  late final AnimationController _hintController;
  late final Animation<double> _hintOffset;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });


    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _hintOffset = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_navigating) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(
        -MediaQuery.of(context).size.height,
        0.0,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_navigating) return;

    final flungUp =
        details.velocity.pixelsPerSecond.dy < -_flingVelocityThreshold;
    final draggedPastThreshold = _dragOffset < -_dismissThreshold;

    if (flungUp || draggedPastThreshold) {
      _commitSwipe();
    } else {
      _snapBack();
    }
  }

  void _commitSwipe() {
    setState(() => _navigating = true);
    final screenHeight = MediaQuery.of(context).size.height;

    _snapController.duration = const Duration(milliseconds: 300);
    final animation = Tween<double>(
      begin: _dragOffset,
      end: -screenHeight,
    ).animate(CurvedAnimation(parent: _snapController, curve: Curves.easeIn));

    void listener() {
      setState(() => _dragOffset = animation.value);
    }

    animation.addListener(listener);
    _snapController.forward(from: 0).whenComplete(() {
      animation.removeListener(listener);
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  void _snapBack() {
    _snapController.duration = const Duration(milliseconds: 250);
    final animation = Tween<double>(
      begin: _dragOffset,
      end: 0,
    ).animate(CurvedAnimation(parent: _snapController, curve: Curves.easeOut));

    void listener() {
      setState(() => _dragOffset = animation.value);
    }

    animation.addListener(listener);
    _snapController.forward(from: 0).whenComplete(() {
      animation.removeListener(listener);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dragProgress = (-_dragOffset / screenHeight).clamp(0.0, 1.0);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF203A8F), Color(0xFF29479D), Color(0xFF3052AE)],
            ),
          ),
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: Opacity(
              opacity: 1.0 - dragProgress,
              child: Stack(
                children: [
                  Center(
                    child: AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: _fadeInDuration,
                      curve: Curves.easeOut,
                      child: AnimatedScale(
                        scale: _visible ? 1.0 : 0.95,
                        duration: _fadeInDuration,
                        curve: Curves.easeOut,
                        child: Image.asset(
                          'assets/images/LOGO_PURSE_MAISON-removebg-preview.png',
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 48,
                    child: AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: _fadeInDuration,
                      child: AnimatedBuilder(
                        animation: _hintOffset,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _hintOffset.value),
                            child: child,
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 32,
                            ),
                            Text(
                              'Swipe up',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
