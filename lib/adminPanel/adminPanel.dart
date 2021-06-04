import 'package:animated_button/animated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:word_quest/adminPanel/viewQuestions.dart';

import 'addQuestions.dart';
import 'configNames.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  User? user;
  bool isLogged = false;

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, "Start");
      }
    });
  }

  getUser() async {
    User? firebase_user = await _auth.currentUser;

    if (firebase_user != null) {
      setState(() {
        this.user = firebase_user;
        this.isLogged = true;
      });
    }
  }

  logout() async {
    if (googleSignIn.isSignedIn() == false) {
      await _auth.signOut();
    } else {
      try {
        await googleSignIn.disconnect().whenComplete(() async {
          await _auth.signOut();
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void deleteAllRecords() {
    try {
      firestore
          .collection(ConfigNames.DATABASE_NAME)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          firestore.collection(ConfigNames.DATABASE_NAME).doc(doc.id).delete();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    this.getUser();
    this.checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Quiz App Configurations'),
        ),
        body: Column(
          children: [
            Container(
                margin: EdgeInsets.fromLTRB(20, 70, 20, 50),
                width: double.infinity,
                child: Text(
                  'Admin Panel',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                )),
            Container(
                margin: EdgeInsets.all(20),
                child: AnimatedButton(
                    color: Colors.green,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddQuestions()),
                      );
                    },
                    child: Text(
                      'Add Questions',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
            Container(
                margin: EdgeInsets.all(20),
                child: AnimatedButton(
                    color: Colors.green,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewQuestions()),
                      );
                    },
                    child: Text('View/Update Questions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))),
            Container(
                margin: EdgeInsets.all(20),
                child: AnimatedButton(
                    onPressed: () => showDialog<String>(
                          //https://api.flutter.dev/flutter/material/AlertDialog-class.html
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Are yor sure?'),
                            content: const Text(
                                'You will be not able to recover this data.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteAllRecords();
                                  Navigator.pop(context, 'OK');
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                    color: Colors.red,
                    child: Text('Delete All Questions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))),
            Container(
                margin: EdgeInsets.all(20),
                child: AnimatedButton(
                    color: Colors.green,
                    onPressed: logout,
                    child: Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))),
          ],
        ),
      ),
    );
  }
}