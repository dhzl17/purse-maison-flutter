import 'package:flutter/material.dart';

/// Hamburger (mobile only) + "Main" section label + notification/info/
/// profile icon buttons. Identical on every screen — owned by AppShell.
class TopBar extends StatelessWidget {
  final bool showMenuButton;
  final VoidCallback onMenuTap;

  const TopBar({
    super.key,
    required this.showMenuButton,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuTap,
          tooltip: showMenuButton ? 'Toggle navigation menu' : 'Open navigation menu',
        ),
        const SizedBox(width: 4),
        const Text(
          'Main',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Icon(Icons.keyboard_arrow_down, size: 18),
        const Spacer(),
        _iconCircle(Icons.notifications_none),
        const SizedBox(width: 12),
        _iconCircle(Icons.info_outline),
        const SizedBox(width: 12),
        _iconCircle(Icons.account_circle),
      ],
    );
  }

  Widget _iconCircle(IconData icon) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.black87,
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}
