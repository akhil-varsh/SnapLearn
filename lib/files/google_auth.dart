import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class google_auth{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<bool> signInWithGoogle() async {
    bool res = false;

    try{
      //sign in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      // obtain auth datails from request
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      //creating a credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      UserCredential userCredential =await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;
      if(user != null){
        if(userCredential.additionalUserInfo!.isNewUser){
          await _firestore.collection('Users').doc(user.uid).set({
            'Username' : user.displayName,
            'Email' : user.email,

          });

        }
        res = true;
      }

    }catch(e){
      res = false;
    }
    return res;
  }






}



