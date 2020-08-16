import 'dart:async';

import 'package:assistant_iot/services/View.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(Start());

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Recognition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: App(),
//      routes: {
//        DiscoveryPage().route : (BuildContext context) => DiscoveryPage(),
//      },
    );
  }
}

class App extends StatefulWidget {
  static const routeName = '/App';

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  AnimationController _controller;
  FlutterToast flutterToast;
  bool sent = false;
  bool isInitialized = false;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String deviceAddress;
  bool status = false;
  final SpeechToText speech = SpeechToText();

  Future<void> initSpeech() async {
    await speech.initialize(onError: errorListener, onStatus: statusListener);
    await speech.locales();
    await speech.systemLocale();
  }

  void startListening() {
    setState(() {
      lastWords = "";
      sent = false;
    });
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 5),
        localeId: 'in_ID',
        cancelOnError: true,
        partialResults: true,
        onDevice: true,
        listenMode: ListenMode.confirmation);
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      print('lastWord : $lastWords');
    });
  }

  void errorListener(SpeechRecognitionError error) {
    lastError = "${error.errorMsg} - ${error.permanent}";
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = "$status";
      print(status);
    });
  }

  Future<AudioPlayer> penuh() async {
    AudioCache cache = new AudioCache();
    return await cache.play("penuh.mp3");
  }

  Future<AudioPlayer> kosong() async {
    AudioCache cache = new AudioCache();
    return await cache.play("kosong.mp3");
  }

  Future<AudioPlayer> isi() async {
    AudioCache cache = new AudioCache();
    return await cache.play("isi.mp3");
  }

  @override
  void initState() {
    super.initState();
    initSpeech();
    flutterToast = FlutterToast(context);
    _controller = AnimationController(vsync: this);
    Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      if (lastWords != "" &&
          sent == false &&
          lastStatus == 'notListening' &&
          lastWords.toLowerCase() == "cek kondisi tempat makan") {
        print('mengecek database');
        var status =
            FirebaseDatabase.instance.reference().child('/status').once();
        status.then((snapshot) {
          print(snapshot);
          if (snapshot.value)
            penuh();
          // print('penuh');
          else
            kosong();
          // print('kosong');
        });
        sent = true;
      } else if (lastWords != "" &&
          sent == false &&
          lastStatus == 'notListening' &&
          lastWords.toLowerCase() == "isi tempat makan") {
        await FirebaseDatabase.instance
            .reference()
            .child('/')
            .update({'voice': true});
        sent = true;
        print('isi');
        isi();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    View().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 4,
              child: lastStatus == 'listening'
                  ? Container(
                      child: Lottie.asset('assets/voice2.json',
                          controller: _controller
                            ..duration = Duration(seconds: 5)
                            ..forward()),
                    )
                  : Container(
                      child: Lottie.asset('assets/voice2.json',
                          controller: _controller
                            ..stop()
                            ..reset()),
                    ),
            ),
            Flexible(
                flex: 4,
                child: lastStatus == 'listening'
                    ? Text(
                        'Perintah : $lastWords\n',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: View.blockX * 5),
                      )
                    : Text(
                        'Klik tombol dibawah\n',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: View.blockX * 5),
                      )),
            Flexible(
              flex: 1,
              child: RaisedButton(
                padding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Colors.deepPurple,
                child: Text(
                  'Mulai',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: View.blockX * 7),
                ),
                onPressed: () {
                  startListening();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
