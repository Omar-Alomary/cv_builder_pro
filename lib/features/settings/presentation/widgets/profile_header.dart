import 'package:flutter/material.dart';
import 'settings_profile_header.dart';

/// Compatibility entry point retaining the shared profile-picker contract.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, this.imagePath, required this.onPick});
  final String? imagePath;
  final Future<void> Function() onPick;
  @override
  Widget build(BuildContext context) =>
      SettingsProfileHeader(imagePath: imagePath, onPick: onPick);
}
