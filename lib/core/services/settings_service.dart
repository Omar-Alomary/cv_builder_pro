import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Platform operations used by settings; callers report actionable failures.
class SettingsService {
  static const storeUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue:
        'https://play.google.com/store/apps/details?id=com.smartresume.builder',
  );
  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'omar.alomary129@gmail.com',
  );

  Future<String?> pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (image == null) return null;
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/profile_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(await image.readAsBytes(), flush: true);
      return file.path;
    } catch (error) {
      throw Exception('Profile image: $error');
    }
  }

  Future<void> contactSupport() => _open(
    Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=CV%20Builder%20Pro%20Support',
    ),
  );
  Future<void> rateApp() => _open(Uri.parse(storeUrl));
  Future<void> _open(Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('No application can open this link');
      }
    } catch (error) {
      throw Exception('Open link: $error');
    }
  }

  Future<void> shareApp(Rect origin, String text) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '$text\n$storeUrl',
          subject: 'CV Maker Pro',
          sharePositionOrigin: origin,
        ),
      );
    } catch (error) {
      throw Exception('Share application: $error');
    }
  }

  Future<void> exitApp() async {
    try {
      await SystemNavigator.pop();
    } catch (error) {
      throw Exception('Exit application: $error');
    }
  }
}
