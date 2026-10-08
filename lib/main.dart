import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/core/network.dart';
import 'package:ziesocial/view/register_view.dart';
import 'package:ziesocial/viewmodel/create_post_viewmodel.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/viewmodel/register_viewmodel.dart';

void main() {
  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => CreatePostViewModel(apiClient),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZieSocial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: RegisterView(),
    );
  }
}