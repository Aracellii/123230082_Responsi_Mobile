import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latres/pages/home_page.dart';

import 'pages/detail_page.dart';
import 'storage/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveService.init();
  runApp(const TVShowApp());
}

class TVShowApp extends StatelessWidget {
  const TVShowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TV Show App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C81)),
        useMaterial3: true,
      ),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final arguments = settings.arguments as Map<String, dynamic>;
          final showId = int.tryParse(arguments['id']?.toString() ?? '0') ?? 0;
          return MaterialPageRoute(
            builder: (_) => DetailPage(showId: showId, initialShow: arguments),
          );
        }
        return null;
      },
    );
  }
}
