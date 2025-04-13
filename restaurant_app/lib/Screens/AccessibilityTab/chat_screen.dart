import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

import 'package:restaurant_app/Widgets/constants/colors.dart';

import '../../Widgets/toast.dart';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({Key? key}) : super(key: key);

  @override
  _ChatSupportScreenState createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  Stream<DocumentSnapshot<Map>>? stream;
  bool isLoading = true;
  late DocumentReference db;
  TextEditingController messageController = TextEditingController();
  late String phoneNumber;
  List<String> imageFormats = ['jpg', 'png', 'jpeg'];

  @override
  void initState() {
    super.initState();
    getStream();
  }

  void getStream() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneNumber = SharedPrefsUtil().getString(AppStrings.mobilenumber)!;
    if (phoneNumber.startsWith('+91')) {
      phoneNumber = phoneNumber.substring(3);
    }
    stream = FirebaseFirestore.instance
        .collection('chat')
        .doc(phoneNumber)
        .snapshots();
    db = FirebaseFirestore.instance.collection('chat').doc(phoneNumber);
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void send(String message) {
    db.update({
      'lastModified': FieldValue.serverTimestamp(),
      'unreadBySupport': FieldValue.increment(1),
      'messages': FieldValue.arrayUnion([
        {
          'type': 'text',
          'text': message,
          'timeStamp': DateTime.now(),
          'sender': phoneNumber
        }
      ])
    });
  }

  void sendAttachment() async {
    FirebaseStorage firestore = FirebaseStorage.instance;
    Reference? ref;
    List<XFile> pickedFile =
        await ImagePicker().pickMultipleMedia(imageQuality: 80);
    int totalFiles = pickedFile.length;
    if (pickedFile.isNotEmpty) {
      Toast.showToast(message: 'Uploading files, This may take a while');
      int uploadedFiles = 0;
      for (XFile file in pickedFile) {
        ref = firestore.ref().child('adminChat/$phoneNumber/${file.name}');
        var uploadFile = File(file.path);
        await ref.putFile(uploadFile);
        String url = await ref.getDownloadURL();
        uploadedFiles++;
        sendAttachmentMessage({
          'type': 'file',
          'filename': file.name.substring(7),
          'downloadUrl': url,
          'text': ref.fullPath,
          'timeStamp': DateTime.now(),
          'sender': phoneNumber
        });
        Toast.showToast(
            message:
                'Sent $uploadedFiles, Remaining ${totalFiles - uploadedFiles}');
      }
    }
  }

  void sendAttachmentMessage(Map attachment) {
    db.update({
      'lastModified': FieldValue.serverTimestamp(),
      'unreadBySupport': FieldValue.increment(1),
      'messages': FieldValue.arrayUnion([attachment])
    });
  }

  @override
  void dispose() {
    super.dispose();
    stream!.drain();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  image: AssetImage('assets/images/otpbg.png'),
                  opacity: .7,
                  fit: BoxFit.cover)),
          child: SizedBox.expand(),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Chat with us",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back_ios))),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(right: 18.0, left: 18),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder(
                            stream: stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.data() == null) {
                                db.set({
                                  'lastModified': DateTime.now(),
                                  'unreadBySupport': 0,
                                  'messages': [],
                                });
                              }
                              List mList = [];
                              if (snapshot.hasData &&
                                  snapshot.data!.data() != null) {
                                mList = snapshot.data!
                                    .data()!['messages']
                                    .reversed
                                    .toList();
                              }
                              return !snapshot.hasData ||
                                      snapshot.data!.data() == null
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : ListView.builder(
                                      reverse: true,
                                      itemCount: snapshot.data!
                                          .data()!['messages']
                                          .length,
                                      itemBuilder: (context, index) => Align(
                                        alignment: mList[index]['sender'] ==
                                                phoneNumber
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .78),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5.0),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  color: mList[index]
                                                              ['sender'] ==
                                                          phoneNumber
                                                      ? primaryColor
                                                      : Color(0xffd6d6d6)),
                                              child: mList[index]['type'] ==
                                                      'text'
                                                  ? Text(
                                                      mList[index]['text'],
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: mList[index][
                                                                      'sender'] ==
                                                                  phoneNumber
                                                              ? Colors.white
                                                              : Colors.black),
                                                    )
                                                  : InkWell(
                                                      onTap: () async {
                                                        if (imageFormats
                                                            .contains(mList[
                                                                        index]
                                                                    ['filename']
                                                                .toString()
                                                                .split('.')
                                                                .last)) {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                            builder: (context) =>
                                                                ImageView(
                                                                    data: mList[
                                                                        index]),
                                                          ));
                                                        } else {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                            builder: (context) =>
                                                                VideoView(
                                                                    data: mList[
                                                                        index]),
                                                          ));
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.file_open,
                                                            color: mList[index][
                                                                        'sender'] ==
                                                                    phoneNumber
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              ' ${mList[index]['filename']}',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: mList[index]
                                                                              [
                                                                              'sender'] ==
                                                                          phoneNumber
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                            },
                          )),
              ),
              TypeMessage(
                messageController: messageController,
                onSend: () async {
                  if (messageController.text.isNotEmpty) {
                    send(messageController.text.trim());
                    messageController.clear();
                  }
                },
                onAttachment: () {
                  sendAttachment();
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}

class TypeMessage extends StatelessWidget {
  const TypeMessage({
    super.key,
    required this.messageController,
    required this.onSend,
    required this.onAttachment,
  });
  final TextEditingController messageController;
  final VoidCallback onSend;
  final VoidCallback onAttachment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        style: TextStyle(fontSize: 15),
        minLines: 1,
        maxLines: 4,
        controller: messageController,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: const BorderSide(color: primaryColor, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: const BorderSide(color: primaryColor, width: 1.5)),
            filled: false,
            hintText: "Start typing your query...",
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onAttachment,
                  child: Transform.rotate(
                    angle: 3.14 / 4,
                    child: Icon(
                      Icons.attach_file,
                      color: primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: onSend,
                    child: Icon(
                      Icons.send_outlined,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.data});
  final Map data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: Text(data['filename']),
      ),
      body: SafeArea(
        child: Center(
          child: CachedNetworkImage(
            imageUrl: data['downloadUrl'],
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.contain,
            imageBuilder: (context, imageProvider) =>
                PhotoView(imageProvider: imageProvider),
          ),
        ),
      ),
    );
  }
}

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.data});
  final Map data;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.data['downloadUrl']))
          ..initialize().then((_) {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(widget.data['filename'])),
        body: _controller.value.isInitialized
            ? Center(
                child: Column(
                  children: [
                    Flexible(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                  } else {
                                    _controller.play();
                                  }
                                  setState(() {});
                                },
                                child: VideoPlayer(_controller)),
                            if (!_controller.value.isPlaying)
                              InkWell(
                                  onTap: () {
                                    _controller.play();
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black87),
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white.withOpacity(.95),
                                      size: 70,
                                    ),
                                  ))
                          ],
                        ),
                      ),
                    ),
                    //Add progress indicator here
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()));
  }
}
