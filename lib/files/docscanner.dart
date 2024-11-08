import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:text_app/files/TextDisplayPage.dart';
import 'package:text_app/files/home.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:text_app/files/internetchecker.dart';


class DocScannerPage extends StatefulWidget {
  @override
  _DocScannerPageState createState() => _DocScannerPageState();
}

class _DocScannerPageState extends State<DocScannerPage> {
  late CameraController _controller;
  late List<XFile> _imageFiles = [];
  late bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    InternetConnectionChecker.checkInternetConnection(context);
  }

  void _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;
      _controller = CameraController(camera, ResolutionPreset.high);
      await _controller.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Document Scanner',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: Colors.white,),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => home(""," ")
              ),
            );
          },
        ),
      ),
      body: _isCameraInitialized
          ? Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: OverflowBox(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _takePicture,
                  child: Icon(Icons.camera_alt, color: Colors.blue),
                ),

                SizedBox(width: 23,),

                ElevatedButton(
                  onPressed: (){


                    _selectImageFromGallery();


                  },
                  child: Icon(Icons.upload_file_rounded, color: Colors.blue),
                ),

              ],
            ),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }


  void _takePicture() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      final XFile picture = await _controller.takePicture();

      // Extract text from the captured image
      final inputImage = InputImage.fromFilePath(picture.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognisedText = await textRecognizer.processImage(inputImage);

      String extractedText = recognisedText.text;
      print('Extracted text: $extractedText');

      // Navigate to another page to display the extracted text
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatGPTScreen(initialText:extractedText),
        ),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _selectImageFromGallery() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      print('Error selecting image from gallery: $e');
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textDetector = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognisedText = await textDetector.processImage(inputImage);
      String extractedText = recognisedText.text;
      print('Extracted text: $extractedText');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatGPTScreen(initialText: extractedText),
        ),
      );
    } catch (e) {
      print('Error processing image: $e');
    }
  }


}
