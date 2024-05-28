import 'dart:io';

import 'package:capture_image/result_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';

class RecognizerScreen extends StatefulWidget {
  File image;
  RecognizerScreen(this.image, {super.key});

  @override
  State<RecognizerScreen> createState() => _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {
  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      compressQuality: 70,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.greenAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ],
    );
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title:
            const Text('Process Image', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                child: Image.file(widget.image),
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
                          Icons.crop,
                          size: 35,
                          color: Colors.white,
                        ),
                        onTap: () async {
                          File? file =
                              await _cropImage(imageFile: widget.image);
                          if (file != null) {
                            File image = File(file.path);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (ctx) {
                              return RecognizerScreen(image);
                            }));
                          }
                        }),
                    InkWell(
                      child: const Icon(
                        Icons.check_box_outlined,
                        size: 35,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        File file = await _processImage();
                        print(file.path);
                        if (file != null) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (ctx) {
                            return ResultScreen(file);
                          }));
                        }
                      },
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.rotate_left,
                        size: 35,
                        color: Colors.white,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _processImage() async {
  //   final inputImage = InputImage.fromFile(widget.image);
  //   final textRecognizer = TextRecognizer();
  //   final RecognizedText recognizedText =
  //       await textRecognizer.processImage(inputImage);
  //   String extractedText = recognizedText.text;
  //   print(extractedText);
  // }
  Future<File> _processImage() async {
    final inputImage = InputImage.fromFile(widget.image);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String extractedText = recognizedText.text;
    // Save extracted text into a PDF file
    final pdf = pw.Document();
    final font = await rootBundle.load("assets/fonts/arial.ttf");

    Uint8List? _logoBytes;

// Load the logo image bytes
    _loadLogoBytes() async {
      ByteData logoData =
          await rootBundle.load('assets/images/splash/logo.png');
      _logoBytes = logoData.buffer.asUint8List();
    }

// Call _loadLogoBytes() before adding the page
    await _loadLogoBytes();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.only(bottom: 8, left: 30),
                  height: 100,
                  child: _logoBytes != null
                      ? pw.Image(pw.MemoryImage(_logoBytes!))
                      : pw.PdfLogo(), // Assuming PdfLogo is a fallback when logoBytes is null
                ),
                pw.Container(
                  child: pw.Text(
                    extractedText,
                    style: pw.TextStyle(
                      fontFallback: [
                        pw.Font.ttf(font),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    Directory? root = await getExternalStorageDirectory();
    String path = '${root?.path}/test.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
