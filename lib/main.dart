import 'package:flutter/material.dart';
import 'package:psoriasis_tracker/utils/commonUi/responsive_app.dart';
import 'package:psoriasis_tracker/utils/mixpanel_utils.dart';
import 'package:provider/provider.dart';
import 'package:psoriasis_tracker/utils/firebase/firebase_options.dart';
import 'package:psoriasis_tracker/utils/revenue_cat_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:psoriasis_tracker/core/navigation/navigation_service.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize Mixpanel
  await MixpanelUtils.init();

  final prefs = await SharedPreferences.getInstance();

  // PremiumService.listenToPurchaseUpdated();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await RevenueCatUtils.initialize();
  await RevenueCatUtils.syncPremiumStatus();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return ResponsiveApp(
            materialApp: MaterialApp(
              navigatorKey: NavigationService.navigatorKey,
              title: 'Protein Calculator',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: localeProvider.locale,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.pinkAccent,
                  primary: const Color(0xFFE2725B), // Coral
                  onPrimary: const Color(0xFFFFFFFF), // White text on Coral
                  secondary: const Color(0xFFE2725B), // Soft Apricot/Peach
                  onSecondary: const Color(0xFF4E3A2E), // Dark Warm Brown text
                  tertiary: const Color(0xFFFFF8F6), // Soft Light Cyan
                  onTertiary: const Color(0xFF1E3C40), // Dark Teal/Blue text
                  surface: const Color(0xFFFFF8F6), // Very Light Rosy/Peachy Off-White
                  onSurface: const Color(0xFF504442), // Dark Warm Gray/Brownish text
                  error: const Color(0xFFB71C1C),         // A slightly deeper Material error red
                  onError: const Color(0xFFFFFFFF),
                  errorContainer: const Color(0xFFFFDAD6), // Light reddish error container
                  onErrorContainer: const Color(0xFF410002), // Dark red for error container text
                  outline: const Color(0xFF9A8C8A),         // Muted warm brownish-gray
                  outlineVariant: const Color(0xFFEADFE0),   // Very light, subtle rosy-gray
                  scrim: const Color(0xFFFFDAD6), // Standard
                  shadow: const Color(0xFF000000), // Standard
                  surfaceDim: const Color(0xFFFDEEEA),      // Lighter version of surfaceContainerLow
                  surfaceBright: const Color(0xFFFFFDFB),    // Brighter than surface
                  surfaceContainerLowest: const Color(0xFFFFFFFF),    // Pure white
                  surfaceContainerLow: const Color(0xFFFEF1EE),      // A touch warmer than surface
                  surfaceContainer: const Color(0xFFFCEAE5),         // Clearer rosy/peach tint
                  surfaceContainerHigh: const Color(0xFFF9E3DD),       // More pronounced tint
                  surfaceContainerHighest: const Color(0xFFF7DCD6), // Strongest rosy/peach tint among containers
                  inverseSurface: const Color(0xFF382E2D),     // Dark, muted reddish-brown (contrast to light surface)
                  onInverseSurface: const Color(0xFFFFF0EE),   // Light pinkish/peachy off-white (for text on inverseSurface)
                  inversePrimary: const Color(0xFFFFB5A8),
                ),
                fontFamily: 'PTSerif',
                useMaterial3: true,
              ),
              initialRoute: '/',
              routes: {
                '/': (context) =>  Container(),
              },
            ),
          );
        },
      ),
    );
  }
}
