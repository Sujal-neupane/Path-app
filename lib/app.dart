import 'package:flutter/material.dart';
import 'package:path_app/features/splash/presentation/pages/splash_screen.dart';


class PathApp extends StatelessWidget {
  const PathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PATH',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter', // Optional if added
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
