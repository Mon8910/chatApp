import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_chat/widgets/bublemessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chatmessage extends StatelessWidget {
  const Chatmessage({super.key});
  @override
  Widget build(BuildContext context) {
    final checkuser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('no message yet'),
            );
          }

          final data = snapshot.data!.docs;
          return ListView.builder(
              itemCount: data.length,
              reverse: true,
              itemBuilder: (ctx, index) {
                final chatmessage = data[index].data();
                final nextmessage =
                    index + 1 < data.length ? data[index + 1] : null;
                final currentuserid = chatmessage['userid'];
                final nextuserid =
                    nextmessage != null ? nextmessage['userid'] : null;
                //hna 3shan a3rf nfs el user wla l2
                final compairmessage = nextuserid == currentuserid;
                if (compairmessage) {
                  return MessageBubble.next(
                      message: chatmessage['test'],
                      isMe: checkuser == Chatmessage);
                }
                else{
                  return MessageBubble.first(
                  userImage: chatmessage['image_url'], 
                  username: chatmessage['username'], 
                  message: chatmessage['test'],
                   isMe: checkuser==chatmessage);
                }
              });
        }));
  }
}
