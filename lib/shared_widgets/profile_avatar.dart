import 'dart:io';
import 'package:flutter/material.dart';

/// Circular account photo with safe missing-file and image-decoding fallbacks.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imagePath,
    this.size = 48,
    this.onTap,
    required this.label,
  });
  final String? imagePath;
  final double size;
  final VoidCallback? onTap;
  final String label;

  File? _file() {
    try {
      final path = imagePath;
      if (path == null || path.isEmpty) return null;
      final file = File(path);
      return file.existsSync() ? file : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final file = _file();
    Widget fallback() => ColoredBox(
      color: scheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: size * .45,
          color: scheme.primary,
        ),
      ),
    );
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: onTap != null,
        image: true,
        child: SizedBox.square(
          dimension: size,
          child: Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: ClipOval(
                child: ExcludeSemantics(
                  child: file == null
                      ? fallback()
                      : Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: size,
                          height: size,
                          errorBuilder: (_, _, _) => fallback(),
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
