import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ocr_app/helper/database_helper.dart';
import 'package:ocr_app/viewdatabasescreen.dart';

class CardScanner extends StatefulWidget {
  File image;
  CardScanner(this.image);

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner> {
  late TextRecognizer textRecognizer;
  late EntityExtractor entityExtractor;
  List<EntityDM> entitiesList = [];
  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    entityExtractor =
        EntityExtractor(language: EntityExtractorLanguage.english);
    doTextRecognition();
  }

  String results = '';

  doTextRecognition() async {
    InputImage inputImage = InputImage.fromFile(this.widget.image);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    entitiesList.clear();
    results = recognizedText.text;

    final List<EntityAnnotation> annotations =
        await entityExtractor.annotateText(results);

    results = '';

    for (final annotation in annotations) {
      annotation.start;
      annotation.end;
      annotation.text;
      for (final entity in annotation.entities) {
        results += entity.type.name + "\n" + annotation.text + "\n\n";
        entitiesList.add(
          EntityDM(entity.type.name, annotation.text),
        );
      }
    }

    print(results);
    setState(() {
      results;
    });
  }

  _importToDatabase() async {
    for (var entity in entitiesList) {
      await DatabaseHelper().insertCardData(entity.name, entity.value);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data imported to database successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Card Scanner',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Image.file(this.widget.image),
              ListView.builder(
                itemBuilder: (context, position) {
                  return Card(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                    color: Colors.blueAccent,
                    child: Container(
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              entitiesList[position].iconData,
                              color: Colors.white,
                              size: 20,
                            ),
                            Expanded(
                              child: Text(
                                entitiesList[position].value,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: entitiesList[position].value));
                                const SnackBar snackBar = SnackBar(
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
                  );
                },
                itemCount: entitiesList.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
              ),
              Container(
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _importToDatabase,
                        child: const Text("Import"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final data = await DatabaseHelper().fetchAllData();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewDatabaseScreen(
                                data,
                                onDataUpdate: () async {
                                  final updatedData =
                                      await DatabaseHelper().fetchAllData();
                                  setState(() {
                                    // Cập nhật lại danh sách dữ liệu trong CardScanner
                                    data.clear();
                                    data.addAll(updatedData);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text("View/Export"),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EntityDM {
  String name;
  String value;
  IconData? iconData;

  EntityDM(this.name, this.value) {
    if (name == "phone") {
      iconData = Icons.phone;
    } else if (name == "email") {
      iconData = Icons.email;
    } else if (name == "url") {
      iconData = Icons.web;
    } else if (name == "address") {
      iconData = Icons.location_on;
    } else if (name == "date") {
      iconData = Icons.date_range;
    } else if (name == "time") {
      iconData = Icons.access_time;
    } else {
      iconData = Icons.info;
    }
  }
}
