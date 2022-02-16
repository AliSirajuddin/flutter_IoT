import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:battery/battery.dart';
import 'package:percent_indicator/percent_indicator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

/// main application widget
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Application';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        body: MyStatefulWidget(),
        backgroundColor: Color(0xFFE8F5F8),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final dbref = FirebaseDatabase.instance.ref("device");

  @override
  void initState() {
    super.initState();
    temperatureData();
    valueData();
    batteryData();
    chargeData();
  }

  String suhu = "here";
  bool isSwitch = true;
  var battery = Battery();
  int batteryval = 0;
  bool isCharge = true;

  void temperatureData() {
    dbref.child("temperature").onValue.listen((event) {
      final String temp = event.snapshot.value.toString();
      setState(() {
        suhu = temp;
      });
    });
  }

  void valueData() {
    dbref.child("lampu1").onValue.listen((event) {
      final String val = event.snapshot.value.toString();
      setState(() {
        if (val == "true") {
          isSwitch = true;
        } else {
          isSwitch = false;
        }
      });
    });
  }

  void chargeData() {
    dbref.child("chargeStat").onValue.listen((event) {
      final String val = event.snapshot.value.toString();
      setState(() {
        if (val == "true") {
          isCharge = true;
        }
        if (batteryval == 100) {
          isCharge = false;
        } else {
          isCharge = false;
        }
      });
    });
  }

  void batteryData() async {
    final batteryLevel = await battery.batteryLevel;
    this.batteryval = batteryLevel;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Center(
      child: Column(
        children: <Widget>[
          _widgetHeader(mediaQuery),
          _widgetCardBattry(mediaQuery),
          _widgetCardRelay(mediaQuery)
        ],
      ),
    );
  }

  Widget _widgetHeader(MediaQueryData mediaQuery) {
    return Container(
        width: double.infinity,
        height: mediaQuery.size.height / 3,
        margin: EdgeInsets.only(top: 24.0),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Color(0xFF74CAC5),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0)),
            image: DecorationImage(
                image: AssetImage('assets/images/rumah_header_crop.png'),
                alignment: Alignment.bottomRight)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 16.0),
              child: Text(
                "Home\nAutomation",
                style: TextStyle(
                    fontFamily: "poppinsMedium", fontSize: 40, height: 1.2),
              ),
            ),
          ],
        ));
  }

  Widget _widgetCardBattry(MediaQueryData mediaQuery) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16),
            height: mediaQuery.size.height / 5,
            width: mediaQuery.size.width / 3,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Color(0xFFF9FBED),
              elevation: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularPercentIndicator(
                      radius: 75,
                      percent: batteryval / 100,
                      progressColor:
                          batteryval >= 20 ? Color(0xFF74CAC5) : Colors.red,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      center: Text(
                        batteryval.toString() + "%",
                        style: TextStyle(
                            fontFamily: "poppinsMedium", fontSize: 20),
                      ),
                    ),
                  ),
                  Container(
                      height: mediaQuery.size.height / 24,
                      width: mediaQuery.size.height / 24,
                      decoration: BoxDecoration(
                          color:
                              isCharge ? Color(0xFF74CAC5) : Color(0xFFF9FBED),
                          borderRadius: BorderRadius.circular(100),
                          border:
                              Border.all(color: Color(0xFF74CAC5), width: 2)),
                      child: new RawMaterialButton(
                        shape: new CircleBorder(),
                        elevation: 0.0,
                        child: new Icon(
                          Icons.power,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              isCharge = !isCharge;
                              dbref.update({"chargeStat": isCharge.toString()});
                            },
                          );
                        },
                      )),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            height: mediaQuery.size.height / 5,
            width: mediaQuery.size.width / 3,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Color(0xFFF9FBED),
              elevation: 2,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 12.0, top: 20),
                    child: Text(
                      "Room\nTemperature:",
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "poppinsMedium",
                          height: 1.2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        width: 48,
                        height: 68,
                        child: Text(
                          suhu,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 36,
                              fontFamily: "poppinsSemiBold",
                              color: Colors.black,
                              height: 1),
                        ),
                      ),
                      Text(
                        "°C",
                        style: TextStyle(
                            fontSize: 28,
                            fontFamily: "poppinsSemiBold",
                            color: Colors.black,
                            height: 1.2),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetCardRelay(MediaQueryData mediaQuery) {
    return Container(
      width: mediaQuery.size.width * 7 / 8,
      height: 52,
      margin: EdgeInsets.only(top: 24),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Color(0xFFF9FBED),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15)),
                      image: DecorationImage(
                          image: AssetImage('assets/images/lamp_crop.png'),
                          fit: BoxFit.cover)),
                  height: 48,
                  width: 32,
                  alignment: Alignment.bottomLeft,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    "Lampu 1",
                    style: TextStyle(fontFamily: "poppinsMedium", fontSize: 32),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Switch(
                    value: isSwitch,
                    onChanged: (value) {
                      setState(() {
                        isSwitch = value;
                        dbref.update({"lampu1": isSwitch.toString()});
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  battContainer(double _height, IconData icon, bool hasglow) {
    return Container(
      width: _height / 7,
      height: _height / 7,
      child: Icon(
        icon,
      ),
    );
  }
}
