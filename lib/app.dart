import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';

class PathApp extends StatelessWidget {
  const PathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PATH',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'PlusJakartaSans', // Using your primary font instead of inter
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
