import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_culture/presentation/splash_screen.dart';
import 'package:urban_culture/utils/internet/internet_cubit.dart';
import 'utils/device_info.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DeviceInformation().init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingOnBackgroundHandler);
  runApp(MyApp(connectivity: Connectivity()));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingOnBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print(message.notification!.title);
    print(message.notification!.body);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.connectivity});

  final Connectivity connectivity;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InternetCubit(connectivity: connectivity),
      child: MaterialApp(
        title: 'Urban Culture',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          textTheme: GoogleFonts.epilogueTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff964F66)),
          useMaterial3: true,
          textTheme: GoogleFonts.epilogueTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
