import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class ResultScreen extends StatefulWidget {
  File pdf;
  ResultScreen(this.pdf, {super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late PdfControllerPinch pdfControllerPinch =
      PdfControllerPinch(document: PdfDocument.openFile(widget.pdf.path));

  @override
  Widget build(BuildContext context) {
    print("-------------------" + widget.pdf.path);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
        title: const Text('View PDF result',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Add the PDFView widget
          Expanded(
              child: PdfViewPinch(
            controller: pdfControllerPinch,
          )),
        ],
      ),
    );
  }
}
