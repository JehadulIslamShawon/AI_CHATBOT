import 'package:ai_chatbot/models/message_model.dart';
import 'package:flutter/material.dart';

class ItemMessage extends StatelessWidget {
  final MessageModel msg;
  const ItemMessage({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isUser? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 300),
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: msg.isUser? Colors.grey.shade300 : Colors.blue.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
