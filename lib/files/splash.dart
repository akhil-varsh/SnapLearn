import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:text_app/files/home.dart';
import 'package:text_app/files/signup.dart';


class splash extends StatefulWidget {
  const splash({super.key});

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();


    Timer(Duration(seconds:2
    ), () {

      if(user==null)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>signup()));

      else
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>home("","")));




    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.blue,
      body: Center(
        child: Text("Snap Learn",style: TextStyle(
          color: Colors.white,
          fontSize: 45,
          fontWeight: FontWeight.bold,
        ),),
      ),
    );
  }
}
