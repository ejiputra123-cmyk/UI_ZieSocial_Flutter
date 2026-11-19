import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/core/network.dart';
import 'package:ziesocial/core/notifications_service.dart';
import 'package:ziesocial/view/login_view.dart';
import 'package:ziesocial/viewmodel/chat_viewmodel.dart';
import 'package:ziesocial/viewmodel/comment_viewmodel.dart';
import 'package:ziesocial/viewmodel/create_post_viewmodel.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/viewmodel/post_viewmodel.dart';
import 'package:ziesocial/viewmodel/profile_viewmodel.dart';
import 'package:ziesocial/viewmodel/register_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Firebase Init Error: $e');
  }

  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(apiClient)),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(apiClient)),
        ChangeNotifierProvider(create: (_) => CreatePostViewModel(apiClient)),
        ChangeNotifierProvider(create: (_) => PostViewModel(apiClient)),
        ChangeNotifierProvider(create: (_) => CommentViewModel(apiClient)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(apiClient)),
        ChangeNotifierProvider(create: (_) => ChatViewModel(apiClient)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZieSocial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      ),
      home: const LoginView(),
    );
  }
}
