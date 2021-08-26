import 'package:flutter/material.dart';
import 'package:app_meteo/widgets/CustomText.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Location location = new Location();
  LocationData position;
  try {
    position = await location.getLocation() ;
    print(position);
    print("Erreur: $e");
  } on PlatformException catch(e) {
    print("Erreur: $e");
  }
  if (position != null) {
    final latitude = position.latitude;
    final longitude = position.longitude;
    final Coordinates coordinates = new Coordinates(latitude, longitude);
    final ville = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    if (ville != null) {
      print(ville.first.locality);
      runApp(new MyApp(cities.first.locality));
    }
  }
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Météo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'App Météo'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<String> cities = [];
  String chosenCity;
  String key = "villes";
  Location location;
  LocationData position;
  Stream<LocationData> stream;

  @override
  void initState() async {
    // TODO: implement initState
    super.initState();
    get();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(widget.title),
        ),
        drawer: new Drawer(
          child: new Container(
            child: new ListView.builder(
                itemCount: cities.length + 2,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return new DrawerHeader(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget> [
                            new CustomText('Mes villes', fontSize: 22.0),
                            new ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.white
                                ),
                                onPressed: addCity,
                                child: new CustomText("Ajouter une ville", color: Colors.blue)
                            )
                          ],
                        )
                    );
                  } else if (i == 1) {
                    return new ListTile(
                      title: new CustomText("Ma ville actuelle"),
                      onTap: () {
                        setState(() {
                          chosenCity = null;
                          Navigator.pop(context);
                        });
                      },
                    );
                  } else {
                    String city = cities[i-2];
                    return ListTile(
                      title: new CustomText(city),
                      trailing: new IconButton(
                          icon: new Icon(Icons.delete_rounded, color: Colors.white),
                          onPressed: (() => remove(city))
                      ),
                      onTap: () {
                        setState(() {
                          chosenCity = city;
                          Navigator.pop(context);
                        });
                      },
                    );
                  }
                }
            ),
            color: Colors.blue,
          ),
        ),
        body: new Center(
          child: new Text((chosenCity == null)?"Ville actuelle": chosenCity),
        )
    );
  }

  Future<Null> addCity() async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext buildContext) {
          return new SimpleDialog(
            contentPadding: EdgeInsets.all(20.0),
            title: new CustomText("Ajoutez une ville", fontSize: 22.0, color: Colors.blue),
            children: <Widget>[
              new TextField(
                decoration: new InputDecoration(labelText: "Ville :"),
                onSubmitted: (String str){
                  add(str);
                  Navigator.pop(buildContext);
                },
              )
            ],
          );
        }
    );
  }

  void get() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> list = await sharedPreferences.getStringList(key);
    if(list != null){
      setState(() {
        cities = list;
      });
    }
  }

  void add(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.add(str);
    await sharedPreferences.setStringList(key, cities);
    get();
  }

  void remove(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.remove(str);
    await sharedPreferences.setStringList(key, cities);
    get();
  }
}

