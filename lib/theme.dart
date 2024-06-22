import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme textTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.openSans(fontSize: 18.0, color: Colors.black),
    displayMedium: GoogleFonts.openSans(
        fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
    bodyLarge: GoogleFonts.openSans(fontSize: 16.0, color: Colors.black),
    bodyMedium: GoogleFonts.openSans(fontSize: 14.0, color: Colors.grey),
    titleMedium: GoogleFonts.openSans(fontSize: 15.0, color: Colors.black),
  );
}

IconThemeData iconTheme() {
  return const IconThemeData(
    color: Colors.black,
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    centerTitle: false,
    color: Colors.white,
    elevation: 0.0,
    iconTheme: iconTheme(),
    titleTextStyle: GoogleFonts.nanumGothic(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

BottomNavigationBarThemeData bottomNavigatorTheme() {
  return const BottomNavigationBarThemeData(
    selectedItemColor: Colors.orange,
    unselectedItemColor: Colors.black54,
    showUnselectedLabels: true,
  );
}

ThemeData theme() {
  return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      textTheme: textTheme(),
      appBarTheme: appBarTheme(),
      bottomNavigationBarTheme: bottomNavigatorTheme(),
      primarySwatch: Colors.orange,
      dialogTheme: const DialogTheme(
          contentTextStyle: TextStyle(fontSize: 10),
          titleTextStyle: TextStyle(
            fontSize: 10, // 원하는 글자 크기로 설정
          )));
}

enum InputType {
  name,
  phone,
  password,
  address,
  emailAddress,
}

const double smallGap = 5.0;
const double mediumGap = 10.0;
const double largeGap = 20.0;
const double xlargeGap = 100.0;
