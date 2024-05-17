import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/draw_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PreDrawPage extends StatefulWidget {
  final String playerName;
  final String playerID;
  final String roomID;
  final int roomCode;
  final int playerCount;

  const PreDrawPage(
      {super.key,
      required this.playerName,
      required this.playerID,
      required this.roomID,
      required this.roomCode,
      required this.playerCount});

  @override
  State<PreDrawPage> createState() => _PreDrawPageState();
}

class _PreDrawPageState extends State<PreDrawPage> {
  late final RealtimeChannel _channelRoom;

  @override
  void initState() {
    super.initState();
    _channelRoom = supabase.channel(widget.roomID,
        opts: const RealtimeChannelConfig(self: true));
    _channelRoom
        .onBroadcast(event: 'start_round', callback: (payload) => something())
        .subscribe();
  }

// må ikke fjernes, lortet går i stykker hvis man gør
  something() {}

  startRound() async {
    await _channelRoom.sendBroadcastMessage(
        event: 'start_round', payload: {'message': 'round started'});
  }

  @override
  Widget build(BuildContext context) {
    final future = supabase
        .from('prompt')
        .select('*, current_prompt!inner(*)')
        .eq('current_prompt.roomID', widget.roomID);
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final prompt = snapshot.data!;
          final drawPrompt = prompt[0]['draw_prompt'];
          return Padding(
            padding: const EdgeInsets.all(100.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text("Tegn $drawPrompt"),
                  ElevatedButton(
                      onPressed: () async {
                        await startRound();
                        if (!context.mounted) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DrawPage(
                                    playerName: widget.playerName,
                                    playerID: widget.playerID,
                                    roomID: widget.roomID,
                                    roomCode: widget.roomCode,
                                    playerCount: widget.playerCount)));
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
