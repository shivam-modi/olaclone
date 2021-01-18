import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppUser{
  String id;
  String email;
  String name;
  String phone;

  AppUser({this.phone, this.email, this.id, this.name});

  AppUser.fromSnapshot(DataSnapshot dataSnapshot){
    id = dataSnapshot.key;
    email = dataSnapshot.value["email"];
    name = dataSnapshot.value["name"];
    phone = dataSnapshot.value["phone"];
  }
}