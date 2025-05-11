import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Add this import for Material widgets
import 'package:firebase_database/firebase_database.dart';

import 'BottomNav/Home.dart'; // Add this import for Firebase Realtime Database

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<dynamic, dynamic>> notificationsList = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  bool isLoading = false;
  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("AllNotification");

    ref.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> notifications =
            snapshot.value as Map<dynamic, dynamic>;
        notifications.forEach((key, value) {
          setState(() {
            notificationsList.add(value);
          });
        });
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('No notifications found');
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      print('Failed to fetch notifications: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Notifications',
          style: TextStyle(color: yellowColor),
        ),
        iconTheme: IconThemeData(
          color: yellowColor, //change your color here
        ),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(backgroundColor: yellowColor),
            )
          : ListView.builder(
              itemCount: notificationsList.length,
              itemBuilder: (context, index) {
                final notification = notificationsList[index];
                return ListTile(
                    title: Text(
                      "${notification['songName'] ?? 'Unknown'} song was added by ${notification['artistName'] ?? 'Unknown'} artist",
                      style: const TextStyle(color: Colors.white),
                    ),
                    // subtitle: Text(notification['message'] ?? 'No Message'),
                    leading:CircleAvatar(
                      radius: 30,
                      backgroundColor: yellowColor,
                      backgroundImage: NetworkImage(notification['albumArtUrl'])
                    )



                    // notification['albumArtUrl'] == ''
                    //     ? Image.asset('assets/icons8-music-record-94.png')
                    //     : Image.network(notification['albumArtUrl'])
                );
              },
            ),
    );
  }
}
