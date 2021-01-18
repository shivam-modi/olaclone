import 'package:flutter/cupertino.dart';
import 'package:uberclone/modals/address.dart';

class AppData extends ChangeNotifier{
  Address userPickupLocation, dropOffLocation;

  updatePickUpLocation(Address pickUpAddress){
    userPickupLocation = pickUpAddress;
    notifyListeners();
  }

  updateDropOffLocation(Address dropOffAddress){
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}