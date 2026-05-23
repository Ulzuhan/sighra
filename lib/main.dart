import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

// Providers
import 'providers/breathing_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/settings_provider.dart';

// Screens
import 'screens/breathing_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/sounds_screen.dart';
import 'screens/settings_screen.dart';

// Generated Localizations
import 'package:respiro/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create state providers and load database stats/preferences
  final settingsProv = SettingsProvider();
  await settingsProv.loadSettings();

  final breathingProv = BreathingProvider();
  breathingProv.setHapticsEnabled(settingsProv.hapticsEnabled);
  breathingProv.setHapticSignature(settingsProv.hapticSignature);

  final statsProv = StatsProvider();
  await statsProv.fetchStats();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProv),
        ChangeNotifierProvider.value(value: breathingProv),
        ChangeNotifierProvider.value(value: statsProv),
      ],
      child: const RespiroApp(),
    ),
  );
}

class RespiroApp extends StatelessWidget {
  const RespiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    // Premium Twilight Color Palette
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0E1A), // Deep Cosmic Navy
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF64DFDF)), // Mint highlight
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF64DFDF),    // Glowing Breath Mint
        secondary: Color(0xFFFFB3C1),  // Solar Soft Pink
        surface: Color(0xFF121829),    // Twilight Indigo card surface
        onPrimary: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF121829),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x1F64DFDF), width: 0.8), // subtle mint glow border
        ),
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF0F4F8), // Soft Light Sky
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF007A7A)),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF007A7A),    // Rich Deep Teal
        secondary: Color(0xFFFF8FA3),  // Warm Coral
        surface: Colors.white,
        onPrimary: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.teal.withValues(alpha: 0.1), width: 0.8),
        ),
      ),
    );

    return MaterialApp(
      title: 'Sighra',
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
      home: const MainShellNavigation(),
    );
  }
}

class MainShellNavigation extends StatefulWidget {
  const MainShellNavigation({super.key});

  @override
  State<MainShellNavigation> createState() => _MainShellNavigationState();
}

class _MainShellNavigationState extends State<MainShellNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BreathingScreen(),
    SoundsScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF0D1222) : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
        selectedLabelStyle: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 10),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.lens_outlined),
            activeIcon: const Icon(Icons.lens),
            label: l10n.tabBreathing,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.music_note_outlined),
            activeIcon: const Icon(Icons.music_note),
            label: l10n.tabSounds,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined),
            activeIcon: const Icon(Icons.bar_chart),
            label: l10n.tabStats,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
