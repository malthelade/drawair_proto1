import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/guess_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PreGuessPage extends StatefulWidget {
  final String playerName;
  final String playerID;
  final String roomID;
  final int roomCode;
  final int playerCount;

  const PreGuessPage(
      {super.key,
      required this.playerName,
      required this.playerID,
      required this.roomID,
      required this.roomCode,
      required this.playerCount});

  @override
  State<PreGuessPage> createState() => _PreGuessPageState();
}

class _PreGuessPageState extends State<PreGuessPage> {
  late final RealtimeChannel _channelRoom;

  @override
  void initState() {
    super.initState();
    _channelRoom = supabase.channel(widget.roomID,
        opts: const RealtimeChannelConfig(self: true));
    _channelRoom
        .onBroadcast(
            event: 'start_round', callback: (payload) => startRoundRecieved())
        .subscribe();
  }

  startRoundRecieved() {
    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => GuessPage(
                playerName: widget.playerName,
                playerID: widget.playerID,
                roomID: widget.roomID,
                roomCode: widget.roomCode,
                playerCount: widget.playerCount))));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 200.0),
          child: Text('Get ready!'),
        ),
      ),
    );
  }
}
