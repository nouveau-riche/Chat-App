import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<StorageTaskSnapshot> uploadProfilePicture(String uid, File image) {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final StorageReference _baseRef = _storage.ref().child('profileImages');

  try {
    return _baseRef.child(uid).putFile(image).onComplete;
  } catch (error) {
    print(error);
  }
}

Future<StorageTaskSnapshot> uploadMediaMessage(String uid, File _file) {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final StorageReference _baseRef = _storage.ref().child('messages');

  var _filename = basename(_file.path);
  _filename += '${DateTime.now().toString()}';
  try {
    return _baseRef
        .child(uid)
        .child('images')
        .child(_filename)
        .putFile(_file)
        .onComplete;
  } catch (error) {
    print(error);
  }
}
