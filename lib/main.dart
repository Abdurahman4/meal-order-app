import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Screen/LoginScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        textTheme: GoogleFonts.tajawalTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          centerTitle: true,
        ),
      ),
      home: LoginScreen(),
    );
  }
}
