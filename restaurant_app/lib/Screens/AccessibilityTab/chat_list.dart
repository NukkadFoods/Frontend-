import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/chat_screen.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List numbers = [];
  Stream<QuerySnapshot<Map<String, dynamic>>>? db;
  @override
  void initState() {
    super.initState();
    initListener();
  }

  void initListener() {
    db = FirebaseFirestore.instance.collection('chat').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: db,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot> temp = [];
              snapshot.data!.docs.forEach((doc) {
                if (doc.get('messages').isNotEmpty) {
                  temp.add(doc);
                }
              });
              temp.sort((b, a) {
                return a.get('lastModified').compareTo(b.get('lastModified')!);
              });
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: temp.length,
                  itemBuilder: (context, index) => ListTile(
                    minTileHeight: MediaQuery.of(context).size.height * .07,
                    title: Text(temp[index].id),
                    trailing: temp[index].get('unreadBySupport') == 0
                        ? null
                        : Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              temp[index].get('unreadBySupport').toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatSupportScreen()));
                    },
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }),
    );
  }
}
