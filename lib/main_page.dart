import 'dart:io';

import 'package:capture_image/recognizer_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart'; // Import the camera package

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;

  late CameraController _cameraController; // Declare CameraController
  late ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
    imagePicker = ImagePicker();
  }

  @override
  void dispose() {
    _cameraController.dispose(); // Dispose camera controller
    super.dispose();
  }

  // Function to initialize camera
  Future<void>? _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController =
        CameraController(firstCamera, ResolutionPreset.max, enableAudio: false);

    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  // Function to capture image from camera
  Future<XFile?> _captureImage() async {
    try {
      // Take the picture and return an XFile containing the image data
      XFile? xfile = await _cameraController.takePicture();
      GallerySaver.saveImage(xfile.path);
      return xfile;
    } catch (e) {
      // Handle errors that may occur during image capture
      print('Error capturing image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 50, bottom: 15, left: 5, right: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
            color: Colors.greenAccent,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.scanner,
                          size: 25,
                          color: Colors.white,
                        ),
                        Text(
                          'Scan',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onTap: () {},
                  ),
                  InkWell(
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 25,
                          color: Colors.white,
                        ),
                        Text(
                          'Recognize',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onTap: () {},
                  ),
                  InkWell(
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_sharp,
                          size: 25,
                          color: Colors.white,
                        ),
                        Text(
                          'Enhance',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onTap: () {},
                  )
                ],
              ),
            ),
          ),
          Card(
            color: Colors.black,
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 300,
              child: _isPermissionGranted == true &&
                      _cameraController.value.isInitialized
                  ? CameraPreview(_cameraController) // Use CameraPreview here
                  : Container(),
            ),
          ),
          Card(
            color: Colors.greenAccent,
            child: SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: const Icon(
                      Icons.rotate_left,
                      size: 35,
                      color: Colors.white,
                    ),
                    onTap: () {},
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.camera,
                      size: 40,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      XFile? xfile = await _captureImage();
                      if (xfile != null) {
                        File image = File(xfile.path);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (ctx) {
                          return RecognizerScreen(image);
                        }));
                      }
                    },
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.image_outlined,
                      size: 35,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      XFile? xfile = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (xfile != null) {
                        File image = File(xfile.path);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (ctx) {
                          return RecognizerScreen(image);
                        }));
                      }
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
    if (_isPermissionGranted == true) {
      _initializeCamera();
    }
  }
}
