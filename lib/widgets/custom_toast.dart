import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

class CustomToast {
  static void showSuccess(String? title, String message) {
    toastification.show(
      icon: Icon(Icons.check_circle, color: Colors.green, size: 24),
      title: Text(
        title!,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      description: Text(
        message,
        style: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      autoCloseDuration: Duration(seconds: 3),
      type: ToastificationType.success,
      style: ToastificationStyle.minimal,
      alignment: Alignment.bottomCenter,
    );
  }

  static void shoeFailed(String? title, String message) {
    toastification.show(
      icon: Icon(Icons.error, color: Colors.red, size: 24),
      title: Text(
        title!,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      description: Text(
        message,
        style: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      autoCloseDuration: Duration(seconds: 3),
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      alignment: Alignment.bottomCenter,
    );
  }
}
