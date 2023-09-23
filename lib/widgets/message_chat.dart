import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageChat extends StatefulWidget {
  const MessageChat({super.key});
  @override
  State<MessageChat> createState() {
    return _MessageChatState();
  }
}

class _MessageChatState extends State<MessageChat> {
  var enteredmessage = TextEditingController();
  void _sendmessage()async{
    final enteredmessages=enteredmessage.text;
    if(enteredmessages.trim().isEmpty){
      return ;
    }
   final id=await FirebaseAuth.instance.currentUser!;
   final users=await FirebaseFirestore.instance.collection('users').doc(id.uid).get();
    FirebaseFirestore.instance.collection('chat').add({
      'test': enteredmessages,
      'time' :Timestamp.now(),
      'userid' :id.uid,
      'username':users.data()!['username'],
      'image_url' :users.data()!['imageurl']
     
    });
    enteredmessage.clear();
  }
  @override
  void dispose() {
    enteredmessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1,bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration:
                  const InputDecoration(labelText: 'write your message'),
              controller: enteredmessage,
              enableSuggestions: true,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
            ),
          ),
          IconButton(
            onPressed: _sendmessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
    );
  }
}
