import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:text_app/files/google_auth.dart';
import 'package:text_app/files/home.dart';
import 'package:text_app/files/internetchecker.dart';
import 'package:text_app/files/signup.dart';

class login extends StatefulWidget {
  var mess;

   login(this.mess);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {

  bool isSignedin = false;
  late bool _passwordVisible = false;

  var email = TextEditingController();
  var email2 = TextEditingController();
  var pass = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final google_auth sign_with_google = google_auth();

  @override
  void initState(){
    super.initState();
    _passwordVisible = false;

    InternetConnectionChecker.checkInternetConnection(context);
  }


  Future<void> forgotPassword() async {
    if (email2.text.isEmpty) {
      showToast("Please enter your email address");
      return;
    }

    try {
      // Attempt to send the password reset email


      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: email2.text.trim());
      showToast("Password reset email sent. Check your inbox.");


      // If no exception is thrown, it means the email was sent successfully

    } on FirebaseAuthException catch (e){
      showToast("email is not valid");
    }
  }



  String _getErrorMessageFromException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'weak-password':
        return 'Please enter a stronger password.';
      case 'invalid-password':
        return 'Please enter a correct password.';
      case 'invalid-email':
        return 'Email is not valid.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'operation-not-allowed':
        return 'Operation is not allowed.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'email-not-found':
        return 'Email not found';
      default:
        return 'Email not found';
    }
  }


  Future<void> login_User() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
          ),
        );
      },
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.toString(),
        password: pass.text.toString(),
      );
      Navigator.pop(context); // Close the loading dialog
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>home("",""),
        ),
            (route) => false, // This prevents going back to the previous routes
      );
      print('object');
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessageFromException(e);
      Navigator.pop(context);// Close the loading dialog
      showToast(errorMessage);
      rethrow;
      // Rethrow the exception to handle it in the UI if needed
    }
  }



  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM_RIGHT,
      timeInSecForIosWeb: 1,
      backgroundColor: Color(0xFF42A5F5),
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
                child: Lottie.asset("assets/lottie/lottie1.json",width: 125,
                  height: 125,
                  fit: BoxFit.fill,),
              ),


              Text(
                "Welcome back!",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 45,
                ),

              ),

              SizedBox(height: 5),
              Text(
                "Login into your account",style: TextStyle(
                  fontSize: 21
              ),

              ),


              SizedBox(height: 34,),



              Container(
                width: 340,
                child: TextField(
                  key: _formkey,
                  keyboardType: TextInputType.emailAddress,
                  controller: email,
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


              SizedBox(height: 23,),

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


                      SizedBox(height: 20,),

              Row(
                children: [
                  SizedBox(width:20),
                  Container(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: (){
                        showDialog(context: context, builder: (BuildContext context)=>
                            AlertDialog(
                              title: Text('Forgot Password',style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),),
                              content:SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('Enter your email address to reset your password.'),

                                    SizedBox(height: 12),
                                    // Add a TextField for the user to enter their email
                                    TextField(

                                      controller: email2,
                                      decoration: InputDecoration(
                                        hintText: "Email",

                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),

                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFF42A5F5),),
                                          borderRadius: BorderRadius.circular(20),
                                        ),

                                      ),
                                    ),
                                  ],
                                ),

                              ),

                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                  },
                                  child: Text('Cancel',style: TextStyle(
                                      color:Color(0xFF42A5F5)
                                  ),),
                                ),

                                TextButton(
                                  onPressed: () async {


                                    forgotPassword();
                                  },
                                  child:Text('Send Reset Email',style: TextStyle(
                                      color:Color(0xFF42A5F5)
                                  ),),
                                ),

                              ],

                            )



                        );




                      },
                      child: Text("Forgot password?",style:TextStyle(
                        color: Colors.blue,
                      ),),
                    ),
                  ),
                ],
              ),


              SizedBox(height: 23,),

              Container(
                  height: 60,
                  width: 340,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(21) )
                      ),

                      onPressed: (){


                        login_User();

                      }, child: Text("Login",style: TextStyle(
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

                      widget.mess?Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>signup())) :

                      Navigator.pop(context);
                    },
                    child: Text("Signup",style: TextStyle(
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
                          builder: (BuildContext context) =>home("",""),
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
                            child: CircularProgressIndicator(color: Colors.blue,)) // Show indicator if signing in
                            : Container(),
                        SizedBox(width: 10,),
                        Image.asset("assets/images/google.png",height: 23,),
                        SizedBox(width: 10,),
                        Text("Login with Google",style: TextStyle(fontSize: 16),)
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
