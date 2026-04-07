import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Wrapping the entire app in ProviderScope allows Riverpod to store state globally
    const ProviderScope(
      child: PathApp(),
    ),
  );
}
