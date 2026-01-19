import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class MyApp extends StatelessWidget {
  final String env;
  const MyApp({super.key, required this.env});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMDUMB ($env)',
      home: Scaffold(
        body: Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
