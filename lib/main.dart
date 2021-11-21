// ignore_for_file: prefer_const_constructors, avoid_print, library_prefixes

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

import 'package:permission_handler/permission_handler.dart';

const appId = "916c6de9bb5649d7a1fbbac0f8054804";
const token =
    "006916c6de9bb5649d7a1fbbac0f8054804IACewVjz5mqUYORK+qHFyiIM4YRTye8qy1KgKGRGKZU6VgZa8+gAAAAAEADsTG0XnAabYQEAAQCcBpth";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Vidio Call ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();
    //create the engine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(token, "testing", null, 0);
  }

  @override
  Widget build(BuildContext context) {
    // / Display remote user's video
    Widget _remoteVideo() {
      if (_remoteUid != null) {
        return RtcRemoteView.SurfaceView(uid: _remoteUid!);
      } else {
        return Text(
          'Please wait for remote user to join',
          textAlign: TextAlign.center,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? RtcLocalView.SurfaceView()
                    : CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
