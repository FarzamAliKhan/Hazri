// Google ML Vision Face Detection and recognition app
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// TO-DO: Add Anti-spoofing to detect not human face in face recognition

// @dart=2.9

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiver/collection.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'detector_painters.dart';
import 'detector_utils.dart';

enum Choice {
  view,
  delete,
  landmarkFace,
  normalFace,
}

bool _landMarkFace = false;

class CaptureAttendance extends StatefulWidget {
  const CaptureAttendance({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CaptureAttendanceState();
}

class _CaptureAttendanceState extends State<CaptureAttendance>
    with WidgetsBindingObserver {
  File jsonFile;
  dynamic data = {};
  double threshold = 1.0;
  Directory _savedFacesDir;
  List _predictedData;
  tfl.Interpreter interpreter;
  final TextEditingController _name = new TextEditingController();
  dynamic _scanResults;
  CameraController _camera;
  Detector _currentDetector = Detector.face;
  bool _isDetecting = false;
  final CameraLensDirection _direction = CameraLensDirection.back;
  bool _faceFound = false;
  bool _camPos = false; //FALSE means Front Camera and TRUE means Back Camera
  String _displayBase64FaceImage = "";
  String _faceName = "Not Recognized";
  bool _addFaceScreen = false;
  String spoofDetectOutput;
  List<String> recognizedFaceNames = [];

  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FaceDetector _faceDetector =
      GoogleVision.instance.faceDetector(const FaceDetectorOptions(
    enableLandmarks: true,
    enableContours: true,
    enableTracking: true,
    enableClassification: false,
    mode: FaceDetectorMode.accurate,
  ));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController camController = _camera;
    if (camController == null || !camController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        print("App is in resumed");
        _currentDetector = Detector.face;
        _initializeCamera();
        break;
      case AppLifecycleState.inactive:
        print("App is in inactive - no need to do anything");
        break;
      case AppLifecycleState.paused:
        print("App is in paused - dispose Camera Controller and ImageStream");
        if (camController != null) {
          camController.stopImageStream();
          camController.dispose();
        }
        break;
      case AppLifecycleState.detached:
        print("App is in detached");
        break;
    }
  }

  Future loadModel() async {
    try {
      this.interpreter =
          await tfl.Interpreter.fromAsset('assets/mobilefacenet.tflite');

      print(
          '**********\n Loaded successfully model mobilefacenet.tflite \n*********\n');
    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  Future<void> _initializeCamera() async {
    await loadModel();
    if (_camera != null) {
      await _camera.dispose();
    }
    final CameraDescription description =
        await ScannerUtils.getCamera(_direction);

    if (_direction == CameraLensDirection.front) {
      _camPos = false;
    } else {
      _camPos = true;
    }

    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.low,
      enableAudio: false,
    );

    void showInSnackBar(String message) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    _camera.addListener(() {
      if (mounted) setState(() {});
      if (_camera.value.hasError) {
        showInSnackBar('Camera error ${_camera.value.errorDescription}');
      }
    });

    await _camera.initialize();
    //Load file from assets directory to store the detected faces
    _savedFacesDir = await getApplicationDocumentsDirectory();
    String _fullPathSavedFaces = _savedFacesDir.path + '/savedFaces.json';
    jsonFile = new File(_fullPathSavedFaces);

    if (jsonFile.existsSync()) {
      data = json.decode(jsonFile.readAsStringSync());
      print('Saved faced from memory: ' + data.toString());
    }
    await _camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      _isDetecting = true;

      String res;
      dynamic finalResults = Multimap<String, Face>();

      ScannerUtils.detect(
        image: image,
        detectInImage: _getDetectionMethod(),
        imageRotation: description.sensorOrientation,
      ).then(
        (dynamic results) {
          if (_currentDetector == null) return;
          if (results.length == 0) {
            _faceFound = false;
          } else {
            _faceFound = true;
          }
          // Start storing faces and use Tensorflow to recognize
          var croppedBoundary = 0;
          Face _face;
          imglib.Image convertedImage = _convertCameraImage(image, _direction);
          /*
          if (Platform.isIOS) {
            if (!_camPos) {
              convertedImage = imglib.copyRotate(convertedImage, 90);
            } else {
              convertedImage = imglib.copyRotate(convertedImage, -90);
            }
          }
          */
          for (_face in results) {
            double x, y, w, h;
            x = (_face.boundingBox.left - croppedBoundary);
            y = (_face.boundingBox.top - croppedBoundary);
            w = (_face.boundingBox.width + croppedBoundary);
            h = (_face.boundingBox.height + croppedBoundary);
            imglib.Image croppedImage;
            if (Platform.isAndroid) {
              croppedImage = imglib.copyCrop(convertedImage,
                  x: x.round(),
                  y: y.round(),
                  width: w.round(),
                  height: h.round());
            } else {
              croppedImage = imglib.copyCrop(convertedImage,
                  x: x.round(),
                  y: y.round(),
                  width: w.round(),
                  height: h.round());
            }
            //Store detected face into
            _displayBase64FaceImage = base64Encode(imglib.encodeJpg(
                imglib.copyResize(croppedImage, width: 200, height: 200)));

            croppedImage = imglib.copyResizeCropSquare(croppedImage, size: 112);
            // int startTime = new DateTime.now().millisecondsSinceEpoch;
            res = _recognizeFace(croppedImage);
            _faceName = res;
            //Judge the detected face for anti spoofing purpose

            // int endTime = new DateTime.now().millisecondsSinceEpoch;
            // print("Inference took ${endTime - startTime}ms");
            finalResults.add(res, _face);
          }
          setState(() {
            _scanResults = finalResults;
          });
        },
      ).whenComplete(() => Future.delayed(
          const Duration(
            milliseconds: 100,
          ),
          () => {_isDetecting = false}));
    });
  }

