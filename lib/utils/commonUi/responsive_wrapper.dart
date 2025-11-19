import 'package:flutter/material.dart';


class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  double getScaleFactor(double height) {
    // print("Height:- $height");
    // if (height > 900) return 0.3;      // Very tall devices
    // if (height > 800) return 0.9;     // Tall devices
    // if (height > 700) return 0.5;      // Medium-tall devices
    // if (height > 600) return 0.6;      // Medium devices
    return 0.78;                        // Standard/small devices
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // print("Media Query:- ${mediaQuery.size.height} ${mediaQuery.size.width}");
    final scale = getScaleFactor(mediaQuery.size.height);
    
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(scale),
        size: Size(
          mediaQuery.size.width * scale,
          mediaQuery.size.height * scale,
        ),
        padding: mediaQuery.padding * scale,
        viewPadding: mediaQuery.viewPadding * scale,
        viewInsets: mediaQuery.viewInsets * scale,
      ),
      child: child,
    );
  }
}
