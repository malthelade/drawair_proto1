import 'package:drawair_proto1/main.dart';
import 'package:flutter/material.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final _future = supabase.from('prompt').select();

  pushPrompt(promptId) async {
    await supabase
        .from('chosen_prompt')
        .update({'prompt_id': promptId}).match({'id': '1'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final prompts = snapshot.data!;
          prompts.shuffle();
          final prompt = prompts.removeLast();
          pushPrompt(prompt['id']);
          return Padding(
            padding: const EdgeInsets.all(100.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(prompt['draw_prompt']),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Gå tilbage')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
