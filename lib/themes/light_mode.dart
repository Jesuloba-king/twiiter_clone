import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  fontFamily: "Inter",
  textTheme: GoogleFonts.montserratTextTheme(),
  primaryTextTheme: GoogleFonts.montserratTextTheme(),
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: Colors.grey.shade300,
      primary: Colors.grey.shade500,
      secondary: Colors.grey.shade200,
      tertiary: Colors.white,
      inversePrimary: Colors.grey.shade900),
);
