import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/draw_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PreDrawPage extends StatefulWidget {
  final String playerName;
  final String playerID;
  final String roomID;
  final int roomCode;

  const PreDrawPage(
      {super.key,
      required this.playerName,
      required this.playerID,
      required this.roomID,
      required this.roomCode});

  @override
  State<PreDrawPage> createState() => _PreDrawPageState();
}

class _PreDrawPageState extends State<PreDrawPage> {
  final _future = supabase.from('prompt').select();
  late final RealtimeChannel _channelRoom;

  @override
  void initState() {
    super.initState();
    _channelRoom = supabase.channel(widget.roomID,
        opts: const RealtimeChannelConfig(self: true));
  }

  pushPrompt(promptID) async {
    await supabase
        .from('current_prompt')
        .update({'promptID': promptID}).match({'roomID': widget.roomID});
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
                        _channelRoom.sendBroadcastMessage(
                            event: 'start_round',
                            payload: {'message': 'round started'});
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DrawPage(
                                    playerName: widget.playerName,
                                    playerID: widget.playerID,
                                    roomID: widget.roomID,
                                    roomCode: widget.roomCode)));
                      },
                      child: const Text('Start')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
