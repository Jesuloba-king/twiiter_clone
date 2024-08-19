import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  // fontFamily: "Inter",
  textTheme: GoogleFonts.montserratTextTheme(),
  primaryTextTheme: GoogleFonts.montserratTextTheme(),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
      surface: const Color.fromARGB(255, 20, 20, 20), //(255, 99, 3, 3), //
      primary: const Color.fromARGB(255, 105, 105, 105),
      secondary: const Color.fromARGB(255, 30, 30, 30),
      tertiary: const Color.fromARGB(255, 47, 47, 47),
      inversePrimary: Colors.grey.shade300),
);
