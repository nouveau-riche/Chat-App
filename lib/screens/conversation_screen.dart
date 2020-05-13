import 'dart:async';
import 'package:chatify/helpers/storage.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../helpers/database.dart';
import '../providers/auth_providers.dart';
import '../helpers/media.dart';

class ConversationPage extends StatefulWidget {
  final String conversationID;
  final String receiverName;
  final String receiverImage;

  ConversationPage(this.conversationID, this.receiverName, this.receiverImage);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {

  String sendingText;

  final scrollViewController = ScrollController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void dispose() {
    scrollViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).backgroundColor;

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: color,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildSenderImage(),
            const SizedBox(width: 20),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            messageListView(context),
            Align(
              alignment: Alignment.bottomCenter,
              child: buildMessageField(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageListView(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final uid = Provider.of<AuthProvider>(context).userId;

    return Container(
      height: mq.height*0.828,
      width: mq.width,

      child: StreamBuilder(
        stream: getConversationMsg(widget.conversationID),
        builder: (context, snapshot) {
          Timer(
              Duration(milliseconds: 1),
              () => scrollViewController
                  .jumpTo(scrollViewController.position.maxScrollExtent));
          var _data = snapshot.data;
          if (_data != null) {
            var msg = _data['messages'];
            if (msg.length != 0) {
              return ListView.builder(
                  controller: scrollViewController,
                  itemCount: msg.length,
                  itemBuilder: (ctx, index) {
                    var ownMessage =
                        msg[index]['senderID'] == uid ? true : false;
                    return msg[index]['type'] == 'text'
                        ? textMessageBubble(
                            context,
                            msg[index]['message'],
                            msg[index]['timestamp'].toDate(),
                            ownMessage,
                          )
                        : imageMessageBubble(
                            context,
                            msg[index]['message'],
                            msg[index]['timestamp'].toDate(),
                            ownMessage,
                          );
                  });
            } else {
              return Align(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color:Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Let\'s Get Started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 20,
                        ),
                  ),
                ),
              );
            }
          } else {
            return SpinKitChasingDots(color: Colors.white);
          }
        },
      ),
    );
  }

  Widget textMessageBubble(BuildContext context, String message,
      DateTime lastMessageTime, bool isOwnMessage) {
    final mq = MediaQuery.of(context).size;
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 183, 1)]
        : [
            Color.fromRGBO(69, 69, 69, 1),
            Color.fromRGBO(43, 43, 43, 1),
          ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          !isOwnMessage ? buildSenderImage() : Container(),
          SizedBox(width: mq.width * 0.014),
          Container(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.03),
            height: mq.height * 0.1,
            width: mq.width * 0.75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: colorScheme,
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: [0.30, 0.70],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(message),
                Text(
                  '${timeago.format(lastMessageTime)}',
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageMessageBubble(BuildContext context, String message,
      DateTime lastMessageTime, bool isOwnMessage) {
    final mq = MediaQuery.of(context).size;
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 183, 1)]
        : [
            Color.fromRGBO(69, 69, 69, 1),
            Color.fromRGBO(43, 43, 43, 1),
          ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          !isOwnMessage ? buildSenderImage() : Container(),
          const SizedBox(width: 6),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5, top: 4),
            height: mq.height * 0.35,
            width: mq.width * 0.45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: colorScheme,
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: [0.30, 0.70],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  height: mq.height * 0.30,
                  width: mq.width * 0.45,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: message == null
                        ? Image.asset('assets/images/msgplaceholder.png',
                            fit: BoxFit.cover)
                        : Image.network(message, fit: BoxFit.cover),
                  ),
                ),
                Text(
                  '${timeago.format(lastMessageTime)}',
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSenderImage() {
    return CircleAvatar(
      radius: 18,
      backgroundImage: NetworkImage(widget.receiverImage),
    );
  }

  Widget buildMessageField(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(bottom: mq.height * 0.01),
      width: mq.width * 0.94,
      decoration: BoxDecoration(
        color: Color.fromRGBO(70, 70, 70, 0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            buildImageMessageButton(context),
            buildTextSenderField(context),
            buildMessageSenderButton(context)
          ],
        ),
      ),
    );
  }

  Widget buildTextSenderField(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return SizedBox(
      width: mq.width * 0.5,
      child: TextFormField(
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          hintText: 'Type a message...',
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
        onSaved: (value) {
          sendingText = value;
        },
      ),
    );
  }

  Widget buildMessageSenderButton(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context).userId;

    return IconButton(
      icon: const Icon(Icons.send),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          sendMessage(widget.conversationID, sendingText, uid, 'text');
          _formKey.currentState.reset();
        }
      },
      splashColor: Colors.transparent,
    );
  }

  Widget buildImageMessageButton(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context).userId;

    return IconButton(
      icon: const Icon(
        Icons.image,
        color: Colors.lightBlueAccent,
      ),
      onPressed: () async {
        var _image = await ChosseImage();
        if (_image != null) {
          var _result = await uploadMediaMessage(uid, _image);
          var _imageUrl = await _result.ref.getDownloadURL();
          await sendMessage(widget.conversationID, _imageUrl.toString(), uid, 'Image');
        }
      },
      splashColor: Colors.transparent,
    );
  }
}
