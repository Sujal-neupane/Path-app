import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/app/app_setup.dart';
import 'app.dart';

void main() async {
  // Initialize all app services before running
  await AppSetup.initialize();
  
  runApp(
    // Wrapping the entire app in ProviderScope allows Riverpod to store state globally
    const ProviderScope(
      child: PathApp(),
    ),
  );
}
