import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:text_app/files/Generatequestions.dart';
import 'package:text_app/files/apikey.dart';
import 'package:text_app/files/slbotres.dart';

class slbot extends StatefulWidget {
  // Accept initial text as a parameter



  @override
  _slbotState createState() => _slbotState();
}

class _slbotState extends State<slbot> {
  final List<Message> _messages = [];

  final TextEditingController _textEditingController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Set initial value of the TextField to the initialText if provided

  }


  void onSendMessage() async {
    Message message = Message(text: _textEditingController.text, isMe: true);

    _textEditingController.clear();

    setState(() {
      _messages.insert(0, message);
      _loading = true;
    });

    String response = await sendMessageToChatGpt(message.text);

    setState(() {
      _loading = false; // Set loading indicator to false when response is received
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => slbotres(response: response),
      ),
    );

  }




  Future<String> sendMessageToChatGpt(String message) async {
    Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": message}
      ],
      "max_tokens": 500,
    };

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${APIKey.apiKey}",
      },
      body: json.encode(body),
    );

    print(response.body);

    Map<String, dynamic> parsedReponse = json.decode(response.body);

    String reply = parsedReponse['choices'][0]['message']['content'];

    return reply;
  }


  Widget _buildMessage(Message message) {
    if (!message.isMe) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'GPT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(message.text),
            ],
          ),
        ),
      );
    }
    return Container();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Snap Learn',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.white, // Change this color to the one you desire
        ),
      ),
      body: Stack(
          children:[ Column(
            children: <Widget>[

              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: _messages.where((message) => !message.isMe).length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildMessage(_messages[index]);
                  },
                ),
              ),
              Expanded(
                flex: 89, // This will make the TextField twice the size of the button
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),

                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,

                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
              SizedBox(height: 10.0), // Add some space between the TextField and the button
              Container(
                width: 300,
                child: FloatingActionButton(

                    backgroundColor: Colors.blue,
                    onPressed: onSendMessage,
                    tooltip: 'Send',
                    child:Text("Generate",style: TextStyle(
                        color: Colors.white,
                        fontSize: 18
                    ),)
                ),
              ),

              SizedBox(height: 12,),
            ],
          ),
            if (_loading) // Show the loading indicator when loading is true
              Center(
                child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),),
              ),
          ]
      ),


    );
  }

}

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}