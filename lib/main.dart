import 'package:flutter/material.dart';
import 'Pages/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';

// void main() => runApp(MyApp());

void main() async {
    // These two lines
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    //Code Goes Here
    runApp(MyApp());
}


//or
// import 'package:firebase_core/firebase_core.dart';
// ...

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MaterialApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram App',
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
      ),
      home: LoginScreen(),
      // Scaffold(
      //   appBar: AppBar(
      //     title: Text('Faniman', style: TextStyle(fontSize: 26.0, color: Colors.white, fontWeight: FontWeight.bold),),
      //   ),
      //   body: Center(
      //     child: Text('Welcome to Faniman Chat App', style: TextStyle(fontSize: 20.0, color: Colors.blueAccent),),
      //   ),
      // ),
      debugShowCheckedModeBanner: false,
    );
  }
}



