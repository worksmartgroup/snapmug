import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ArtistService {
  Future<String> fetchTopArtistName() async {
    try {
      final DatabaseReference ref =
          FirebaseDatabase.instance.ref("artistTrend");
      final Query query = ref.orderByChild("challenges").limitToLast(1);

      final DataSnapshot snapshot = await query.get();

      if (!snapshot.exists) return "";

      final data = snapshot.value as Map;
      final topArtist = data.values.first;

      return topArtist['name'] ?? "";
    } catch (e) {
      debugPrint('Error: ${e.toString()}');

      if (e.toString().contains('index-not-defined')) {
        await _initializeDatabaseIndexes(); // دالة جديدة لتهيئة الفهارس
        return "";
      }
      return "";
    }
  }

  Future<void> _initializeDatabaseIndexes() async {
    try {
      final ref = FirebaseDatabase.instance.ref(".settings/rules");
      await ref.set({
        "rules": {
          "artistTrend": {
            ".indexOn": ["challenges"]
          }
        }
      });
      debugPrint('تم تحديث الفهارس بنجاح');
    } catch (e) {
      debugPrint('فشل تحديث الفهارس: $e');
    }
  }
}
