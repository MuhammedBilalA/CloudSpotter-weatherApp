import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_spotter/screens/constants.dart' as k;

import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoaded = false;
  num temp = 0;

  num press = 0;
  num hum = 0;
  num cover = 0;
  String cityname = 'Unknown';

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    var p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        forceAndroidLocationManager: true);
    if (p != null) {
      print('Lat:${p.latitude},Long:${p.longitude}');
      getCurrentCityWeather(p);
    } else {
      print('Data unavailable');
    }
  }

  getCityWeather(String cityname) async {
    var client = http.Client();
    var uri = '${k.domain}q=$cityname&appid=${k.apiKey}';
    var url = Uri.parse(uri);
    var response = await client.get(url);
    print(client);
    if (response.statusCode == 200) {
      var data = response.body;
      print(data);
      var decodeData = json.decode(data);
      updateUI(decodeData);
      setState(() {
        isLoaded = true;
      });
    } else {
      updateUI(null);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Enter a valid Location'),
            );
          });

      Timer(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
      print(response.statusCode);
    }
  }

  getCurrentCityWeather(Position position) async {
    var client = http.Client();
    var uri =
        '${k.domain}lat=${position.latitude}&lon=${position.longitude}&appid=${k.apiKey}';
    var url = Uri.parse(uri);
    var response = await client.get(url);
    print(client);
    if (response.statusCode == 200) {
      var data = response.body;
      print(data);
      var decodeData = json.decode(data);
      updateUI(decodeData);
      setState(() {
        isLoaded = true;
      });
    } else {
      print(response.statusCode);
    }
  }

  updateUI(var decodedData) {
    setState(() {
      if (decodedData == null) {
        temp = 0;
        press = 0;
        hum = 0;
        cover = 0;
        cityname = 'Not available';
      } else {
        temp = decodedData['main']['temp'] - 273;
        press = decodedData['main']['pressure'];
        hum = decodedData['main']['humidity'];
        cover = decodedData['clouds']['all'];
        cityname = decodedData['name'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
              Color(0xFFFA8BFF),
              Color(0xFF2BD2FF),
              Color(0xFF2BFF88),
            ])),
        // child: Visibility(
        //   visible: isLoaded,
        //   replacement: const Center(
        //     child: CircularProgressIndicator(),
        //   ),
        child: Column(
          children: [
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                    Color(0xFF2BD2FF),
                    Color.fromARGB(255, 86, 234, 150),
                    Color.fromARGB(255, 15, 243, 114),
                  ])),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                  ),
                  SizedBox(
                      height: 60,
                      width: 60,
                      child: Image.asset(
                        'assets/04n.png',
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Cloud Spotter',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Center(
                  child: TextFormField(
                    onFieldSubmitted: (String s) {
                      setState(() {
                        cityname = s;
                        getCityWeather(s.trim());
                        setState(() {
                          isLoaded = false;
                          controller.clear();
                        });
                      });
                    },
                    controller: controller,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search City',
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.pin_drop,
                    color: Colors.red,
                    size: 40,
                  ),
                  Text(
                    cityname,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.my_location_outlined,
                      size: 30,
                    ),
                    onPressed: () {
                      getCurrentLocation();
                    },
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8, right: 8),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.09,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade900,
                          offset: const Offset(1, 2),
                          blurRadius: 3,
                          spreadRadius: 1),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(18))),
                child: Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Image.asset(
                      'assets/thermometer.png',
                      width: MediaQuery.of(context).size.width * 0.09,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Temperature : ${temp.toInt()} ℃ ',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8, right: 8),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.09,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade900,
                          offset: const Offset(1, 2),
                          blurRadius: 3,
                          spreadRadius: 1),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(18))),
                child: Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Image.asset(
                      'assets/barometer.png',
                      width: MediaQuery.of(context).size.width * 0.09,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Pressure : ${press.toStringAsFixed(2)} hPa',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8, right: 8),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.09,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade900,
                          offset: const Offset(1, 2),
                          blurRadius: 3,
                          spreadRadius: 1),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(18))),
                child: Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Image.asset(
                      'assets/humidity.png',
                      width: MediaQuery.of(context).size.width * 0.09,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Humidity : ${hum.toInt()}%',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8, right: 8),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.09,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade900,
                          offset: const Offset(1, 2),
                          blurRadius: 3,
                          spreadRadius: 1),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(18))),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      'assets/cloud cover.png',
                      width: MediaQuery.of(context).size.width * 0.09,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Cloud Cover : ${cover.toInt()}%',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();

    super.dispose();
  }
}
