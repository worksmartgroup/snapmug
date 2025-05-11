import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:snapmug/globals.dart';

class ChallengesFire {
  List challengesList = [];
  Future<void> requestChallenge(
      {required String id,
      required String linkSongCreated,
      required num amount}) async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid != null) {
      final ref = FirebaseDatabase.instance
          .ref('AllUsers')
          .child(userUid)
          .child('Challanges')
          .child(id);

      final ref2 = FirebaseDatabase.instance.ref('AllUsers').child(userUid);
      final snapAmount = await ref2.child('earning').once();

// التأكد من أن القيمة الحالية رقمية ويمكن تحويلها
      num currentEarning = 0;
      if (snapAmount.snapshot.value != null) {
        try {
          currentEarning = num.parse(snapAmount.snapshot.value.toString()) == ""
              ? 0
              : num.parse(snapAmount.snapshot.value.toString());
        } catch (e) {
          print("خطأ في تحويل القيمة إلى رقم: $e");
        }
      }

      final String totalAmount = (currentEarning + amount).toString();

      await ref2.update({'earning': totalAmount});

      userProfileData?.updateEarning(totalAmount);

      final refChallenge =
          FirebaseDatabase.instance.ref("AllChallanges").child(id);
      await refChallenge.update({
        "exec_time": DateTime.now().millisecondsSinceEpoch,
        "status": "Sending",
        "link_song_created": linkSongCreated,
        'amount': amount
      });

      await ref.remove();
    }
  }
}
