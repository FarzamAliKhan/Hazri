// Google ML Vision Face Detection and recognition app
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:io';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:flutter/material.dart';

enum Detector {
  face,
}

//Draw Face rectangle with Name on it
class FaceDetectorNormalPainter extends CustomPainter {
  FaceDetectorNormalPainter(this.imageSize, this.results, this.camPos);
  final Size imageSize;
  double scaleX, scaleY;
  dynamic results;
  bool camPos;

  Face face;
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;
    //print('=============Painter() size: $size =============');
    for (String label in results.keys) {
      for (Face face in results[label]) {
        // face = results[label];
        scaleX = size.width / imageSize.width;
        scaleY = size.height / imageSize.height;
        if (label == "NOT RECOGNIZED") {
          paint.color = Colors.purple;
        }
        if (Platform.isAndroid && !camPos) {
          canvas.drawRRect(
              _scaleRect(
                  rect: face.boundingBox,
                  imageSize: imageSize,
                  widgetSize: size,
                  scaleX: scaleX,
                  scaleY: scaleY,
                  cameraPosition: camPos
              ),
              paint);
        } else if (Platform.isIOS || camPos) {
          canvas.drawRect(
              _scaleRect(
                  rect: face.boundingBox,
                  imageSize: imageSize,
                  widgetSize: size,
                  scaleX: scaleX,
                  scaleY: scaleY,
                  cameraPosition: camPos
              ),
              paint);
        }
        TextSpan span = TextSpan(
            style: TextStyle(color: Colors.red[600], fontSize: 20,
                fontWeight: FontWeight.bold),
            text: label);
        TextPainter textPainter = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        textPainter.layout();
        if(Platform.isIOS || camPos) {
        textPainter.paint(
            canvas,
            Offset(
                (10 + face.boundingBox.left.toDouble()) * scaleX,
                (face.boundingBox.top.toDouble() - 15) * scaleY));
        } else if (Platform.isAndroid && !camPos) {
          textPainter.paint(
              canvas,
              Offset(
                  size.width - (70 + face.boundingBox.left.toDouble()) * scaleX,
                  (face.boundingBox.top.toDouble() - 0) * scaleY));
        }
      }
    }
  }

  @override
  bool shouldRepaint(FaceDetectorNormalPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.results != results;
  }
}

dynamic _scaleRect({@required Rect rect, @required Size imageSize, @required Size widgetSize, double scaleX, double scaleY, bool cameraPosition}) {
  RRect _rRect;
  Rect _rect;
  dynamic result;
  if (Platform.isAndroid && !cameraPosition ) {
    _rRect = RRect.fromLTRBR(
        (widgetSize.width - rect.left.toDouble() * scaleX),
        rect.top.toDouble() * scaleY,
        widgetSize.width - rect.right.toDouble() * scaleX,
        rect.bottom.toDouble() * scaleY,
        Radius.circular(10));
    result = _rRect;
  } else if (Platform.isIOS || cameraPosition) {
    _rect = Rect.fromLTRB(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.right * scaleX,
      rect.bottom * scaleY,
    );
    result = _rect;
  }
  return result;
}
