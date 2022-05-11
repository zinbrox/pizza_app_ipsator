import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pizza_app_ipsator/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizza Ordering App',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        textTheme: GoogleFonts.rubikTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/homePage',
      routes: {
        '/homePage':(context) => HomePage(),
      },
    );
  }
}

