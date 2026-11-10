import 'package:flutter/material.dart';
import 'home_cta_card.dart';

/// Compatibility entry point for the redesigned home CTA.
class HomePrimaryAction extends StatelessWidget {
  const HomePrimaryAction({
    super.key,
    required this.onCreate,
    required this.onImport,
    required this.onAts,
  });
  final Future<void> Function() onCreate, onImport, onAts;
  @override
  Widget build(BuildContext context) =>
      HomeCtaCard(onCreate: onCreate, onImport: onImport, onAts: onAts);
}
