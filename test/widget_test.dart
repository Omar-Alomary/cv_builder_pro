import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/core/utils/responsive.dart';

void main() {
  testWidgets('Breakpoints and content width support small and large screens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final cases = <double, ScreenType>{
      320: ScreenType.mobile,
      599: ScreenType.mobile,
      600: ScreenType.tablet,
      1199: ScreenType.tablet,
      1200: ScreenType.desktop,
      1920: ScreenType.desktop,
    };
    for (final entry in cases.entries) {
      tester.view.physicalSize = Size(entry.key, 900);
      late ScreenType actual;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              actual = Responsive.screenType(context);
              return Scaffold(
                body: Responsive.maxWidth(
                  child: const SizedBox(
                    key: ValueKey('content'),
                    width: double.infinity,
                    height: 100,
                  ),
                ),
              );
            },
          ),
        ),
      );
      expect(actual, entry.value);
      expect(
        tester.getSize(find.byKey(const ValueKey('content'))).width,
        entry.key > 1200 ? 1200 : entry.key,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
