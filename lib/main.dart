import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
// import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:snapmug/core/class/colors.dart';
import 'package:snapmug/pages/splash_screen.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
          apiKey: "AIzaSyB8fudufdb81EmsK-XLAuzeTf57b5d9LEA",
          authDomain: "snapmugflutter.firebaseapp.com",
          databaseURL: "https://snapmugflutter-default-rtdb.firebaseio.com",
          projectId: "snapmugflutter",
          storageBucket: "snapmugflutter.appspot.com",
          messagingSenderId: "534586490308",
          appId: "1:534586490308:android:51b3e0cd6ff44a883d7891",
          measurementId: "G-7PBECNZRNE");
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and macOS
      return const FirebaseOptions(
        apiKey: 'AIzaSyDhK5vHpxzCh_jgP7sfuWMabS77lS7SFVs',
        appId: '1:534586490308:ios:5ced94cdc4ef838f3d7891',
        messagingSenderId: '534586490308',
        projectId: 'snapmugflutter',
        storageBucket: 'snapmugflutter.appspot.com',
        iosClientId: 'YOUR_IOS_CLIENT_ID',
        iosBundleId: 'YOUR_IOS_BUNDLE_ID',
      );
    } else {
      // Android
      return const FirebaseOptions(
        apiKey: 'AIzaSyDhK5vHpxzCh_jgP7sfuWMabS77lS7SFVs',
        appId: '1:534586490308:android:51b3e0cd6ff44a883d7891',
        messagingSenderId: "",
        projectId: 'snapmugflutter',
        storageBucket: 'snapmugflutter.appspot.com',
      );
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // print('firebase options ${DefaultFirebaseOptions.currentPlatform}');
  initializeFirebase();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.yourcompany.yourapp.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Snapmug',
      useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
        ),
        scaffoldBackgroundColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      // initialRoute: FirebaseAuth.instance.currentUser != null ? '/home' : '/',
      // routes: {
      //   '/': (context) => SignInActivity(),
      //   '/home': (context) => HomePage(),
      // },
    );
  }
}

Future<void> initializeFirebase() async {
  try {
    final apps = Firebase.apps;
    if (apps.any((app) => app.name == 'Snapmug')) {
      print('Firebase already initialized with name Snapmug');
      return;
    }
    await Firebase.initializeApp(
      name: 'Snapmug',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
}
