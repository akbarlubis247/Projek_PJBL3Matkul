import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models.dart';
import 'services/api_service.dart';

part 'screens/auth.dart';
part 'screens/home.dart';
part 'screens/create_report.dart';
part 'screens/notifications.dart';
part 'screens/chat.dart';
part 'screens/chat_detail.dart';
part 'screens/profile_nav.dart';
part 'screens/profile_edit.dart';
part 'screens/dashboard.dart';
part 'controllers/auth_controller.dart';
part 'controllers/report_controller.dart';
part 'controllers/chat_controller.dart';
part 'controllers/notification_controller.dart';
part 'widgets/header.dart';
part 'widgets/bottom_nav.dart';
part 'widgets/form_controls.dart';
part 'widgets/photo_picker.dart';
part 'widgets/report_cards.dart';
part 'widgets/chat_widgets.dart';

void main() => runApp(const KampusLaporApp());

class KampusLaporApp extends StatelessWidget {
  const KampusLaporApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Lapor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        scaffoldBackgroundColor: const Color(0xFFF5F3FF),
        useMaterial3: true,
      ),
      home: const CivitasHomePage(),
    );
  }
}
