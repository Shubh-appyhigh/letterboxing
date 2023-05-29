import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:letterboxing/logic.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'LetterBoxing'),
      ),
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
  Uint8List? finalImage;
  String? selectedFilePath;
  final _logger=Logger();
  int? originalWidth,originalHeight,widthWithBorder,heightWithBorder,widthwoBorder,heightwoBorder;

  Future<void> uploadImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      setState(() {
        selectedFilePath = filePath;
        resizeImage();
      });
    }
  }
  void resizeImage() {
    File imageFile = File(selectedFilePath!);
    Uint8List bytes = imageFile.readAsBytesSync();
    img.Image image1 = img.decodeImage(bytes)!;
    originalWidth = image1.width;
    originalHeight = image1.height;
    _logger.i('Image dimensions: $originalWidth x $originalHeight');
    List result=letterbox(image1);
    img.Image refactor = result[0];
    widthwoBorder=result[1][0];
    heightwoBorder=result[1][1];
    widthWithBorder=refactor.width;
    heightWithBorder=refactor.height;

    _logger.i('Updated Image dimensions: ${refactor.width} x ${refactor.height}');
    finalImage = img.encodeJpg(refactor);
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        shrinkWrap: true,
        // scrollDirection: Axis.horizontal,
        children: [
          selectedFilePath==null?const SizedBox():Text('Image dimensions: $originalWidth x $originalHeight'),
          finalImage==null?const SizedBox():Text('Updated Image dimensions w/o border: $widthwoBorder x $heightwoBorder'),
          finalImage==null?const SizedBox():Text('Updated Image dimensions: $widthWithBorder x $heightWithBorder'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                finalImage==null?const SizedBox():Container(
                    width: 100.w,
                    decoration: const BoxDecoration(),
                    child: Image.memory(finalImage!)),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          ElevatedButton(
              onPressed: () {
                uploadImage();
              },
              child: const Text("Upload Image"))
        ],
      ),
    );
  }
}
