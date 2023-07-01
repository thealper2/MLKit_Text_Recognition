import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MLKit Text Recognition'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  String result = '';
  late ImagePicker imagePicker;

  dynamic textRecognizer;
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    textRecognizer = GoogleMlKit.vision.textRecognizer();
  }

  pickImage(bool fromGallery) async {
    XFile? pickedFile = await imagePicker.pickImage(source: fromGallery ? ImageSource.gallery : ImageSource.camera);
    File image = File(pickedFile!.path);
    setState(() {
      _image = image;
      if (_image != null) {
        textRecognition();
      }
    });
  }

  textRecognition() async {
    InputImage inputImage = InputImage.fromFile(_image!);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    result = "";
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          result += element.text + " ";
        }
        result += "\n";
      }
      result += "\n";
    }
    setState(() {
      result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
         child: Text(widget.title),
        )
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _image != null
              ? Image.file(_image!)
              : Icon(
                  Icons.image,
                  size: 150,
                ),
          ElevatedButton(
            onPressed: () {
              pickImage(true);
            },
            onLongPress: () {
              pickImage(false);
            },
            child: Text("Choose"),
          ),
          SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: Text(
              '$result',
              textAlign: TextAlign.justify,
              style: TextStyle(fontFamily: 'solway', fontSize: 10),
            ),
          ),
        ],
      )),
    );
  }
}
