import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:konnect/managers/landing_manger.dart';
import 'package:konnect/sevices/auth.dart';
import 'package:konnect/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    return Provider<AuthBase>(
      create: (context) => Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Konnect',
        theme: ThemeData(
          primaryColor: kColorPrimary,
          accentColor: kColorAccent,
          brightness: Brightness.dark,
          fontFamily: 'GoogleSans',

        ),
        home: LandingManager(),
      ),
    );
  }
}



// class SplashScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF3a3744),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//          SizedBox(height: 200.0,),
//           Image.asset('assets/images/logo.png',
//           scale: 5,),
//           SizedBox(height: 70.0,),
//           Text('Konnect',textAlign: TextAlign.center,
//           style: Theme.of(context).textTheme.headline4.copyWith(
//             color: Colors.white.withOpacity(0.25),
//           ),)
//         ],
//       ),
//     );
//   }
// }
