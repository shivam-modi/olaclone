import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uberclone/dataHandler/appData.dart';
import 'package:uberclone/screens/loginScreen.dart';
import 'package:uberclone/screens/mainSreen.dart';
import 'package:uberclone/screens/registerScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RiderApp());
}

DatabaseReference userRef = FirebaseDatabase.instance.reference().child("users");

class RiderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jaldi Chalo',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen : HomeScreen.idScreen,
        routes: {
          LoginScreen.idScreen: (context) => LoginScreen(),
          RegisterScreen.idScreen: (context) => RegisterScreen(),
          HomeScreen.idScreen: (context) => HomeScreen()
        },
      ),
    );
  }
}
