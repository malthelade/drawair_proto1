import 'package:flutter/material.dart';

class MyDemo extends StatelessWidget {
  const MyDemo({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message);
  }
}
