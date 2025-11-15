import 'package:flutter/material.dart';
import 'package:car_maintenance_tracker/utils/commonUi/responsive_wrapper.dart';

class ResponsiveApp extends StatelessWidget {
  final MaterialApp materialApp;

  const ResponsiveApp({super.key, required this.materialApp});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MaterialApp(
          key: materialApp.key,
          scaffoldMessengerKey: materialApp.scaffoldMessengerKey,
          navigatorKey: materialApp.navigatorKey,
          home: materialApp.home != null
              ? ResponsiveWrapper(child: materialApp.home!)
              : null,
          routes: Map.fromEntries(
            materialApp.routes?.entries.map(
                  (entry) => MapEntry(
                    entry.key,
                    (context) => ResponsiveWrapper(
                      child:
                          Builder(builder: (context) => entry.value(context)),
                    ),
                  ),
                ) ??
                {},
          ),
          initialRoute: materialApp.initialRoute,
          onGenerateRoute: materialApp.onGenerateRoute != null
              ? (settings) {
                  final route = materialApp.onGenerateRoute!(settings);
                  if (route == null) return null;

                  if (route is PageRoute) {
                    return PageRouteBuilder(
                      settings: route.settings,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return ResponsiveWrapper(
                          child: route.buildPage(
                              context, animation, secondaryAnimation),
                        );
                      },
                    );
                  }
                  return route;
                }
              : null,
          onUnknownRoute: materialApp.onUnknownRoute,
          title: materialApp.title,
          color: materialApp.color,
          theme: materialApp.theme,
          darkTheme: materialApp.darkTheme,
          highContrastTheme: materialApp.highContrastTheme,
          highContrastDarkTheme: materialApp.highContrastDarkTheme,
          themeMode: materialApp.themeMode,
          locale: materialApp.locale,
          localizationsDelegates: materialApp.localizationsDelegates,
          localeListResolutionCallback:
              materialApp.localeListResolutionCallback,
          localeResolutionCallback: materialApp.localeResolutionCallback,
          supportedLocales: materialApp.supportedLocales,
          debugShowMaterialGrid: materialApp.debugShowMaterialGrid,
          showPerformanceOverlay: materialApp.showPerformanceOverlay,
          checkerboardRasterCacheImages:
              materialApp.checkerboardRasterCacheImages,
          checkerboardOffscreenLayers: materialApp.checkerboardOffscreenLayers,
          showSemanticsDebugger: materialApp.showSemanticsDebugger,
          debugShowCheckedModeBanner: materialApp.debugShowCheckedModeBanner,
          shortcuts: materialApp.shortcuts,
          actions: materialApp.actions,
          restorationScopeId: materialApp.restorationScopeId,
          scrollBehavior: materialApp.scrollBehavior,
          onGenerateTitle: materialApp.onGenerateTitle,
        );
      },
    );
  }
}
