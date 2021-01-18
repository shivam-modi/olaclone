import 'package:flutter/material.dart';

showDia(ctx, msg){
  return showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (ctx) => ProgressDialog(msg: msg),
  );
}
class ProgressDialog extends StatelessWidget {
  final String msg;
  ProgressDialog({this.msg});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white60,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              SizedBox(
                width: 6,
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Colors.black87,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                msg,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
