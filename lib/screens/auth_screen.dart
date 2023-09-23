import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_chat/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  var islogin = true;
  var enteredmail = '';
  var enteredpassword = '';
  File? saveimage;
  var auth = false;
  var entereduser ='';
  final formkey = GlobalKey<FormState>();

  void _saveddata() async {
    final isvalidate = formkey.currentState!.validate();
    if (!isvalidate || !islogin && saveimage == null ) {
      return;
    }
    formkey.currentState!.save();

    try {
      setState(() {
        auth = true;
      });
      if (islogin) {
        await _firebase.signInWithEmailAndPassword(
            email: enteredmail, password: enteredpassword);
      } else {
        final createuser = await _firebase.createUserWithEmailAndPassword(
            email: enteredmail, password: enteredpassword);
        final storagedata = FirebaseStorage.instance
            .ref()
            .child('user-address')
            .child('${createuser.user!.uid}.jpg');
       await storagedata.putFile(saveimage!);
    final imaged=   await  storagedata.getDownloadURL();
       FirebaseFirestore.instance.collection('users').doc(createuser.user!.uid).set({
          'username' :entereduser,
          'email' :enteredmail,
          'imageurl ': imaged
         
        });
        
       
      }
    } on FirebaseAuthException catch (error) {
      if (error == 'email-already-in-use') {
        //...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'authentication')),
      );
      setState(() {
        auth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 10,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 300,
                child: Image.asset('assets/images/chat.png'),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                margin: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!islogin)
                            UserImagePicker(
                              onselectedimage: (pickedimage) {
                                saveimage = pickedimage;
                              },
                            ),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: 'E-mail address'),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.trim().contains('@')) {
                                return 'is not valid';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredmail = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if(!islogin)
                          TextFormField(
                            decoration:const InputDecoration(labelText: 'user'),
                            enableSuggestions: false,
                            validator: (value) {
                              if(value==null || value.isEmpty||value.trim().length<4){
                                return 'your user name is not valid' ;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              entereduser=value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 8) {
                                return 'passwoed is not valid';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredpassword = value!;
                            },
                          ),
                          if (auth) const CircularProgressIndicator(),
                          if (!auth)
                            ElevatedButton(
                              onPressed: _saveddata,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              child: Text(islogin ? 'login' : 'sign up'),
                            ),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  islogin = !islogin;
                                });
                              },
                              child: Text(islogin
                                  ? 'create new account'
                                  : 'already have account'))
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
