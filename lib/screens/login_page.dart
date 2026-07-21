import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/app_session.dart';


const _kPrimaryBlue = Color(0xFF1F2F7A);
const _kBackground = Color(0xFFEEF4FB);
const _kTextColor = Color(0xFF111827);
const _kHintColor = Color(0xFF8A8A8A);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSubmitting = false;
  String? _loginError;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
        );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin(BuildContext context) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _loginError = null;
    });

    final error = await AppSession.instance.authenticate(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSubmitting = false;
        _loginError = error;
      });
      return;
    }

    setState(() => _isSubmitting = false);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/LOGO_PURSE_MAISON-removebg-preview.png',
                          width: 140,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 32),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _kTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _AnimatedLoginField(
                          controller: _usernameController,
                          hint: 'Username',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _AnimatedLoginField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: _kHintColor,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              InkWell(
                                onTap: () =>
                                    setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (v) => setState(
                                          () => _rememberMe = v ?? false,
                                        ),
                                        activeColor: _kPrimaryBlue,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Remember Me',
                                      style: TextStyle(
                                        color: _kTextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Password reset coming soon'),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: _kPrimaryBlue,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_loginError != null) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _loginError!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        _HoverScaleButton(
                          isLoading: _isSubmitting,
                          onPressed: () => _submitLogin(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined text field whose border animates to the primary blue when
/// focused (AnimatedContainer per the spec), instead of the default
/// abrupt Material focus outline.
class _AnimatedLoginField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;

  const _AnimatedLoginField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  State<_AnimatedLoginField> createState() => _AnimatedLoginFieldState();
}

class _AnimatedLoginFieldState extends State<_AnimatedLoginField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _focused
              ? _kPrimaryBlue
              : _kPrimaryBlue.withValues(alpha: 0.4),
          width: _focused ? 1.6 : 1.0,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        style: const TextStyle(fontSize: 18, color: _kTextColor),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: _kHintColor, fontSize: 16),
          prefixIcon: Icon(widget.icon, color: _kPrimaryBlue),
          suffixIcon: widget.suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}

/// The login submit button. Wrapped in a MouseRegion so desktop/web users
/// get a subtle scale-up on hover, in addition to the Material ripple that
/// ElevatedButton already provides on press.
class _HoverScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _HoverScaleButton({required this.onPressed, this.isLoading = false});

  @override
  State<_HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 220,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _kPrimaryBlue.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: _hovering ? 4 : 0,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Log in',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}
