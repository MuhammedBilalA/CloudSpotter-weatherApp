import 'package:cloud_spotter/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CloudSpotter());
}

class CloudSpotter extends StatelessWidget {
  const CloudSpotter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home:  HomeScreen(),
    );
  }
}
