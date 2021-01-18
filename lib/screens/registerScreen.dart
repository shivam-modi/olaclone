import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../modals/toasts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uberclone/main.dart';
import 'package:uberclone/screens/loginScreen.dart';
import 'package:uberclone/screens/mainSreen.dart';
import '../widgets/progressDia.dart';


class RegisterScreen extends StatelessWidget {
  static const String idScreen = 'registerScreen';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  goTologIn(ctx){
    Navigator.pushNamedAndRemoveUntil(ctx, LoginScreen.idScreen, (route) => false);
  }

  signUp(ctx) async {
    String email = emailTextEditingController.text;
    String password = passwordTextEditingController.text;
    String name = nameTextEditingController.text;
    String phone = phoneTextEditingController.text;

    if(name.isEmpty && password.isEmpty && email.isEmpty && phone.isEmpty) {
      displayToastMsg("Fields must not be empty");
    } else if(name.trim().length < 4){
      displayToastMsg("Name must be atleast four character");
    } else if(!email.contains("@")){
      displayToastMsg("Email address is not valid");
    } else if(phone.length != 10){
      displayToastMsg("Phone number not valid");
    } else if(password.length < 6){
      displayToastMsg("Password must be atleast six character");
    } else if(name.trim().length > 4 && password.trim().length >= 6 && email.contains("@") && phone.length == 10) {
      showDia(ctx, "Registering Please wait...");
      final User firebaseUser = (await _firebaseAuth
          .createUserWithEmailAndPassword(
          email: email,
          password: password).catchError((errMsg) {
            Navigator.of(ctx).pop();
            displayToastMsg("Error: " + errMsg.toString());
         }
      )).user;
      if(firebaseUser.uid != null){
        Map userData = {
          "name": name,
          "phone": phone,
          "email": email.trim(),
          "userId": firebaseUser.uid
        };

      await userRef.child(firebaseUser.uid).set(userData).catchError((error){
        }).then((value) {
          displayToastMsg("Account created successfully");
          Navigator.of(ctx).pushNamedAndRemoveUntil(HomeScreen.idScreen, (route) => false);
        });
      } else {
        Navigator.of(ctx).pop();
        displayToastMsg("New user not created");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 35,
              ),
              Image.asset(
                "assets/images/logo.png",
                width: 280,
                height: 280,
                alignment: Alignment.center,
              ),
              SizedBox(height: 15.0,),
              Text(
                "Register as Rider",
                style: GoogleFonts.aBeeZee(
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2,),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      style: TextStyle(
                          fontSize: 22
                      ),
                    ),
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
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
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
                        textColor: Colors.brown,
                        child: Center(
                          child: Container(
                            height: 45,
                            child: Text(
                                "Signup",
                                style: TextStyle(
                                    fontSize: 28,
                                    fontFamily: "Bolt"
                                )
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () {
                          print("Clicked");
                          signUp(context);}
                    )
                  ],
                ),
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                  child: RichText(
                      text: TextSpan(
                          text: "Already have an Account?",
                          children: [
                            TextSpan(
                                text: " Login here",
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () => goTologIn(context)
                            ),
                          ],
                          style: TextStyle(
                              fontSize: 18,
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
