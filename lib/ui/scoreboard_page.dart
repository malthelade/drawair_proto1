import 'package:drawair_proto1/main.dart';
import 'package:flutter/material.dart';

class ScoreboardPage extends StatefulWidget {
  final int id;

  const ScoreboardPage({super.key, required this.id});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  @override
  Widget build(BuildContext context) {
    final future =
        supabase.from('game').select('playerID').eq('roomID', widget.id);

    return Scaffold(
        body: FutureBuilder<List<Map<String, dynamic>>>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: ListView(
                  children: const [
                    ListTile(title: Text('liste1')),
                    ListTile(
                      title: Text('list'),
                    ),
                  ],
                ),
              );
            }));
  }
}
