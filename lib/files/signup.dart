import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:text_app/files/google_auth.dart';
import 'package:text_app/files/home.dart';
import 'package:text_app/files/internetchecker.dart';
import 'package:text_app/files/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_app/files/userdatabase.dart';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {

  var username = TextEditingController();
  var email = TextEditingController();
  var pass = TextEditingController();

  var ErrorText;

  final google_auth sign_with_google = google_auth();


  bool isSignedin = false;
  late bool _passwordVisible = false;



  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM_RIGHT,
      timeInSecForIosWeb: 1,
      backgroundColor:Color(0xFF42A5F5),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }




  String _getErrorMessageFromException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'weak-password':
        return 'Please enter a stronger password.';
      case 'invalid-email':
        return 'Email is not valid.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'operation-not-allowed':
        return 'Operation is not allowed.';
      case 'user-disabled':
        return 'This user has been disabled.';
      default:
        return 'An unknown error occurred.';
    }
  }





  Future<void> registerUser(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child:  CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      },
    );
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text,
        password: pass.text,
      );



      // Close the loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => home(username.text.toString(),email.text.toString())),
      );

      print("User registered: ${userCredential.user!.email}");
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessageFromException(e);
      Navigator.pop(context);
         // Close the loading dialog
      showToast(errorMessage);
      rethrow;
      // Rethrow the exception to handle it in the UI if needed
    }

  }





  @override
  void initState(){
    super.initState();
    _passwordVisible = false;
    InternetConnectionChecker.checkInternetConnection(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      

      body: SingleChildScrollView(
        child: Center(
          child: Column(
        
            children: [

              Padding(
                padding: const EdgeInsets.only(top:60),
                child: Lottie.asset("assets/lottie/lottie2.json",width: 125,
                  height: 125,
                  fit: BoxFit.fill,),
              ),



              SizedBox(height: 5),
              Text(
                  "Create an account for free",style: TextStyle(
               fontSize: 27,
                color: Colors.blue,
                fontWeight: FontWeight.bold
              ),
        
              ),
        
        
              SizedBox(height: 34,),
        
              Container(
                width: 340,
                child: TextField(
                    controller: username,

                  decoration: InputDecoration(
                    hintText: "Username",
                    errorText: ErrorText,

                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23)
        
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
        
        
                  ),
        
        
                ),
              ),
        
        
              SizedBox(height: 23,),
        
        
              Container(
              width: 340,
                 child: TextField(
                 controller: email,
                   keyboardType: TextInputType.emailAddress,
                   decoration: InputDecoration(
                     hintText: "Email",

        
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(23)
        
                     ),
                     focusedBorder: OutlineInputBorder(
                   borderSide: BorderSide(color: Colors.blue),
                   borderRadius: BorderRadius.circular(20),
                 ),
        
        
                   ),
        
        
                 ),
               ),


        
              SizedBox(height: 23),
        
              Container(
                width: 340,
                child: TextField(
                  controller: pass,
                  obscureText: !_passwordVisible,
                  
                  decoration: InputDecoration(
                    hintText: "Password",

                    suffixIcon: IconButton(

                      icon: Icon(
                        _passwordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blue,
                      ),
                      onPressed: (){
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),


                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23)
        
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
        
        
                  ),
        
        
                ),
              ),
        
        
           SizedBox(height: 25,),
        
              Container(
                  height: 60,
                  width: 340,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(21) )
                    ),

                      onPressed: (){


                                  if (username.text.toString().isEmpty) {
                                  setState(() {
                                  ErrorText = 'Please enter username';
                                  });

                                  }

                                  else{
                                  registerUser(context);
                                  userdatabase().addUser(username.text.toString(),email.text.toString());
                                  }
                                  


                      }, child: Text("Signup",style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
        
                  ),))),


              SizedBox(height:18,),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text("Already have an account?"),

                  SizedBox(width:6),

                  InkWell(
                    onTap: (){
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>login(false)));
                    },
                    child: Text("Login",style: TextStyle(
                      color: Colors.blue,
                    ),),
                  )
                ],
              ),

              SizedBox(height: 30,),


              Container(
                margin: EdgeInsets.only(left: 20,right: 20),

                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color:Colors.grey,
                        height:2,
                        indent:1,
                        endIndent: 1,
                      ),

                    ),

                    SizedBox(width: 5,),

                    Text("Or continue with",style: TextStyle(

                    ),),

                    SizedBox(width: 5,),

                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color:Colors.grey,
                        height:2,
                        indent:1,
                        endIndent: 1,
                      ),

                    ),


                  ],
                ),
              ),

              SizedBox(height: 30,),

              Container(
                width: 320,
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () async {
                    setState(() {
                     isSignedin = true;
                    });

                    bool res = await sign_with_google.signInWithGoogle();
                    if (res) {
                      Navigator.pushAndRemoveUntil<void>(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>home(" ", " "),
                        ),
                            (route) => false, // This prevents going back to the previous routes
                      );
                    }

                    setState(() {
                      isSignedin = false;
                    });
                  },

                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: Colors.blue)
                    ),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isSignedin
                            ? Container(
                            height: 23,
                            width: 23,
                            child: CircularProgressIndicator(color:Colors.blue)) // Show indicator if signing in
                            : Container(),
                        SizedBox(width: 10,),
                        Image.asset("assets/images/google.png",height: 23,),
                        SizedBox(width: 10,),
                        Expanded(child:
                        Text("Sign up with Google",style: TextStyle(fontSize: 16),)
                        ),
                          ],
                    ),
                  ),
                ),
              ),









            ],
          ),
        ),
      ),
    );
  }
}
