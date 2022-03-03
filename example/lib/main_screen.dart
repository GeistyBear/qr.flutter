/*
 * QR.Flutter
 * Copyright (c) 2022 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// This is the screen that you'll see when the app starts
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tapCount = 0;
  Timer? _tapTimer;
  String _defaultInstructions = "Scan the QR code";
  String _instructions = "Scan the QR code";

  @override
  Widget build(BuildContext context) {
    final codeMessage =
        // ignore: lines_longer_than_80_chars
        'How much wood would a woodchuck chuck if a woodchuck could chuck wood?';

    final qrFutureBuilder = FutureBuilder<ui.Image>(
      future: _loadOverlayImage(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final appearance = QrAppearance(
          gapSize: 2,
          moduleStyle: QrDataModuleStyle(
            colors: QrColors.sequence([
              Color(0xFF0E664B),
              Color(0xFF008253),
              Color(0xFF2AB689),
              Color(0xFF7BD4AB),
            ], direction: Axis.vertical),
            shape: QrDataModuleShape.circle,
          ),
          markerStyle: QrMarkerStyle(
            color: Color(0xFF0E664B),
            shape: QrMarkerShape.roundedRect,
            gap: 2,
          ),
          markerDotStyle: QrMarkerDotStyle(
            color: Color(0xFF339C7A),
            shape: QrMarkerDotShape.roundedRect,
          ),
          embeddedImageStyle: QrEmbeddedImageStyle(
            size: Size.square(72),
            drawOverModules: false,
          ),
        );

        return GestureDetector(
          onTap: onCodeTapped,
          child: AspectRatio(
              aspectRatio: 1,
              child: QrImageView(
                data: codeMessage,
                appearance: appearance,
              )),
        );
      },
    );

    // CustomPaint(
    //   painter: QrPainter(
    //     data: codeMessage,
    //     version: QrVersions.auto,
    //     errorCorrectionLevel: QrErrorCorrectLevel.L,
    //     embeddedImage: snapshot.data,
    //     appearance: appearance,
    //   ),
    // ),

    return Material(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 480, minWidth: 200),
                    child: qrFutureBuilder,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40)
                    .copyWith(bottom: 40),
                child: Text(_instructions),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load('assets/images/4.0x/logo_yakka.png');
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }

  void onCodeTapped() {
    _tapTimer?.cancel();
    _tapTimer = Timer(Duration(seconds: 3), () {
      _tapCount = 0;
    });
    _tapCount++;
    if (_tapCount >= 5) {
      setState(() {
        _instructions = "Keep tapping ...";
      });
    }
    if (_tapCount == 10) {
      setState(() {
        _instructions = _defaultInstructions;
      });
      _tapTimer?.cancel();
      _tapCount = 0;
      launch("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
    }
  }
}
