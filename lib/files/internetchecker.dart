import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class InternetConnectionChecker {
  static Future<void> checkInternetConnection(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      await _showNoInternetDialog(context);
    }
  }

  static Future<void> _showNoInternetDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection',style: TextStyle(
              fontWeight: FontWeight.bold
          ),),
          content: Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await checkInternetConnection(context);
              },
              child: Text('OK',style: TextStyle(
                  color: Color(0xFF42A5F5)
              ),),
            ),
          ],
        );
      },
    );
  }
}
