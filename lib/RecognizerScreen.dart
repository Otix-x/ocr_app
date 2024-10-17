import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecognizerScreen extends StatefulWidget {
  File image;
  RecognizerScreen(this.image, {super.key});

  @override
  State<RecognizerScreen> createState() => _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {
  late TextRecognizer textRecognizer;
  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    doTextRecognition();
  }

  String results = '';

  doTextRecognition() async {
    InputImage inputImage = InputImage.fromFile(this.widget.image);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    results = recognizedText.text;
    print(results);
    setState(() {
      results;
    });
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Recognizer',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Image.file(this.widget.image),
              Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      color: Colors.blueAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.document_scanner_outlined,
                              color: Colors.white,
                            ),
                            const Text(
                              'Results',
                              style: TextStyle(color: Colors.white),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: results));
                                SnackBar snackBar = const SnackBar(
                                  content: Text('Copied to clipboard'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                              child: const Icon(
                                Icons.copy,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      results,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
