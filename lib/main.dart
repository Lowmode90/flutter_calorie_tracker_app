import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      print("Nous sommes sur iOS");
    } else {
      print("Nous ne sommes pas sur iOS");
    }
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('fr'),
        const Locale('en')
      ],
      debugShowCheckedModeBanner: false,
      title: 'Calorie Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'Calorie Tracker')
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int calorieBase;
  int calorieWithActivity;
  int selectedRadio;
  double weight;
  double age;
  bool gender = false;
  double userHeight = 170.0;

  Map mapActivity = {
    0: "Faible",
    1: "Modérée",
    2: "Forte"
  };

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: (() => FocusScope.of(context).requestFocus(new FocusNode())),
      child: (Platform.isIOS) ? new CupertinoPageScaffold(
            navigationBar: new CupertinoNavigationBar(
            backgroundColor: setColor(),
            middle: styledText(widget.title),
            ),
            child: body()
      )
      : new Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: setColor(),
          ),
          body: body()
      )
    );
  }

  Widget body() {
    return new SingleChildScrollView(
      padding: EdgeInsets.all(15.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          padding(),
          styledText("Remplissez tous les champs pour obtenir votre besoin journalier en calories."),
          padding(),
          new Card(
            elevation: 10.0,
            child: new Column(
              children: <Widget>[
                padding(),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    styledText("Femme", color: Colors.teal),
                    switchDependingOnPlatform(),
                    styledText("Homme", color: Colors.indigo)
                  ],
                ),
                padding(),
                ageButton(),
                padding(),
                styledText("Votre taille est de : ${userHeight.toInt()} cm", color: setColor()),
                padding(),
                sliderDependingOnPlatform(),
                padding(),
                new TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (String string) {
                    setState(() {
                      weight = double.tryParse(string);
                    });
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: new InputDecoration(
                      labelText: "Entrez votre poids en kilos.",
                      contentPadding: EdgeInsets.only(left: 15.0)
                  ),
                ),
                padding(),
                styledText("Quelle est votre activité sportive?", color: setColor()),
                padding(),
                rowRadio(),
                padding()
              ],
            ),
          ),
          padding(),
          calcButton()
        ],
      ),
    );
  }

  Padding padding() {
    return new Padding(padding: EdgeInsets.only(top: 20.0));
  }
  
  Future<Null> showPicker() async {
    DateTime choice = await showDatePicker(
      context: context,
      locale: const Locale("fr", "FR"),
      initialDate: new DateTime.now(),
      firstDate: new DateTime(1900),
      lastDate: new DateTime.now(),
      initialDatePickerMode: DatePickerMode.year
    );
    if (choice != null) {
      var difference = new DateTime.now().difference(choice);
      var days = difference.inDays;
      var years = (days / 365.25);
      setState(() {
        age = years;
      });
    }
  }

  Color setColor() {
    if (gender) {
      return Colors.indigo;
    } else {
      return Colors.teal;
    }
  }

  Widget sliderDependingOnPlatform() {
    if (Platform.isIOS) {
      return new CupertinoSlider(
          value: userHeight,
          activeColor: setColor(),
          onChanged: (double d) {
            setState(() {
              userHeight = d;
            });
          },
        min: 100.0,
        max: 215.0
      );
    } else {
      return new Slider(
        value: userHeight,
        activeColor: setColor(),
        onChanged: (double d) {
          setState(() {
            userHeight = d;
          });
        },
        max: 215.0,
        min: 100.0,
      );
    }
  }

  Widget switchDependingOnPlatform() {
    if (Platform.isIOS) {
      return new CupertinoSwitch(
          value: gender,
          activeColor: Colors.indigo,
          onChanged: (bool b) {
            setState(() {
              gender = b;
            });
          }
      );
    } else {
      return new Switch(
          value: gender,
          inactiveTrackColor: Colors.teal,
          activeColor: Colors.indigo,
          onChanged: (bool b) {
            setState(() {
              gender = b;
            });
          }
      );
    }
  }

  Widget styledText(String data, {color: Colors.black, fontSize: 15.0}) {
    if (Platform.isIOS) {
      return new DefaultTextStyle(
          style: new TextStyle(
            color: color,
            fontSize: fontSize
          ),
          child: new Text(
              data,
              textAlign: TextAlign.center)
      );
    } else {
      return new Text(
          data,
          textAlign: TextAlign.center,
          style: new TextStyle(
              color: color,
              fontSize: fontSize
          )
      );
    }
  }

  Widget calcButton() {
    if (Platform.isIOS) {
      return new CupertinoButton(
          color: setColor(),
          child: styledText("Calculer", color: Colors.white),
          onPressed: calculateCalories
      );
    } else {
      return new ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: setColor()
          ),
          onPressed: calculateCalories,
          child: styledText("Calculer", color: Colors.white)
      );
    }
  }

  Widget ageButton() {
    if (Platform.isIOS) {
      return new CupertinoButton(
          color: setColor(),
          child: styledText((age == null) ? "Entrez votre âge" : "Vous avez : ${age.toInt()} ans",
              color: Colors.white
          ),
          onPressed: showPicker
      );
    } else {
      return new ElevatedButton(
        child: styledText((age == null) ? "Appuyez pour entrer votre âge" : "Vous avez : ${age.toInt()} ans",
            color: Colors.white
        ),
        onPressed: (()=>  showPicker()),
        style: ElevatedButton.styleFrom(primary: setColor()),
      );
    }
  }

  Row rowRadio() {
    List<Widget> l = [];
    mapActivity.forEach((key, value) {
      Column activityColumn = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Radio(
              activeColor: setColor(),
              value: key,
              groupValue: selectedRadio,
              onChanged: (Object i) {
                setState(() {
                  selectedRadio = i;
                });
              }
          ),
          styledText(value, color: setColor())
        ],
      );
      l.add(activityColumn);
    });
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: l,
    );
  }

  void calculateCalories() {
    if (age != null && weight != null && selectedRadio != null) {
      if (gender) {
        calorieBase = (66.4730 + (13.7516 * weight) + (5.0033 * userHeight) - (6.7550 * age)).toInt();
      } else {
        calorieBase = (655.0955 + (9.5634 * weight) + (1.8496 * userHeight) - (4.6756 * age)).toInt();
      }
      switch(selectedRadio) {
        case 0:
          calorieWithActivity = (calorieBase * 1.2).toInt();
          break;
        case 1:
          calorieWithActivity = (calorieBase * 1.2).toInt();
          break;
        case 2:
          calorieWithActivity = (calorieBase * 1.2).toInt();
          break;
        default:
          calorieWithActivity = calorieBase;
          break;
      }
      setState(() {
        dialog();
      });
    } else {
      alert();
    }
  }

  Future<Null> dialog() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext buildContext) {
          return SimpleDialog(
            title: styledText("Votre besoin en calories", color: setColor()),
            contentPadding: EdgeInsets.all(15.0),
            children: <Widget>[
              padding(),
              styledText("Votre besoin de base est de : $calorieBase"),
              padding(),
              styledText("Votre besoin avec activité sportive est de : $calorieWithActivity"),
              new ElevatedButton(
                onPressed: () {
                  Navigator.pop(buildContext);
                  },
                child: styledText("OK", color: Colors.white),
                style: ElevatedButton.styleFrom(
                  primary: setColor()
                ),
              )
            ],
          );
        }
    );
}
  
  Future<Null> alert() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext buildContext) {
          if (Platform.isIOS) {
            return new CupertinoAlertDialog(
              title: styledText("Erreur"),
              content: styledText("Tous les champs doivent être renseignés"),
              actions: <Widget>[
                new CupertinoButton(
                    color: Colors.white,
                    child: styledText("OK", color: Colors.red),
                    onPressed: () {
                      Navigator.pop(buildContext);
                    }
                )
              ],
            );
          } else {
            return new AlertDialog(
              title: styledText("Erreur"),
              content: styledText("Tous les champs doivent être renseignés"),
              actions: <Widget>[
                new TextButton(
                    onPressed: () {
                      Navigator.pop(buildContext);
                    },
                    child: styledText("OK", color: Colors.red))
              ],
            );
          }
        }
    );
  }
}
