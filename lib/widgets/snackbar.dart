import 'package:flutter/material.dart';

void snackBarSuccess(BuildContext context,String message){
  Scaffold.of(context).hideCurrentSnackBar();
  Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(message,style:TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
      ));
}

void snackBarError(BuildContext context,String message){
  Scaffold.of(context).hideCurrentSnackBar();
  Scaffold.of(context).showSnackBar(
      SnackBar(
          duration: Duration(seconds: 2),
          content: Text(message,style:TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
      ));
}