import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uberclone/assistant/assistantMethods.dart';
import 'package:uberclone/configMaps.dart';
import 'package:uberclone/dataHandler/appData.dart';
import 'package:uberclone/modals/directDetails.dart';
import 'package:uberclone/screens/loginScreen.dart';
import 'package:uberclone/screens/searchScreen.dart';
import '../widgets/divider.dart';
import '../widgets/progressDia.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomeScreen extends StatefulWidget {
  static const String idScreen = 'mainScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController _newGoogleMapController;
  Position currentPosition;
  var _geolocator = Geolocator();
  double bottomPaddingOfMap = 120;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double searchDetailsContainerHeight = 270.0;
  double requestRideDetailsContainer = 0;
  double rideDetailsContainerHeight = 0.0;

  bool drawerOpen =  true;

  DirectionDetails tripDetails = DirectionDetails();

  DatabaseReference rideRequestRefer;


  @override
  void initState(){
    super.initState();
    AssistantMethods.getCurrentUserInfo();
  }

  saveRideRequest(){
    rideRequestRefer = FirebaseDatabase.instance.reference().child("Ride Requests");
    var pickUp = Provider.of<AppData>(context, listen: false).userPickupLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
      "placeName": pickUp.placeName,
    };

    Map dropOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
      "placeName": dropOff.placeName,
    };


    Map rideInfoMap = {
      "driverId": "waiting",
      "paymentMethod": "cash",
      "pickup": pickUpLocMap,
      "dropOff": dropOffLocMap,
      "timestamp": DateTime.now(),
      "riderName": appUser.name,
      "riderPhone": appUser.phone,
      "rideId": "${pickUp.latitude}${dropOff.longitude}"
    };
    
    rideRequestRefer.set(rideInfoMap);
  }

  displayRideDetailsContainer()  async {
    await getPlaceDirection();

    setState(() {
       searchDetailsContainerHeight = 0.0;
       rideDetailsContainerHeight = 210.0;
       bottomPaddingOfMap = 230;
       drawerOpen = false;
    });
  }

  cancelRideRequest(ctx){
    rideRequestRefer.remove();
    resetApp(ctx);
  }

  locatePosition(ctx) async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high); ///use best when navigating
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);
    _newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(position, ctx);

  }

  decoration(){
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
              color: Colors.black87,
              blurRadius: 16,
              spreadRadius: 6,
              offset: Offset(0.7, 0.7)
          ),
        ]
    );
  }

  Future<void> getPlaceDirection() async{
    var initialPosition = Provider.of<AppData>(context, listen: false).userPickupLocation;
    var finalPosition = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPosition.latitude, initialPosition.longitude);
    var dropOffLatLng = LatLng(finalPosition.latitude, finalPosition.longitude);

    showDia(context, "Please wait...");

    var details = await AssistantMethods.obtainDirectionDetails(pickUpLatLng, dropOffLatLng);
    Navigator.of(context).pop();
    print("****\n\n$details\n\n*****");
     setState(() {
       tripDetails = details;
     });

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResult = polylinePoints.decodePolyline(details.encodedPoints);
    pLineCoordinates.clear();
    if(decodePolyLinePointsResult.isNotEmpty){
      decodePolyLinePointsResult.forEach((pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: Colors.pink,
          polylineId: PolylineId("polylineId"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true
      );
      polylineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if(pickUpLatLng.latitude > dropOffLatLng.latitude && pickUpLatLng.longitude >dropOffLatLng.longitude){
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if(pickUpLatLng.longitude > dropOffLatLng.longitude){
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude), northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if(pickUpLatLng.latitude > dropOffLatLng.latitude){
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude), northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    
    _newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: initialPosition.placeName, snippet: "my Location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );
    Marker dropOffMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPosition.placeName, snippet: "Destination"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );
    setState(() {
      markersSet.add(pickUpMarker);
      markersSet.add(dropOffMarker);
    });

    Circle pickUpCircle = Circle(
      fillColor: Colors.amber,
      center: pickUpLatLng,
      radius: 12,
      strokeColor: Colors.amberAccent,
      strokeWidth: 4,
      circleId: CircleId("pickUpCircle")
    );
    Circle dropOffCircle = Circle(
        fillColor: Colors.purple,
        center: pickUpLatLng,
        radius: 12,
        strokeColor: Colors.purpleAccent,
        strokeWidth: 4,
        circleId: CircleId("pickUpCircle")
    );
    setState(() {
      circlesSet.add(pickUpCircle);
      circlesSet.add(dropOffCircle);
    });
  }

  resetApp(ctx){
    setState(() {
      drawerOpen = true;
      searchDetailsContainerHeight = 270.0;
      rideDetailsContainerHeight = 0.0;
      requestRideDetailsContainer = 0.0;
      bottomPaddingOfMap = 280;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition(ctx);
  }

  displayRequestRideDetails(){
    saveRideRequest();
    setState(() {
      requestRideDetailsContainer = 210;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230;
      drawerOpen = true;
    });
  }

  goToModal(ctx){
    setState(() {
      bottomPaddingOfMap = 280;
    });
    return showModalBottomSheet(
        context: ctx,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return AnimatedSize(
            vsync: this,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: 160),
            child: Container(
              height: searchDetailsContainerHeight,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black87,
                        blurRadius: 12,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7)
                    ),
                  ]
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6,),
                    Text("Hi there",
                      style: TextStyle(
                          fontSize: 13
                      ),
                    ),
                    Text("Where to",
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Bolt"
                      ),
                    ),
                    SizedBox(height: 17,),
                    GestureDetector(
                      onTap: () async {
                        var res = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchLocation()));
                          if(res == "obtainedDirection"){
                            displayRideDetailsContainer();
                          }
                        },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 5,
                                  spreadRadius: 0.3,
                                  offset: Offset(0.7, 0.7)
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.brown),
                              SizedBox(width: 10,),
                              Text("Search Drop Off")
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24,),
                    Row(
                      children: [
                        Icon(Icons.home, color: Colors.grey),
                        SizedBox(width: 24,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Provider.of<AppData>(context).userPickupLocation != null ?
                              Provider.of<AppData>(context).userPickupLocation.placeName :
                              "Add Pick Up",
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              softWrap: true,
                            ),
                            SizedBox(height: 4,),
                            Text("Current Home Address",
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 8,),
                    WidgetDivider(),
                    SizedBox(height: 8,),
                    Row(
                      children: [
                        Icon(Icons.work, color: Colors.grey),
                        SizedBox(width: 24,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add Work"),
                            SizedBox(height: 4,),
                            Text("Work Address",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title: Text("Jaldi chalo!"),
      // ),
      drawer: Container(
        color: Colors.white,
        width: 250,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white70
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                          "assets/images/user_icon.png",
                          height: 65,
                          width: 65,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "profile name",
                            style: GoogleFonts.aBeeZee(
                              fontSize: 16,
                            )
                          ),
                          SizedBox(height: 6,),
                          Text("Visit Profile"),
                        ]
                      )
                    ],
                  ),
                )
              ),
              WidgetDivider(),
              SizedBox(height: 12,),
              //Drawer body
              ListTile(
                leading: Icon(Icons.history),
                title: Text("History", style: TextStyle(fontSize: 15)),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Profile", style: TextStyle(fontSize: 15)),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("About", style: TextStyle(fontSize: 15)),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Sign Out", style: TextStyle(fontSize: 15)),
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.idScreen, (route) => false);
                },
              )
            ]
          )
        ),
      ),
      body: Stack(
          children: [
            GoogleMap(
                  padding: EdgeInsets.only(bottom: bottomPaddingOfMap, top: 35),
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  polylines: polylineSet,
                  circles: circlesSet,
                  markers: markersSet,
                  onMapCreated: (GoogleMapController controller){
                     _mapController.complete(controller);
                     _newGoogleMapController = controller;
                     locatePosition(context);
                  },
              ),
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,0.7
                      )
                    )
                  ]
                ),
                child: GestureDetector(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(drawerOpen ? Icons.menu : Icons.cancel, color: drawerOpen ? Colors.black87 : Colors.red),
                    radius: 20,
                  ),
                  onTap: (){ drawerOpen ?
                             scaffoldKey.currentState.openDrawer() :
                             resetApp(context);
                  },
                ),
              ),
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black87,
                              blurRadius: 12,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7)
                          ),
                        ]
                    ),
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           Icon(Icons.local_taxi_sharp, size: 23,),
                           SizedBox(width: 10,),
                           Text("Pick a ride",
                             style: GoogleFonts.comfortaa(
                               fontSize: 21
                             ),
                           )
                          ],
                        ),
                    ),
                   ),
                  onTap: () => goToModal(context),
                )
            ),
            Positioned(
                bottom: 0.0,
                left: 0,
                right: 0,
                child: AnimatedSize(
                  vsync: this,
                  duration: Duration(milliseconds: 160),
                  curve: Curves.bounceIn,
                  child: Container(
                    height: rideDetailsContainerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 16,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7)
                        )
                      ]
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.tealAccent[100],
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Image.asset("assets/images/taxi.png", height: 70, width: 80,),
                                SizedBox(width: 16,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Car",
                                        style: GoogleFonts.aBeeZee(
                                          fontSize: 18
                                        )
                                      ),
                                      Text(tripDetails != null ? tripDetails.distanceText : '',
                                          style: GoogleFonts.baloo(
                                              fontSize: 16,
                                              color: Colors.grey
                                          )
                                      )
                                    ]
                                  ),
                                ),
                                Expanded(
                                  child: Text(tripDetails != null ?
                                          "₹${AssistantMethods.calculateFares(tripDetails)}" :
                                          ''
                                      ,
                                      style: GoogleFonts.aBeeZee(
                                          // fontSize: 1,
                                          color: Colors.black87
                                      )
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Icon(FontAwesomeIcons.rupeeSign, size: 18, color: Colors.black54,),
                                  SizedBox(width: 16,),
                                  Text("Cash",
                                      style: GoogleFonts.aBeeZee(
                                          fontSize: 16,
                                          color: Colors.grey
                                      )
                                  ),
                                  SizedBox(width: 6,),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16,)
                                ],
                              ),
                        ),
                        SizedBox(height: 24,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: RaisedButton(
                            onPressed: displayRequestRideDetails,
                            color: Theme.of(context).accentColor,
                            child: Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Request", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),),
                                  Icon(FontAwesomeIcons.taxi, color: Colors.brown, size: 26,)
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 160),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 0.5,
                        blurRadius: 16,
                        color: Colors.black45,
                        offset: Offset(0.7, 0.7)
                      )
                    ]
                  ),
                  height: requestRideDetailsContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                         SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ColorizeAnimatedTextKit(
                            onTap: () {
                              print("Tap Event");
                            },
                            text: [
                              "Requesting a Ride",
                              "Please wait...",
                              "Finding a driver",
                            ],
                            textStyle: TextStyle(
                                fontSize: 55.0,
                                fontFamily: "Signatra"
                            ),
                            colors: [
                              Colors.purple,
                              Colors.pink,
                              Colors.blue,
                              Colors.yellow,
                              Colors.red,
                              Colors.green,
                            ],
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap: () => cancelRideRequest(context),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(width: 2, color: Colors.grey[300]),
                            ),
                            child: Icon(Icons.close,size: 26, ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: double.infinity,
                          child: Text("Cancel ride",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
}