  Future<dynamic> Function(GoogleVisionImage image) _getDetectionMethod() {
    return _faceDetector.processImage;
  }

  Widget _buildResults() {
    const Text noResultsText = Text('No results!');

    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }

    CustomPainter painter;

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );

    assert(_currentDetector == Detector.face);

    if (_landMarkFace)
      painter = FaceDetectorLandmarkPainter(imageSize, _scanResults, _camPos);
    else
      painter = FaceDetectorNormalPainter(imageSize, _scanResults, _camPos);

    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ?  Center(
              child: Text(
                'Initializing Camera...',
                style: GoogleFonts.ubuntu(
                    color: const Color(0xff508AA8), fontWeight: FontWeight.bold, fontSize: 30),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                _buildResults(),
              ],
            ),
    );
  }

  Widget _buildStack() {
    return Stack(
      alignment: const Alignment(-1, 1),
      children: [
        _buildImage(),
        CircleAvatar(
          backgroundColor: const Color(0xff9DD1F1),
          radius: 50,
          child: CircleAvatar(
            backgroundColor: Colors.black12,
            //backgroundImage: AssetImage('assets/face.jpg'),
            foregroundImage:
                (_displayBase64FaceImage != "" && _faceFound && !_addFaceScreen
                    ? MemoryImage(base64Decode(_displayBase64FaceImage))
                    : const AssetImage('assets/background.jpg')),
            radius: 48,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.black45,
          ),
          child: Text(
            // ignore: prefer_if_null_operators
            (spoofDetectOutput != null ? spoofDetectOutput : _faceName),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Capture Attendance',
            style: GoogleFonts.ubuntu(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff508AA8),
          centerTitle: true,
          shadowColor: Colors.blueGrey,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: true,
        ),
        body: _buildStack(),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: (_faceFound) ? const Color(0xff508AA8) : Colors.blueGrey[300],
            child: const Icon(Icons.camera_sharp, color: Colors.white,),
            onPressed: () {
              if (_faceFound) {
                setState(() {
                  _camera = null;
                });

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xff508AA8),
                      title: Text(
                        'Mark Attendance',
                        style: GoogleFonts.ubuntu(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      
                      scrollable: true,
                      content: Column(
                        children: [
                         const Divider(color: Colors.white,thickness: 2),
                          if (uniqueRecognizedFaceNames.isEmpty)
                            const Text('No faces recognized yet.'),
                          for (String faceName in uniqueRecognizedFaceNames)
                            if (faceName != "NOT RECOGNIZED")
                              ListTile(
                                title: Text(faceName, style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            uniqueRecognizedFaceNames.clear();
                            _initializeCamera();
                            Navigator.pop(context);
                          },
                          child:  Text('Close', style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            uniqueRecognizedFaceNames.clear();
                           _initializeCamera();
                            Navigator.pop(context);
                          },
                          child:  Text('Save', style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          const SizedBox(
            height: 10,
          ),
        ]));
  }

  void _addRecognizedFaceName(String faceName) {
    setState(() {
      recognizedFaceNames.add(faceName);
    });
  }

  List<String> uniqueRecognizedFaceNames = [];

  // Existing code...

  String _recognizeFace(imglib.Image img) {
    List input = ScannerUtils.imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    interpreter.run(input, output);
    output = output.reshape([192]);
    _predictedData = List.from(output);

    String recognizedFaceName =
        _compareExistSavedFaces(_predictedData).toUpperCase();

    if (!uniqueRecognizedFaceNames.contains(recognizedFaceName)) {
      uniqueRecognizedFaceNames.add(recognizedFaceName);
      _addRecognizedFaceName(recognizedFaceName);
    }

    return recognizedFaceName;
  }

  String _compareExistSavedFaces(List currEmb) {
    if (data.length == 0) return "No Face saved";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";
    for (String label in data.keys) {
      currDist = ScannerUtils.euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    if (kDebugMode) {
      print("$minDist $predRes");
    }
    return predRes;
  }

  imglib.Image _convertCameraImage(
      CameraImage image, CameraLensDirection _dir) {
    try {
      imglib.Image img;
      if (image.format.group == ImageFormatGroup.yuv420) {
        img = _convertYUV420(image, _dir);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        img = _convertBGRA8888(image, _dir);
      }

      return img;
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }

  static imglib.Image _convertBGRA8888(
      CameraImage image, CameraLensDirection _dir) {
    var img = imglib.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes as ByteBuffer,
      order: imglib.ChannelOrder.bgra,
    );

    //var img1 = (_dir == CameraLensDirection.front)
    //    ? imglib.copyRotate(img, -90)
    //    : imglib.copyRotate(img, 90);
    return img;
  }

  imglib.Image _convertYUV420(CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    var img = imglib.Image(width: width, height: height);
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

        img.setPixelRgba(x, y, r, (g << 8), (b << 16), hexFF);
        //img.data[index] = hexFF | (b << 16) | (g << 8) | r;
        //img = (data[index] = hexFF | (b << 16) | (g << 8) | r) as imglib.Image;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)
        ? imglib.copyRotate(img, angle: -90)
        : imglib.copyRotate(img, angle: 90);
    return img1;
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _camera.dispose().then((_) {
      _faceDetector.close();
    });
    _currentDetector = null;
    recognizedFaceNames.clear();
  }
}
