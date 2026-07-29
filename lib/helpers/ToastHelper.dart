import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {

  // ==================== Success Toast ====================
  static void success({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  // ==================== Error Toast ====================
  static void error({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  // ==================== Info Toast ====================
  static void info({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  // ==================== Warning Toast ====================
  static void warning({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}