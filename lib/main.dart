import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/game_provider.dart';
import 'providers/language_provider.dart';
import 'utils/app_localizations.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force app to run in landscape mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Optionally hide system overlays for an immersive experience (keeps status/nav bars on desktop)
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize language provider and load saved preferences
  final languageProvider = LanguageProvider();
  await languageProvider.loadLanguage();

  runApp(TarotApp(languageProvider: languageProvider));
}

class TarotApp extends StatelessWidget {
  final LanguageProvider languageProvider;

  const TarotApp({super.key, required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider.value(value: languageProvider),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Tarot Card Game',
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('fr')],
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              textTheme:
                  GoogleFonts.cinzelTextTheme(
                    ThemeData.light().textTheme,
                  ).copyWith(
                    displayLarge: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    displayMedium: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    displaySmall: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    headlineLarge: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    headlineMedium: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    headlineSmall: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    titleLarge: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                    titleMedium: GoogleFonts.cinzel(
                      fontWeight: FontWeight.w600,
                    ),
                    titleSmall: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
                    bodyLarge: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
                    bodyMedium: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
                    bodySmall: GoogleFonts.cinzel(fontWeight: FontWeight.w500),
                    labelLarge: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                    labelMedium: GoogleFonts.cinzel(
                      fontWeight: FontWeight.w600,
                    ),
                    labelSmall: GoogleFonts.cinzel(fontWeight: FontWeight.w500),
                  ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.cinzelTextTheme(ThemeData.dark().textTheme)
                  .copyWith(
                    displayLarge: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    displayMedium: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    displaySmall: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    headlineLarge: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    headlineMedium: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    headlineSmall: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                    titleLarge: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                    titleMedium: GoogleFonts.cinzel(
                      fontWeight: FontWeight.w600,
                    ),
                    titleSmall: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
                    bodyLarge: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
                    bodyMedium: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
                    bodySmall: GoogleFonts.cinzel(fontWeight: FontWeight.w500),
                    labelLarge: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                    labelMedium: GoogleFonts.cinzel(
                      fontWeight: FontWeight.w600,
                    ),
                    labelSmall: GoogleFonts.cinzel(fontWeight: FontWeight.w500),
                  ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
