import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapmug/pages/HomePage.dart';

Future<void> signInWithTwitter(BuildContext context) async {
  final twitterProvider = TwitterAuthProvider();

  try {
    final userCredential =
        await FirebaseAuth.instance.signInWithProvider(twitterProvider);
    final user = userCredential.user;

    if (user != null) {
      print('تم تسجيل الدخول بنجاح: ${user.displayName}');

      // الانتقال إلى الصفحة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      throw Exception('Error: User is null');
    }
  } catch (e) {
    print('خطأ في تسجيل الدخول: $e');

    // عرض رسالة الخطأ للمستخدم
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error : ${e.toString()}'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
