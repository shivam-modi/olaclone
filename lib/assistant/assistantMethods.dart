import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uberclone/assistant/requestAssistant.dart';
import 'package:uberclone/configMaps.dart';
import 'package:uberclone/modals/address.dart';
import 'package:uberclone/modals/directDetails.dart';
import '../dataHandler/appData.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../modals/users.dart';
class AssistantMethods {
  static Future<String> searchCoordinateAddress(Position position, context) async{
    String placeAddress = "";
    List<String> address = List();

    String url = "https://nominatim.openstreetmap.org/reverse.php?lat=${position.latitude}&lon=${position.longitude}&zoom=21&format=jsonv2";

    var response = await RequestAssistant.getRequest(url);

    if(response != "Failed!!"){
      //placeAddress = response["display_name"];
      address.add(response["address"]["road"]) ;
      address.add(response["address"]["suburb"]);
      address.add(response["address"]["county"]);
      address.add(response["address"]["state_district"]);
      address.add(response["address"]["state"]);

      // print("\n\n****\n$position\n****\n");
      placeAddress = "${address[0]??""}, ${address[1]??""}, ${address[2]??""}, ${address[3]??""}, ${address[4]??""}";

      print("\n\n****\n$placeAddress\n****\n");
      Address userPickUpAddress = Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;
      // userPickUpAddress.placeId =
      Provider.of<AppData>(context, listen: false).updatePickUpLocation(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails> obtainDirectionDetails(LatLng initialPosition, LatLng finalPosition) async{
    String directionsUrl = "https://api.mapbox.com/directions/v5/mapbox/driving/${initialPosition.latitude},${initialPosition.longitude};${finalPosition.latitude},${finalPosition.longitude}?geometries=polyline6&access_token=pk.eyJ1Ijoic2hpdmFtZW50cmUiLCJhIjoiY2tqOHVqdWU5NTFydjJ4c2N6YXltOGpicSJ9.EEWCR7gQNQhWR76IAlwyJg";

   var res = await RequestAssistant.getRequest(directionsUrl);
    print("****\n\n$res\n\n*****");

   if(res == "Failed!!" || res["code"] != "ok"){
     return null;
   }
    int hr, min;
    double distance = ((res["routes"][0]["distance"]/1000));
    double duration = (res["routes"][0]["duration"])/3600;
    duration = num.parse(duration.toStringAsFixed(2));
    distance = num.parse(distance.toStringAsFixed(2));
    hr = num.parse(duration.toStringAsFixed(2).split(".").first);
    min = num.parse(duration.toStringAsFixed(2).split(".").last);
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.encodedPoints = res["routes"][0]["geometry"];
    directionDetails.distanceText = "$distance km";
    directionDetails.distanceValue = distance;
    directionDetails.durationText = "$hr hr $min min";
    directionDetails.distanceValue = duration;
    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails){
    double timeTravelFare = (directionDetails.durationValue/60) * 0.25;
    double distanceTravelFare = (directionDetails.distanceValue/1000) * 0.15;
    double totalFare = (timeTravelFare + distanceTravelFare) * 73.29 ;

    return totalFare.truncate();
  }

  static void getCurrentUserInfo() async{
    user = await FirebaseAuth.instance.currentUser;
    String userId = user.uid;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("users").child(userId);
    
    reference.once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value != null) {
        appUser = AppUser.fromSnapshot(dataSnapshot);
      }
    });
  }
}