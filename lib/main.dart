import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_provider.dart';
import 'my_app.dart';
import 'database/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init(); // ✅ Initialise Hive avant tout

  final eventProvider = EventProvider();
  await eventProvider.loadEvents(); // ✅ Charge les events après Hive

  runApp(
    ChangeNotifierProvider(
      create: (_) => eventProvider,
      child: const MyApp(),
    ),
  );
}
