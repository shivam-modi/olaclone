import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uberclone/assistant/requestAssistant.dart';
import 'package:uberclone/widgets/divider.dart';
import 'package:uberclone/widgets/progressDia.dart';
import 'package:uberclone/dataHandler/appData.dart';
import '../modals/RelatedSearch.dart';
import '../modals/address.dart';

class SearchLocation extends StatefulWidget {
  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropOffController = TextEditingController();
  List<SearchRelatedPlaces> relatedPlaces = [];


  findPlace(placeName) async {
    if(placeName.length > 1){
      String autoCompleteUrl = "https://api.mapbox.com/geocoding/v5/mapbox.places/$placeName.json?autocomplete=true&country=in&access_token=pk.eyJ1Ijoic2hpdmFtZW50cmUiLCJhIjoiY2tqOHVqdWU5NTFydjJ4c2N6YXltOGpicSJ9.EEWCR7gQNQhWR76IAlwyJg";
      var res = await RequestAssistant.getRequest(autoCompleteUrl);
      if(res == "Failed!!"){
        return;
      }
    //  print("****\n\n${res["features"].length}\n\n****");
      if(res["features"].length != 0){
        // int responseLength = res["features"].length;
        var searchResult = res["features"];
        var places = (searchResult as List).map((e) => SearchRelatedPlaces.fromJson(e)).toList();
        setState(() {
           relatedPlaces = places;
        });
        // for(int i = 0; i != responseLength; i++ ){
        //  setState(() {
        //    relatedPlaces.add(res["features"][i]["place_name"]);
        //  });
        // }

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    String placeAddress = Provider.of<AppData>(context).userPickupLocation.placeName?? "";
    pickUpController.text = placeAddress;
    return Scaffold(
      body: Column(
        children: [
          Container(
             height: 215,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 5,
                  spreadRadius: 0.4,
                  offset: Offset(0.7, 0.7),
                )
              ]
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 25, top: 40, right: 25, bottom: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                          child: Icon(Icons.arrow_back),
                          onTap: () {
                            Navigator.of(context).pop();
                         }
                      ),
                      Center(
                        child: Text("Choose Destination",
                          style: GoogleFonts.aBeeZee(fontSize: 18,),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16,),
                  Row(
                    children: [
                      Image.asset("assets/images/pickicon.png", height: 16, width: 16,),
                      SizedBox(width: 18,),
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[350],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextField(
                                controller: pickUpController,
                                decoration: InputDecoration(
                                  hintText: "PickUp Location",
                                  fillColor: Colors.grey[350],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    left: 11,
                                    top: 8,
                                    bottom: 8
                                  ),
                                ),
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Image.asset("assets/images/desticon.png", height: 16, width: 16,),
                      SizedBox(width: 18,),
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[350],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextField(
                                controller: dropOffController,
                                onChanged: (val) => findPlace(val),
                                decoration: InputDecoration(
                                  hintText: "Where to ?",
                                  fillColor: Colors.grey[350],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 11,
                                      top: 8,
                                      bottom: 8
                                  ),
                                ),
                              ),
                            ),
                          )
                      )
                    ],
                  )
                ],
              )
            ),
          ),
          SizedBox(height: 10),
          relatedPlaces.length > 0 ?
              Expanded(
                child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) => SearchResultTile(searchResult: relatedPlaces[index],),
                      separatorBuilder: (context, index) => WidgetDivider(),
                      itemCount: relatedPlaces.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                ),
              ) :
             Container()
        ]
      ),
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final SearchRelatedPlaces searchResult;
  SearchResultTile({Key key, this.searchResult}) : super(key: key);

  findPlaceDetails(ctx){
     // String placeDetailsUrl = "https://api.mapbox.com/geocoding/v5/mapbox.places/77.149879,28.693751.json?types=poi&access_token=pk.eyJ1Ijoic2hpdmFtZW50cmUiLCJhIjoiY2tqOHVnZ282NTFuaDJ3c2M5ZGRodDNhOCJ9.-OPpUMvQBmMCSgedwJiXgw";

     Address address = Address();
     address.placeName = searchResult.mainPlace;
     address.longitude = searchResult.longitude;
     address.latitude = searchResult.latitude;

     Provider.of<AppData>(ctx, listen: false).updateDropOffLocation(address);
     print("****\n${address.placeName} \n****");
     Navigator.of(ctx).pop("obtainedDirection");
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () => findPlaceDetails(context),
      child: Container(
        child: Column(
          children: [
            SizedBox(width: 10,),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(width: 14,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(searchResult.mainPlace,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.aBeeZee(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 3,),
                      Text(searchResult.secondaryText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.aBeeZee(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 10,),
          ],
        ),
      ),
    );
  }
}
