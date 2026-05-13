import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/task_controller.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/task_repository_impl.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationService = NotificationService.instance;
  await notificationService.init();
  await notificationService.requestPermissions();
  
  runApp(const AgendaNusantaraApp());
}

class AgendaNusantaraApp extends StatelessWidget {
  const AgendaNusantaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            repository: AuthRepositoryImpl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskController(
            repository: TaskRepositoryImpl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeController(
            repository: TaskRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Agenda Nusantara',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
