import 'package:cloud_firestore/cloud_firestore.dart';


class userdatabase {

  final CollectionReference data = FirebaseFirestore.instance.collection("Users");
  Future<void> addUser(String username, String email) async {
    try {
      print("hi");
      if (username.isEmpty || email.isEmpty) {
        throw "Username or email cannot be empty.";
      }

      await FirebaseFirestore.instance.collection('Users').add({
        'Username': username,
        'Email': email,
      });

      print("User added to Firestore!");
    } catch (error) {
      print("Error adding user: $error");
    }
  }



}
