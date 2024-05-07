import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/lobby_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScoreboardPage extends StatefulWidget {
  final String playerID;
  final String roomID;
  final int roomCode;

  const ScoreboardPage(
      {super.key,
      required this.playerID,
      required this.roomID,
      required this.roomCode});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  @override
  Widget build(BuildContext context) {
    final future = supabase
        .from('game')
        .select('playerID, points, player!inner(*)')
        .eq('roomID', widget.roomID);

    return Scaffold(
        body: FutureBuilder<List<Map<String, dynamic>>>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final game = snapshot.data!;
              return Column(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: ListView(
                      padding: const EdgeInsets.all(40.0),
                      children: [
                        ListTile(
                          title: Text('Code: ${widget.roomCode}'),
                        ),
                        for (var player in game)
                          ListTile(
                            title: Text(
                                '${player['player']['name']}: ${player['points']}'),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                        onPressed: () async {
                          await supabase
                              .from('game')
                              .delete()
                              .match({'playerID': widget.playerID});
                          Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LobbyPage(playerID: widget.playerID)));
                        },
                        child: const Text('Leave')),
                  )
                ],
              );
            }));
  }
}
