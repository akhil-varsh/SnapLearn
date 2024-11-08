import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_app/files/docscanner.dart';
import 'package:text_app/files/login.dart';
import 'package:text_app/files/signup.dart';
import 'package:text_app/files/slbot.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'internetchecker.dart';


class home extends StatefulWidget {
var userr, emaill;

home(this.userr, this.emaill);


  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  int index = 0;
  PageController _pageController = PageController(initialPage: 0);



  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late SharedPreferences _prefs;

  List<Map<String, String>> _notifications = [];



late var Userr = TextEditingController();
late var email = TextEditingController();

  List<String> imagePaths = [];
  File? imagee;
  String? imageeURL;

  bool isLoading = true;


  void loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Userr.text = prefs.getString('username') ?? '';
      email.text = prefs.getString('email') ?? '';
    });
  }

  void saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', Userr.text);
    await prefs.setString('email', email.text);
  }




  Future<void> deleteAccount(BuildContext context) async {
    try {


      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        clearPrefs();

        print('Account deleted successfully');
        // Navigate to the login screen or any other appropriate screen
      } else {
        print('No user signed in');
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }




  _launchEmail() async {
    const email = 'codeakhilsai@gmail.com'; // Replace with your email
    const subject = 'Feedback on Your App'; // Replace with your desired subject


    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject',
    );

    if (await canLaunch(params.toString())) {
      await launch(params.toString());
    } else {

      Fluttertoast.showToast(
        msg: "Please try again",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }


  Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("cleared");
  }


  @override
  Future<void> signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    // Clear SharedPreferences
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => login(true)),
          (route) => false,
    );
  }



  void deleteDocument(String email) async {
    // Reference to the Firestore collection
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('Users');

    // Query to find the document with the specified email
    QuerySnapshot querySnapshot = await collectionReference.where('Email', isEqualTo: email).get();

    // Check if any documents match the query
    if (querySnapshot.docs.isNotEmpty) {
      // Delete the document
      await collectionReference.doc(querySnapshot.docs.first.id).delete();
      clearPrefs();

      print('Document deleted successfully');
    } else {
      print('Document not found');
    }
  }





  Future<String?> _uploadProfilePhoto() async {
    try {

      if (imagee != null) {
        // Upload the profile photo to Firebase Storage
        var storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child(Userr.text)
            .child(Userr.text+".jpg");

        await storageRef.putFile(imagee!);

        // Get the download URL
        String downloadURL = await storageRef.getDownloadURL();
        return downloadURL;
      }
      else{
        return "";
      }
    } catch (e) {
      print('Error uploading profile photo: $e');
      return "";
    }

  }












  @override
  void initState(){
    super.initState();
    loadProfileData();
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });

    email.addListener(saveProfileData);
    Userr.addListener(saveProfileData);

    fetchUserData();


    _initializeSharedPreferences();
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _addNotification(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addNotification(message);
    });

    InternetConnectionChecker.checkInternetConnection(context);

  }



  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = (_prefs.getStringList('notifications') ?? []).map((notification) {
        final parts = notification.split('|');
        return {'title': parts[0], 'subtitle': parts[1]};
      }).toList();
    });
  }

  void _addNotification(RemoteMessage message) {
    if (message.notification != null && message.notification!.title != null && message.notification!.body != null) {
      final notificationTitle = message.notification!.title!;
      final notificationBody = message.notification!.body!;
      final notification = {'title': notificationTitle, 'subtitle': notificationBody};
      setState(() {
        _notifications.add(notification);
        _prefs.setStringList(
          'notifications',
          _notifications.map((notification) => '${notification['title']}|${notification['subtitle']}').toList(),
        );
      });


      if (message.data.containsKey('notificationLaunchArgs')) {
        // Extract launch arguments from the data field
        final notificationLaunchArgs = message.data['notificationLaunchArgs'];
        // Navigate directly to the notification page
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => home(""," ")));
      }

    }



  }

  @override
  void dispose() {
    _notifications.clear(); // Clear the notifications list when the page is disposed
    super.dispose();
  }





  Future<void> pickimg(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imagee = File(pickedFile.path);
        imagePaths.add(pickedFile.path);
      });
    }
  }


  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        print('User Email: ${user.email}');

        // Reference to the Firestore collection
        CollectionReference collectionReference = FirebaseFirestore.instance.collection('Users');

        // Query to find documents with the specified email
        QuerySnapshot querySnapshot = await collectionReference.where('Email', isEqualTo: user.email).get();

        print('Document Exists: ${querySnapshot.docs.isNotEmpty}');

        if (querySnapshot.docs.isNotEmpty) {
          print("fetched2");
          // Assuming you're only interested in the first document if multiple are found
          var documentSnapshot = querySnapshot.docs.first;

          setState(() {
            // Update the state variables with the fetched data
            widget.userr = documentSnapshot['Username'] ;
            widget.emaill = documentSnapshot['Email'];
           // Set to false as we have fetched data from Firestore



            Userr.text= widget.userr;
            email.text = widget.emaill;

          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  void _clearNotifications() {
    setState(() {
      _notifications.clear();
      _prefs.remove('notifications');
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Snap Learn",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.white, // Change this color to the one you desire
        ),


        actions: [

          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(onPressed: (){
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DocScannerPage()));


            }, icon:Icon(Icons.document_scanner_outlined,size: 27,)),
          )

        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (pageIndex) {
          setState(() {
            index = pageIndex;
          });
        },
        children: [

          Column(
            children: [

              SizedBox(height: 23,),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: "Welcome to ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "SnapLearn",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: " - Snap a pic, get instant questions. Effortless studying, anytime, anywhere. Goodbye manual notes, hello intuitive learning. Try it now!",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 27,),
              Container(
                height: 140,
                width: 350,
                child: GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DocScannerPage()));

                  },
                  child: Card(
                    elevation: 4,
                    child: Row(


                      children: [

                        SizedBox(width: 23,),
                        Icon(
                          Icons.document_scanner_rounded,
                          size: 29, // Adjust the size of the icon as needed
                          color: Colors.blue, // Adjust the color as needed
                        ),
                        SizedBox(width: 13),
                        Text(
                          'Scan',
                          style: TextStyle(
                            fontSize: 28, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Adjust the color as needed
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              Container(
                height: 140,
                width: 350,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>slbot()));

                  },
                  child: Card(
                    elevation: 4,
                    child:Row(

                      children: [

                        SizedBox(width: 23,),
                        Icon(
                          Icons.question_answer_rounded,
                          size: 29, // Adjust the size of the icon as needed
                          color: Colors.blue, // Adjust the color as needed
                        ),
                        SizedBox(width: 13),
                        Text(
                          'SL-Bot ',
                          style: TextStyle(
                            fontSize: 28, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Adjust the color as needed
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),




              Container(
                height: 140,
                width: 350,
                child: GestureDetector(
                  onTap: () async {
                    final intent = AndroidIntent(
                      action: 'action_view',
                      data: 'content://com.android.providers.downloads.documents/document/msf:%d',
                      type: 'vnd.android.document/directory',
                    );
                    await intent.launch();

                  },

                  child: Card(
                    elevation: 4,
                    child:  Row(

                      children: [

                        SizedBox(width: 23,),
                        Icon(
                          Icons.download,
                          size: 29, // Adjust the size of the icon as needed
                          color: Colors.blue, // Adjust the color as needed
                        ),
                        SizedBox(width: 13),
                        Text(
                          'Downloads',
                          style: TextStyle(
                            fontSize: 26, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Adjust the color as needed
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),



            ],
          ),



                        Column(
                        children: [
                        SizedBox(height: 20,),
                        Text(
                        "Notifications",
                        style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        ),
                        ),
                        Expanded( // Use Expanded to allow ListView to occupy remaining space
                        child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Card(
                        elevation: 2,
                        child: ListTile(
                        title: Text(notification['title'] ?? ' ', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(notification['subtitle'] ?? ' '),
                        ),
                        );
                        },
                        ),
                        ),

                          Padding(

                            padding: EdgeInsets.only(bottom: 34,left: 287),
                            // Adjust as needed
                            child: FloatingActionButton(
                              backgroundColor: Colors.blue,
                              onPressed: () {
                                 _clearNotifications();
                              },
                              child: Icon(Icons.delete,color: Colors.white,),
                            ),
                          ),
                        ],
                        ),




    Column(
            children: [

              SizedBox(height: 25,),
              Text("Settings",style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 30

              ),),


              SizedBox(height: 18,),

            GestureDetector(
               onTap: (){
                 _showAppVersionDialog();

               },
               child: Card(
                 elevation: 4,
                   color: Colors.white,
                   child: Container(
                     height: 80,
                     width: 350,
                     padding: EdgeInsets.only(right: 23,top: 3,left:13),
                     child: Row(

                       children: [
                         Icon(Icons.info_outline_rounded,  color: Colors.blue,),
                         SizedBox(width: 8,),
                         Text("About",style: TextStyle(
                           fontSize: 20,
                           color: Colors.blue,
                         ),),
                       ],
                     ),
                   )),
             ),

              SizedBox(height: 10,),

              GestureDetector(
                onTap: (){


                  _launchEmail();

                },
                child: Card(
                    elevation: 3,
                    color: Colors.white,
                    child: Container(
                      height: 80,
                      width: 350,
                      padding: EdgeInsets.only(right: 23,top: 3,left:13),
                      child: Row(

                        children: [
                          Icon(Icons.feedback_outlined,  color: Colors.blue,),
                          SizedBox(width: 8,),
                          Text("Feedback",style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),),
                        ],
                      ),
                    )),
              ),


              SizedBox(height: 10,),

              GestureDetector(
                onTap: (){
                  _showClearCacheConfirmationDialog(context);
                },
                child: Card(
                    elevation: 3,
                    color: Colors.white,
                    child: Container(
                      height: 80,
                      width: 350,
                      padding: EdgeInsets.only(right: 23,top: 3,left:13),
                      child: Row(

                        children: [
                          Icon(Icons.delete_outlined,  color: Colors.blue,),
                          SizedBox(width: 8,),
                          Text("Clear cache",style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),),
                        ],
                      ),
                    )),
              ),

              SizedBox(height: 10,),


              GestureDetector(
                onTap: () {
                  _launchURL();
                },
                child: Card(
                  elevation: 3,
                  color: Colors.white,
                  child: Container(
                    height: 80,
                    width: 350,
                    padding: EdgeInsets.only(right: 23,top: 3,left:13),
                    child:  Row(

                      children: [
                        Icon(FontAwesomeIcons.star,color: Colors.blue,size: 18,),
                        SizedBox(width: 8),
                        Text("Rate the app",style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                        ),),
                      ],
                    ),
                  ),
                ),
              ),







            ],
          ),



          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [

                SizedBox(height: 20,),
                Text("Profile",style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 33

                ),),


                   Column(
                    //crossAxisAlignment:CrossAxisAlignment.center,

                    children: [


                      Container(
                        height:160,
                        width:200,


                        margin: EdgeInsets.only(left:4,top:30),

                        child: Stack(
                          children:[
                            GestureDetector(
                              onTap:()  {
                                                       if (imageeURL != null) {
                                                       // Show the profile picture in zoom
                                                       Navigator.push(
                                                       context,
                                                       MaterialPageRoute(
                                                       builder: (context) => PhotoViewGallery.builder(
                                                       itemCount: 1,
                                                       builder: (context, index) {
                                                       return PhotoViewGalleryPageOptions(
                                                       imageProvider: NetworkImage(
                                                       imageeURL!,
                                                       ),
                                                       minScale: PhotoViewComputedScale.contained * 0.8,
                                                       maxScale: PhotoViewComputedScale.covered * 2,
                                                       );
                                                       },
                                                       scrollPhysics: BouncingScrollPhysics(),
                                                       backgroundDecoration: BoxDecoration(
                                                       color: Colors.black,
                                                       ),
                                                       pageController: PageController(),
                                                       ),
                                                       ),
                                                       );
                                                       }


                                                                       else{

                                                                       Navigator.push(
                                                                       context,
                                                                       MaterialPageRoute(
                                                                       builder: (context) => PhotoViewGallery.builder(
                                                                       itemCount: 1,
                                                                       builder: (context, index) {
                                                                       return PhotoViewGalleryPageOptions(
                                                                       imageProvider: AssetImage(
                                                                       "assets/images/nopic.png",
                                                                       ),
                                                                       minScale: PhotoViewComputedScale.contained * 0.8,
                                                                       maxScale: PhotoViewComputedScale.covered * 2,
                                                                       );
                                                                       },
                                                                       scrollPhysics: BouncingScrollPhysics(),
                                                                       backgroundDecoration: BoxDecoration(
                                                                       color: Colors.black,
                                                                       ),
                                                                       pageController: PageController(),
                                                                       ),
                                                                       ),
                                                                       );

                                                                       }



                                     },

                              child: CircleAvatar(
                                radius:99,
                                // backgroundImage: imagee != null ?  FileImage(imagee!) : AssetImage("assets/image/img.png") as ImageProvider,
                                backgroundImage: imagee != null
                                    ? FileImage(imagee!)
                                    : imageeURL != null
                                    ? NetworkImage(imageeURL!)
                                    : AssetImage("assets/images/img.png") as ImageProvider,

                              ),
                            ),
                            Positioned(
                              right:39,
                              top:125,

                              child:InkWell(
                                onTap: (){
                                  showModalBottomSheet(context: context, builder: (builder)=>bottomsheet());


                                },
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 39,
                                  color: Colors.blue,

                                ),
                              ),)

                          ],

                        ),

                      ),

                      SizedBox(height:34),


                      Container(

                        width:340,
                        alignment: Alignment.center,
                        child: TextField(
                          controller: Userr,



                          decoration: InputDecoration(


                            labelStyle: TextStyle(
                                color: Colors.blue
                            ),

                            hintText: Userr.text = widget.userr.toString(),

                            border: OutlineInputBorder(

                                borderRadius: BorderRadius.circular(23)

                            ),



                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue,),
                              borderRadius: BorderRadius.circular(23),
                            ),




                          ),

                        ),
                      ),


                      SizedBox(height:20),

                      Container(

                        width:340,
                        alignment: Alignment.center,
                        child: TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,


                          decoration: InputDecoration(

                            labelStyle: TextStyle(
                              color: Colors.blue
                            ),

                            hintText: email.text = widget.emaill.toString(),
                            border: OutlineInputBorder(

                                borderRadius: BorderRadius.circular(23)

                            ),


                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue,),
                              borderRadius: BorderRadius.circular(23),
                            ),



                          ),

                        ),
                      ),



                      SizedBox(height: 30,),

                      Container(

                          width:320,
                          height:57,

                          child: ElevatedButton(onPressed: ()  async {


                            showDialog(
                              context: context,
                              builder: (context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                            await _uploadProfilePhoto();

                          },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(13)),
                                backgroundColor: Colors.blue
                              ),

                              child: Text("Save",style: TextStyle(
                                  fontSize:19,
                                  color: Colors.white
                              ),))),

                      SizedBox(height:58),

                      Divider(
                        thickness:3,

                        indent:5,
                        endIndent: 5,
                      ),

                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: (){

                          signout(context);
                        },
                        child: Row(
                          children: [
                            SizedBox(width: 11),

                            Text("Logout",style: TextStyle(
                              fontSize:22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,

                            ),),

                            SizedBox(width:4),



                            Icon(Icons.logout_outlined,color: Colors.blue,size:24,),





                          ],
                        ),
                      ),



                      SizedBox(height: 10),



                      Divider(
                        thickness:3,

                        indent:5,
                        endIndent: 5,
                      ),


                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Account Deletion',style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),),
                                content: Text('Are you sure to delete your account permanently?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('No',style: TextStyle(
                                        color:Colors.blue
                                    ),),
                                  ),
                                  TextButton(
                                    onPressed: () async {

                                      await deleteAccount(context);
                                      deleteDocument(email.text);
                                      Navigator.push(context,MaterialPageRoute(builder: (context)=>signup()));




                                    },
                                    child:Text('Yes',style: TextStyle(
                                        color:Colors.blue
                                    ),),
                                  ),
                                ],
                              );
                            },
                          );





                        },
                        child: Row(
                          children: [

                            SizedBox(width: 11),

                            Text("Delete Account",style: TextStyle(
                              fontSize:22,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),),



                            Icon(Icons.delete,color: Colors.redAccent,size:24,),





                          ],
                        ),
                      ),

                      SizedBox(height: 35),

                      //SizedBox(height:40,),




                    ],
                  ),











              ],
            ),
          ),


        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.blue.shade400,
        animationDuration: Duration(milliseconds: 420),
        items: [
          Icon(
            Icons.home,
            color: Colors.white,
          ),
          Icon(
            Icons.notifications,
            color: Colors.white,
          ),
          Icon(
            Icons.settings,
            color: Colors.white,
          ),
          Icon(
            Icons.account_circle_sharp,
            color: Colors.white,
          ),
        ],
        index: index,
        onTap: (int tappedIndex) {
          setState(() {
            index = tappedIndex;
            _pageController.animateToPage(
              tappedIndex,
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          });
        },
      ),
    );
  }

  Widget bottomsheet(){
    return Container(
        height: 114,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          children: [
            Text("Choose profile photo",style: TextStyle(
                fontSize:22
            ),
            ),
            SizedBox(height:20,),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(width:3,),


                InkWell(
                  onTap: (){
                    pickimg(ImageSource.camera);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt,
                        size:27,
                        color: Color(0xFF42A5F5),),


                      SizedBox(width:4),


                      Text("Camera",style: TextStyle(
                        fontSize:15,
                      ),),
                    ],
                  ),
                ),


                SizedBox(width:20,),

                InkWell(
                  onTap: () {
                    pickimg(ImageSource.gallery);},

                  child: Row(
                    children: [
                      Icon(Icons.image,
                        size:27,
                        color: Color(0xFF42A5F5),),

                      SizedBox(width:4),

                      Text("Gallery",style: TextStyle(
                        fontSize:15,
                      ),),
                    ],
                  ),
                ),



                SizedBox(width:20,),


                InkWell(
                  onTap: () {
                   deleteProfilePicture();


                  },


                  child: Row(
                    children: [
                      Icon(Icons.delete,
                        size:27,
                        color: Color(0xFF42A5F5),),

                      SizedBox(width:4),

                      Text("Delete",style: TextStyle(
                        fontSize:15,
                      ),),
                    ],
                  ),
                ),



              ],
            )
          ],
        ));
  }

  Future<void> deleteProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      imagee = null;
    });
    await prefs.remove("imagePath");

    // Delete the image from Firebase Storage
    var storageRef = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(Userr.text)
        .child(Userr.text + ".jpg");



    await storageRef.delete();

  }





  void _showClearCacheConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Cache',style: TextStyle(
              fontWeight: FontWeight.bold,

          ),),
          content: Text('Are you sure you want to clear the app cache?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel',style: TextStyle(
                  color: Colors.blue
              ),),
            ),
            TextButton(
              onPressed: () {
                clearCache();
                Navigator.pop(context);

                Fluttertoast.showToast(
                  msg: "Cache cleared",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM_RIGHT,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              },
              child: Text('Clear',style: TextStyle(
                  color: Colors.blue
              ),),
            ),
          ],
        );
      },
    );
  }


  Future<void> clearCache() async {
    DefaultCacheManager().emptyCache();
  }



  void _launchURL() async {
    const url = 'https://play.google.com/store/apps/details?id=your_package_name'; // Replace with your app's URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _showAppVersionDialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Snap Learn',style: TextStyle(
            fontWeight: FontWeight.bold,

          ),),
          content: Text('Version: $version'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close',style: TextStyle(
                color: Colors.blue,
              ),),
            ),
          ],
        );
      },
    );
  }




}
