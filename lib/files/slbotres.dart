import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:text_app/files/internetchecker.dart';

class slbotres extends StatefulWidget {
  final String response;

  slbotres({required this.response});

  @override
  _slbotresState createState() => _slbotresState();
}

class _slbotresState extends State<slbotres> {

  @override
  void initState() {
    super.initState();


    InternetConnectionChecker.checkInternetConnection(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Response',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.response,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        )
      ),
    );
  }

}


