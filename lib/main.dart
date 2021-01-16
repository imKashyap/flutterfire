import 'package:flutter/material.dart';
import 'package:konnect/screens/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'GoogleSans'),
      home: LoginPage(),
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
