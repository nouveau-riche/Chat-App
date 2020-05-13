import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createDatabase(
    String uid, String name, String email, String imageUrl) async {
  try {
    return await Firestore.instance.collection('users').document(uid).setData({
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'lastseen': DateTime.now().toIso8601String(),
    });
  } catch (error) {
    print(error);
  }
}

Stream<List<DocumentSnapshot>> getUserConversationContacts(String uid) {
  final ref = Firestore.instance
      .collection('users')
      .document(uid)
      .collection('Conversations');
  try {
    return ref.snapshots().map((_snapshot) {
      return _snapshot.documents;
    });
  } catch (error) {
    print(error);
  }
}

Stream<List<DocumentSnapshot>> getAllUserDatabase(String _search) {
  final ref = Firestore.instance
      .collection('users')
      .where('name', isGreaterThanOrEqualTo: _search)
      .where('name', isLessThan: '$_search  ');
  try {
    return ref.snapshots().map((_snapshot) {
      return _snapshot.documents;
    });
  } catch (error) {
    print(error);
  }
}

Future<void> createOrGetConversation(String currentUserID, String recepientID,
    Future<void> onSuccess(String conversationID)) async {
  var ref = Firestore.instance.collection('Conversations');
  var userConversationRef = Firestore.instance
      .collection('users')
      .document(currentUserID)
      .collection('Conversations');
  try {
    var conversation = await userConversationRef.document(recepientID).get();
    if (conversation.data != null) {
      return onSuccess(conversation.data['conversationID']);
    } else {
      var _conversationRef = ref.document();
      await _conversationRef.setData({
        'members': [currentUserID, recepientID],
        'ownerID': currentUserID,
        'messages': [],
      });
      return onSuccess(_conversationRef.documentID);
    }
  } catch (error) {
    print(error);
  }
}

Future<void> updateLastSeen(String uid) async {
  return await Firestore.instance
      .collection('users')
      .document(uid)
      .updateData({'lastseen': Timestamp.now()});
}

Stream getConversationMsg(String conversationID) {
  final ref =
      Firestore.instance.collection('Conversations').document(conversationID);
  return ref.snapshots();
}

Future<void> sendMessage(
    String conversationID, String msg, String senderId, String type) {
  final ref =
      Firestore.instance.collection('Conversations').document(conversationID);

  return ref.updateData({
    'messages': FieldValue.arrayUnion(
      [
        {
          'message': msg,
          'senderID': senderId,
          'timestamp': DateTime.now(),
          'type': type,
        },
      ],
    ),
  });
}
