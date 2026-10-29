import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/guide.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const GuideApp());
}

class GuideApp extends StatelessWidget {
  const GuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'DAMSTOCK Code Guide',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: mode,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: const _Loader(),
      ),
    );
  }
}

class _Loader extends StatefulWidget {
  const _Loader();

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> {
  late final Future<Guide> _future = Guide.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Guide>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasData) return const HomeScreen();
        return Scaffold(
          backgroundColor: Brand.deep,
          body: Center(
            child: snap.hasError
                ? Text('${snap.error}', style: const TextStyle(color: Colors.white))
                : const SizedBox(width: 34, height: 34, child: CircularProgressIndicator(color: Brand.gold, strokeWidth: 3)),
          ),
        );
      },
    );
  }
}

void toggleTheme(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  themeMode.value = dark ? ThemeMode.light : ThemeMode.dark;
}
