import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../services/app_session.dart';
import '../theme/app_colors.dart';
import '../widgets/app_shell.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _accountFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _emailController = TextEditingController();
  late final TextEditingController _roleController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _salesUpdates = true;
  bool _inventoryAlerts = true;
  bool _systemAnnouncements = true;

  @override
  void initState() {
    super.initState();
    final session = AppSession.instance;
    _nameController = TextEditingController(text: session.username ?? '');
    _roleController = TextEditingController(
      text: session.currentRole?.label ?? UserRole.salesAssociate.label,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (!_accountFormKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account settings saved.')),
    );
  }

  bool _isUpdatingPassword = false;

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isUpdatingPassword = true);
    try {
      // Firebase requires a recent sign-in before a sensitive change like
      // a password update, so we reauthenticate with the current password
      // first.
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);

      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? 'Current password is incorrect.'
          : 'Could not update password: ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isUpdatingPassword = false);
    }
  }

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 5,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(26, 10, 26, 14),
                      decoration: BoxDecoration(
                        color: AppColors.panelBackground,
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 25,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Manage your account, notifications, and security preferences.',
                            style: TextStyle(fontSize: 16, color: Color(0xFF57575E)),
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 850;
                              final account = _AccountSettingsCard(
                                formKey: _accountFormKey,
                                nameController: _nameController,
                                emailController: _emailController,
                                roleController: _roleController,
                                onSave: _saveAccount,
                              );
                              final security = _SecuritySettingsCard(
                                formKey: _passwordFormKey,
                                currentPasswordController: _currentPasswordController,
                                newPasswordController: _newPasswordController,
                                confirmPasswordController: _confirmPasswordController,
                                hideCurrentPassword: _hideCurrentPassword,
                                hideNewPassword: _hideNewPassword,
                                hideConfirmPassword: _hideConfirmPassword,
                                onToggleCurrent: () => setState(
                                  () => _hideCurrentPassword = !_hideCurrentPassword,
                                ),
                                onToggleNew: () => setState(
                                  () => _hideNewPassword = !_hideNewPassword,
                                ),
                                onToggleConfirm: () => setState(
                                  () => _hideConfirmPassword = !_hideConfirmPassword,
                                ),
                                onUpdate: _updatePassword,
                              );
                              return isWide
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: account),
                                        const SizedBox(width: 28),
                                        Expanded(child: security),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        account,
                                        const SizedBox(height: 18),
                                        security,
                                      ],
                                    );
                            },
                          ),
                          const SizedBox(height: 16),
                          _NotificationSettingsCard(
                            salesUpdates: _salesUpdates,
                            inventoryAlerts: _inventoryAlerts,
                            systemAnnouncements: _systemAnnouncements,
                            onSalesUpdatesChanged: (value) =>
                                setState(() => _salesUpdates = value),
                            onInventoryAlertsChanged: (value) =>
                                setState(() => _inventoryAlerts = value),
                            onSystemAnnouncementsChanged: (value) =>
                                setState(() => _systemAnnouncements = value),
                            onSave: _savePreferences,
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

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFC),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Color(0x11000000), blurRadius: 20, offset: Offset(0, 10)),
      ],
    ),
    child: child,
  );
}

class _CardHeading extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 31,
        height: 31,
        decoration: const BoxDecoration(color: AppColors.sidebarBg, shape: BoxShape.circle),
        child: Icon(icon, size: 19, color: Colors.white),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}

class _AccountSettingsCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController roleController;
  final VoidCallback onSave;

  const _AccountSettingsCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.roleController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => _SettingsCard(
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeading(icon: Icons.person, title: 'Account Settings'),
          const SizedBox(height: 22),
          _AccountField(label: 'Full Name', controller: nameController, hint: 'Enter full name'),
          const SizedBox(height: 17),
          _AccountField(
            label: 'Email Address',
            controller: emailController,
            hint: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty && !value.contains('@')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 17),
          _AccountField(label: 'Role', controller: roleController, hint: 'Enter role', readOnly: true),
          const SizedBox(height: 27),
          Align(
            alignment: Alignment.centerRight,
            child: _PrimaryButton(label: 'Save Changes', onPressed: onSave),
          ),
        ],
      ),
    ),
  );
}

class _AccountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;

  const _AccountField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked = constraints.maxWidth < 380;
      final input = SizedBox(
        width: stacked ? double.infinity : 300,
        child: _SettingsTextField(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
        ),
      );
      return stacked
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: _labelStyle), const SizedBox(height: 7), input])
          : Row(children: [SizedBox(width: 170, child: Text(label, style: _labelStyle)), Expanded(child: Align(alignment: Alignment.centerRight, child: input))]);
    },
  );
}

