import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../providers/auth_providers.dart';
import '../helpers/database.dart';
import '../screens/conversation_screen.dart';

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userID = Provider.of<AuthProvider>(context).userId;

    return StreamBuilder(
        stream: getUserConversationContacts(userID),
        builder: (context, snapshot) {
          var _data = snapshot.data;

          if (_data != null) {
            if (_data.length != 0) {
              return ListView.builder(
                padding: EdgeInsets.all(5),
                itemCount: _data.length,
                itemBuilder: (ctx, index) {
                  var store = _data[index];
                  return buildListTile(
                      context,
                      store['conversationID'],
                      store['name'],
                      store['type'],
                      store['image'],
                      store['lastMessage'] != null ? store['lastMessage'] : '',
                      store['unseenCount']);
                },
              );
            } else {
              return Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQNidbGHnXwwc9vCA592BC4CxLQU8kxayhBJn53oQK2GzoSIS8l&usqp=CAU');
            }
          } else {
            return SpinKitChasingDots(color: Colors.white);
          }
        });
  }

  Widget buildListTile(
    BuildContext context,
    String conversationID,
    String name,
    String type,
    String image,
    String lastMessage,
    int unseen,
  ) {
    final mq = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[
        Container(
          child: ListTile(
            leading: CircleAvatar(
              radius: mq.width * 0.065,
              backgroundImage: image != null
                  ? NetworkImage(image)
                  : NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSsjy6fkNaT19t7iX4z-dOYRQbEet-WOR3c4JTcxuNT5hrj6fV7&usqp=CAU'),
            ),
            title: Text(name),
            subtitle: type == 'text'
                ? Text(lastMessage)
                : Align(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.image,
                            color: Colors.grey[500],
                            size: 20,
                          ),
                          Text(' Photo')
                        ]),
                    alignment: Alignment.centerLeft,
                  ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    ConversationPage(conversationID, name, image),
              ));
            },
          ),
        ),
        Divider(
          thickness: 0.27,
          color: Colors.grey,
          indent: mq.width * 0.23,
          endIndent: mq.width * 0.022,
        ),
      ],
    );
  }
}
