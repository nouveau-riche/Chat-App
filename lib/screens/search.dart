import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../helpers/database.dart';
import '../providers/auth_providers.dart';
import '../screens/conversation_screen.dart';


class Search extends StatefulWidget {

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String _selectedSearch;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final args = Provider.of<AuthProvider>(context);
    final uid = args.userId;
    args.getUserData(uid);
    final email = args.userInfo['userEmail'];

    return Container(
      padding: EdgeInsets.all(mq.height*0.007),
      height: mq.height,
      width: mq.width,
      child: Column(
        children: <Widget>[
          Container(
            child: TextField(
              cursorColor: Colors.white,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search...',
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide.none),
              ),
              onSubmitted: (value) {
                  _selectedSearch = value;
              },
            ),
          ),
          SizedBox(height: mq.height * 0.012),
          searchList(mq.width * 0.065, mq.width * 0.23,
              mq.width * 0.022, _selectedSearch, uid, email),
        ],
      ),
    );
  }

  Widget searchList( double rad, double frontindent,
      double backindent, String _search, String uid, String email) {
    return Expanded(
      child: StreamBuilder(
          stream: getAllUserDatabase(_search),
          builder: (ctx, snapshot) {
            var _data = snapshot.data;
            if (_data != null) {
              _data.removeWhere((contact) => contact['email'] == email);
            }
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      var data = _data[index];
                      var img = data['imageUrl'] != null
                          ? data['imageUrl']
                          : 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS5kuyA0DO4_dlJGnz5XshQCMFn4rMjq0tQsGh_m3cX0jqNLU6z&usqp=CAU';
                      var name = data['name'];

                      return Column(
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              createOrGetConversation(uid, data.documentID,
                                  (String conversationID) async {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx){
                                   return  ConversationPage(
                                      conversationID, name, img);
                                  }
                                ));
                              });
                            },
                            leading: CircleAvatar(
                              radius: rad,
                              backgroundImage: NetworkImage(img),
                            ),
                            title: Text(name),
                            trailing: searchListTileTrailing(
                                data['lastseen'].toDate()),
                          ),
                          Divider(
                            thickness: 0.27,
                            color: Colors.grey,
                            indent: frontindent,
                            endIndent: backindent,
                          ),
                        ],
                      );
                    })
                : SpinKitChasingDots(color: Colors.white);
          }),
    );
  }

  Widget searchListTileTrailing(DateTime date) {
    var isUserActive =
        !date.isBefore(DateTime.now().subtract(Duration(minutes: 18)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        isUserActive ? const Text('Active now') : const Text('Last Seen'),
        isUserActive
            ? const Icon(
                Icons.brightness_1,
                size: 10,
                color: Colors.green,
              )
            : Text(
                timeago.format(date),
                style: TextStyle(color: Colors.grey),
              ),
      ],
    );
  }
}
