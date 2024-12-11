import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_app/cardscanner.dart';
import 'package:ocr_app/RecognizerScreen.dart';
import 'package:ocr_app/enhancescreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImagePicker imagePicker;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    initializeCamera();
  }

  late CameraController controller;
  bool isCameraReady = false;
  initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      return;
    }
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      // The underscore (_) is a placeholder for the result of the initialize() method.
      if (!mounted) {
        // If this variable is true, the camera is allocated to the application. If it is false, the camera is being used by another application.
        return;
      }
      setState(() {
        isCameraReady = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  bool scan = false;
  bool recognition = true;
  bool enhance = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 5, right: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
            color: Colors.blueAccent,
            child: Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.scanner,
                          size: 25,
                          color: scan ? Colors.white : Colors.grey.shade700,
                        ),
                        Text(
                          'Scan',
                          style: TextStyle(
                              color:
                                  scan ? Colors.white : Colors.grey.shade700),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        scan = true;
                        recognition = false;
                        enhance = false;
                      });
                    },
                  ),
                  InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 25,
                          color:
                              recognition ? Colors.white : Colors.grey.shade700,
                        ),
                        Text(
                          'Recognition',
                          style: TextStyle(
                              color: recognition
                                  ? Colors.white
                                  : Colors.grey.shade700),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        scan = false;
                        recognition = true;
                        enhance = false;
                      });
                    },
                  ),
                  InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.adf_scanner,
                          size: 25,
                          color: enhance ? Colors.white : Colors.grey.shade700,
                        ),
                        Text(
                          'Enhance',
                          style: TextStyle(
                              color: enhance
                                  ? Colors.white
                                  : Colors.grey.shade700),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        scan = false;
                        recognition = false;
                        enhance = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.black,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: MediaQuery.of(context).size.height - 300,
                    child: isCameraReady
                        ? AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: CameraPreview(controller),
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
          Card(
            color: Colors.blueAccent,
            child: Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: const Icon(
                      Icons.rotate_right_sharp,
                      size: 30,
                      color: Colors.white,
                    ),
                    onTap: () {},
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      await controller.takePicture().then(
                        (value) {
                          if (value != null) {
                            File image = File(value.path);
                            processImage(image);
                          }
                        },
                      );
                    },
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.image_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      XFile? xfile = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (xfile != null) {
                        File image = File(xfile.path);
                        processImage(image);
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // function to process image
  processImage(File image) async {
    final editedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropper(
          image: image.readAsBytesSync(), // <-- Uint8List of image
        ),
      ),
    );

    image.writeAsBytes(editedImage); // <-- Update image

    if (recognition) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) {
            return RecognizerScreen(image);
          },
        ),
      );
    } else if (scan) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) {
            return CardScanner(image);
          },
        ),
      );
    } else if (enhance) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) {
            return EnhanceScreen(image);
          },
        ),
      );
    }
  }
}
