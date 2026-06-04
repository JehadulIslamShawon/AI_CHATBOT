import 'dart:convert';

import 'package:ai_chatbot/models/message_model.dart';
import 'package:ai_chatbot/screens/home/widgets/item_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent';
  final msgController = TextEditingController();
  List<MessageModel> messages = [];
  bool loading = false;

  sendMessage() async {
    String msg = msgController.text;
    msgController.clear();
    setState(() {
      messages.add(MessageModel(msg, true));
      loading = true;
    });
    try {
    
      final result = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key':
              'google api key will be set in here',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": msg},
              ],
            },
          ],
        }),
      );
      // print(result.body);
      final data = jsonDecode(result.body);
      // Safely extract the answer to avoid NoSuchMethodError when fields are missing
      try {
        final candidates = data['candidates'];
        if (candidates == null || candidates is! List || candidates.isEmpty) {
          print('No candidates in response: ${result.body}');
          setState(() {
            messages.add(MessageModel('No response from API', false));
          });
        } else {
          final content = candidates[0]['content'];
          final parts = content != null ? content['parts'] : null;
          if (parts == null || parts is! List || parts.isEmpty || parts[0]['text'] == null) {
            print('Unexpected response format: ${result.body}');
            setState(() {
              messages.add(MessageModel('Unexpected API response', false));
            });
          } else {
            String answer = parts[0]['text'];
            setState(() {
              messages.add(MessageModel(answer, false));
            });
            print(answer);
          }
        }
      } catch (e) {
        print('Error parsing response: ${e.toString()}');
        setState(() {
          messages.add(MessageModel('Error parsing API response', false));
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Chatbot'), backgroundColor: Colors.blue,),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              // shrinkWrap: true,
              children: [
                for (var msg in messages) ItemMessage(msg: msg),
                loading
                    ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'Waiting....',
                        style: TextStyle(color: Colors.blue),
                      ),
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: InputDecoration(
                      hintText: 'Ask your question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    // Handle send button press
                    if (msgController.text.isNotEmpty) {
                      sendMessage();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
