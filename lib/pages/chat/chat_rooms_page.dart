import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/empty_page.dart';

class ChatRoomsPage extends StatefulWidget {
  const ChatRoomsPage({super.key});

  @override
  ChatRoomsPageState createState() {
    return ChatRoomsPageState();
  }
}

class ChatRoomsPageState extends State<ChatRoomsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discussions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
                  (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: const Center(
        child: EmptyPage(
          icon: Icon(FontAwesomeIcons.exclamation),
          sub: Text('Coming soon ...'),
        ),
      ),
    );
  }
}