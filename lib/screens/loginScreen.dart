import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uberclone/main.dart';
import 'package:uberclone/modals/toasts.dart';
import 'package:uberclone/screens/mainSreen.dart';
import 'package:uberclone/screens/registerScreen.dart';
import '../widgets/progressDia.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = 'loginScreen';
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  logIn(ctx) async {
    String email = emailTextEditingController.text;
    String password = passwordTextEditingController.text;

    if(!email.contains("@")){
      displayToastMsg("Email address is not valid");
    } else if(password.isEmpty){
      displayToastMsg("This can't be empty");
    } else if (email.contains("@") && password.isNotEmpty ) {
      showDia(ctx, "Authenticating please wait..");
      final User firebaseUser = (await _firebaseAuth
          .signInWithEmailAndPassword(
          email: email,
          password: password).catchError((errMsg) {
        Navigator.of(ctx).pop();
        displayToastMsg("Error: " + errMsg.toString());
      }
      )).user;
      if (firebaseUser.uid != null) {
        await userRef.child(firebaseUser.uid).once().then(
                (DataSnapshot snap) {
              if (snap.value != null) {
                Navigator.of(ctx).pushNamedAndRemoveUntil(
                    HomeScreen.idScreen, (route) => false);
                displayToastMsg("Logged In successfully");
              } else {
                _firebaseAuth.signOut();
                Navigator.of(ctx).pop();
                displayToastMsg("No records founds");
              }
            });
      }
    } else {
      displayToastMsg("Enter right credentials");
    }
  }

  goTosignUp(ctx){
    Navigator.of(ctx).pushNamedAndRemoveUntil(RegisterScreen.idScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x28231D),
                Color(0x0A0806)
              ]
            )
          ),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 35,
              ),
              Image.asset(
                "assets/images/logo.png",
                width: 310,
                height: 310,
                alignment: Alignment.center,
              ),
              SizedBox(height: 10.0,),
              Text(
                "Login as Rider",
                style: GoogleFonts.aBeeZee(
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 22
                      ),
                    ),
                    TextFormField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      style: TextStyle(
                          fontSize: 22
                      ),
                    ),
                    SizedBox(
                      height: 14
                    ),
                    RaisedButton(
                        color: Colors.yellow,
                        textColor: Colors.white,
                        child: Center(
                           child: Container(
                             height: 45,
                             child: Text(
                               "Login",
                               style: TextStyle(
                                 fontSize: 28,
                                   color: Colors.brown[800],
                                 fontFamily: "Bolt"
                               )
                             ),
                           ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () => logIn(context)
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                child: RichText(
                    text: TextSpan(
                  text: "Don't have an Account?",
                  children: [
                    TextSpan(
                      text: " Register",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () => goTosignUp(context)
                    ),
                  ],
                 style: TextStyle(
                   fontSize: 20,
                   color: Colors.black87
                 )
                )
               )
              )
            ],
          ),
        ),
      ),
    );
  }
}
