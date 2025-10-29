import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationDetails extends StatefulWidget {
  const NotificationDetails({super.key});

  @override
  State<NotificationDetails> createState() => NotificationDetailsState();
}

class NotificationDetailsState extends State<NotificationDetails> {
  Map<String, dynamic> get notification => Get.arguments;

  @override
  void initState() {
    if (notification.isEmpty) {
        Future.delayed(Duration.zero, () {
          if(mounted){
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: icon()),
              Text(
                notification['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(notification['body'], style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Ok'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget icon() {
    switch (notification['data']?['type']) {
      case 'info':
        return const Icon(Icons.info, color: Colors.blue, size: 70);
      case 'warning':
        return const Icon(Icons.warning, color: Colors.orange, size: 70);
      case 'error':
        return const Icon(Icons.error, color: Colors.red, size: 70);
      default:
        return const Icon(Icons.notifications, color: Colors.grey, size: 70);
    }
  }
}
