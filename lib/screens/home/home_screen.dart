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
  static const String _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent';

  final TextEditingController msgController = TextEditingController();

  final List<MessageModel> messages = [];
  // this store all chat messages, where each message is represented by an instance of MessageModel, which contains the text of the message and a boolean indicating whether the message was sent by the user or received from the chatbot.
  // When the user sends a message: messages.add(MessageModel("Hello", true),); now: [MessageModel("Hello", true)] When AI replies: messages.add(MessageModel("Hi!", false),); now: [MessageModel("Hello", true),MessageModel("Hi!", false)] 
  // then ListView displays these messages for (var msg in messages) ItemMessage(msg: msg) Visual Result: Hello (user message) Hi! (AI response) 

  bool loading = false;

  @override
  void dispose() {
    msgController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final String msg = msgController.text.trim();
    // leading  and trailing spaces are removed by trim() function and if the message is empty after trimming, it will return without sending the message.
    if (msg.isEmpty) return;

    msgController.clear();
    // show user mesage and adds the message to the chat list
    setState(() {
      messages.add(MessageModel(msg, true));
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key':
              'Api Key here',
        },
        // convert dart Map into JSON string and sends the user message as part of the request
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
      // check status code of the response and if it's  200, it will suceessfully send the message.
      if (response.statusCode != 200) {
        setState(() {
          messages.add(MessageModel('Error: ${response.statusCode}', false));
        });
        return;
        // in here return means stop the function.
      }
      // convert the response body from JSON string to dart Map and extract the answer from the response and adds it to the chat list.
      print(response.body);
      print("test");
      final Map<String, dynamic> data = jsonDecode(response.body);
      print(data);
      final String? answer =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      setState(() {
        messages.add(MessageModel(answer ?? 'No response received.', false));
        // answer ?? means if answer != null, use answer, otherwise use 'No response received.' as the default value. 
      });
    } catch (e) {
      setState(() {
        messages.add(MessageModel('Something went wrong.\n$e', false));
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
        backgroundColor: Colors.blue,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildBody();
          }

          return Row(
            children: [
              Container(
                width: 300,
                color: Colors.grey.shade200,
                child: const Center(child: Text('Additional content here')),
              ),
              Expanded(child: _buildBody()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length + (loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (loading && index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Waiting...',
                      style: TextStyle(color: Colors.blue),
                    ),
                  );
                }

                return ItemMessage(msg: messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: const InputDecoration(
                      hintText: 'Ask your question...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: loading ? null : sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
