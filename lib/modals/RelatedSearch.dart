class SearchRelatedPlaces{
  String secondaryText;
  String mainPlace;
  String placeId;
  double longitude;
  double latitude;

  SearchRelatedPlaces({this.secondaryText, this.mainPlace, this.placeId});

  SearchRelatedPlaces.fromJson(Map<String, dynamic> json){
    placeId = json["id"];
    mainPlace = json["place_name"];
    latitude = json["geometry"]["coordinates"][0];
    longitude = json["geometry"]["coordinates"][1];
    secondaryText = "${json["context"][0]["text"]}, ${json["context"][1]["text"]}, ${json["context"][2]["text"]}, ${json["context"][3]["text"]}";
    print("****\n\n$longitude, $latitude\n\n****");
  }
}