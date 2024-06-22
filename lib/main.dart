// ignore_for_file: avoid_print
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'permission_manager.dart';
import 'phone_auth.dart';
import 'theme.dart';
// import 'move_routes.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // PermissionManager permission = PermissionManager();
    // permission.requestPermissions().then((isGranted) {
    //   if (!isGranted) {
    //     permission.showPermissionMessage(context);
    //     print('권한허용 안됨 ');
    //     return;
    //   }
    // });

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: ' 핸드폰 앨범 hnpna 0614',
      debugShowCheckedModeBanner: false,
      theme: theme(),
      home: const PhoneAuth(),
      // initialRoute: Routes.phoneAuthPage,
      // // qrCodeGeneratorPage, //imageLabelViewPage, //photoTaggerPage, // Routes.loginPage,
      // routes: getRouters(),
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en', ''), // English
      //   Locale('ko', ''), // Korean
      // ],
    );
  }
}
