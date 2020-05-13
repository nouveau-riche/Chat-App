import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_providers.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final args = Provider.of<AuthProvider>(context);
    final userId = args.userId;
    args.getUserData(userId);

    return Column(
      children: <Widget>[
        SizedBox(height: mq.height * 0.25),
        CircleAvatar(
          radius: mq.width * 0.22,
          backgroundImage: args.userInfo['imageUrl'] != null
              ? NetworkImage('${args.userInfo['imageUrl']}')
              : NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQIb_yOMUqLK4WMjy2iRUMPq520_p7Ey_0Ba1CWWvFLCp-KYvCm&usqp=CAU')
        ),
        SizedBox(height: mq.height * 0.04),
        Text(
          '${args.userInfo['userName']}',
          style: TextStyle(fontSize: 26),
        ),
        SizedBox(height: mq.height * 0.015),
        Text('${args.userInfo['userEmail']}',
            style: TextStyle(color: Colors.grey)),
        SizedBox(height: mq.height * 0.06),
        SizedBox(
          width: mq.width * 0.85,
          height: 45,
          child: RaisedButton(
            child: const Text(
              'LOGOUT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            color: Colors.red,
            onPressed: () {
              args.logOut();
            },
          ),
        )
      ],
    );
  }
}