class _SecuritySettingsCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool hideCurrentPassword;
  final bool hideNewPassword;
  final bool hideConfirmPassword;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final VoidCallback onUpdate;

  const _SecuritySettingsCard({
    required this.formKey,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.hideCurrentPassword,
    required this.hideNewPassword,
    required this.hideConfirmPassword,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) => _SettingsCard(
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeading(icon: Icons.lock_outline, title: 'Security Settings'),
          const Padding(
            padding: EdgeInsets.only(left: 47, top: 7),
            child: Text('Change Password', style: TextStyle(fontSize: 16, color: Color(0xFF53535A))),
          ),
          const SizedBox(height: 9),
          const Divider(color: Color(0xFFE4E2DD)),
          const SizedBox(height: 7),
          _PasswordField(label: 'Current Password', controller: currentPasswordController, hidden: hideCurrentPassword, onVisibilityTap: onToggleCurrent),
          const SizedBox(height: 17),
          _PasswordField(label: 'New Password', controller: newPasswordController, hidden: hideNewPassword, onVisibilityTap: onToggleNew, validator: (value) => value != null && value.isNotEmpty && value.length < 8 ? 'Use at least 8 characters' : null),
          const SizedBox(height: 17),
          _PasswordField(label: 'Confirm New Password', controller: confirmPasswordController, hidden: hideConfirmPassword, onVisibilityTap: onToggleConfirm, validator: (value) {
            if (newPasswordController.text.isNotEmpty && value != newPasswordController.text) return 'Passwords do not match';
            return null;
          }),
          const SizedBox(height: 14),
          Align(alignment: Alignment.centerRight, child: _PrimaryButton(label: 'Update Password', onPressed: onUpdate)),
        ],
      ),
    ),
  );
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool hidden;
  final VoidCallback onVisibilityTap;
  final String? Function(String?)? validator;

  const _PasswordField({required this.label, required this.controller, required this.hidden, required this.onVisibilityTap, this.validator});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked = constraints.maxWidth < 400;
      final input = SizedBox(
        width: stacked ? double.infinity : 200,
        child: _SettingsTextField(controller: controller, hint: 'Enter ${label.toLowerCase()}', obscureText: hidden, validator: validator, suffixIcon: IconButton(icon: Icon(hidden ? Icons.visibility_off : Icons.visibility, size: 18), onPressed: onVisibilityTap)),
      );
      return stacked
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: _labelStyle), const SizedBox(height: 7), input])
          : Row(children: [Expanded(child: Text(label, style: _labelStyle)), input]);
    },
  );
}

class _NotificationSettingsCard extends StatelessWidget {
  final bool salesUpdates;
  final bool inventoryAlerts;
  final bool systemAnnouncements;
  final ValueChanged<bool> onSalesUpdatesChanged;
  final ValueChanged<bool> onInventoryAlertsChanged;
  final ValueChanged<bool> onSystemAnnouncementsChanged;
  final VoidCallback onSave;

  const _NotificationSettingsCard({
    required this.salesUpdates,
    required this.inventoryAlerts,
    required this.systemAnnouncements,
    required this.onSalesUpdatesChanged,
    required this.onInventoryAlertsChanged,
    required this.onSystemAnnouncementsChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => _SettingsCard(
    child: Column(
      children: [
        const Align(alignment: Alignment.centerLeft, child: _CardHeading(icon: Icons.notifications, title: 'Notification Settings')),
        const SizedBox(height: 3),
        _NotificationRow(title: 'Sales Updates', subtitle: 'Receive notifications about sales performance and reports.', value: salesUpdates, onChanged: onSalesUpdatesChanged),
        const Divider(color: Color(0xFFE4E2DD)),
        _NotificationRow(title: 'Inventory Alerts', subtitle: 'Receive alerts for low stock and inventory updates.', value: inventoryAlerts, onChanged: onInventoryAlertsChanged),
        const Divider(color: Color(0xFFE4E2DD)),
        _NotificationRow(title: 'System Announcement', subtitle: 'Receive important system announcements and updates.', value: systemAnnouncements, onChanged: onSystemAnnouncementsChanged),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onSave,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sidebarBg,
            side: const BorderSide(color: AppColors.sidebarBg),
            minimumSize: const Size(162, 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          ),
          child: const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}

class _NotificationRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationRow({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontalPadding = constraints.maxWidth < 500 ? 16.0 : 48.0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 1),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF585860))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.sidebarBg,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;

  const _SettingsTextField({required this.controller, required this.hint, this.keyboardType, this.obscureText = false, this.suffixIcon, this.validator, this.readOnly = false});

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: validator,
    readOnly: readOnly,
    style: const TextStyle(fontSize: 12),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9B9A9A)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minHeight: 32, minWidth: 36),
      border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFB9B9B9))),
      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFB9B9B9))),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.sidebarBg, width: 1.4)),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(180, 34),
      backgroundColor: AppColors.sidebarBg,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    child: Text(label),
  );
}

const _labelStyle = TextStyle(fontSize: 16, color: Color(0xFF52525B));
