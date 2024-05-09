import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/lobby_page.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ScorePage extends StatefulWidget {
  final String playerName;
  final String playerID;
  final String roomID;
  final int roomCode;

  const ScorePage(
      {super.key,
      required this.playerName,
      required this.playerID,
      required this.roomID,
      required this.roomCode});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  @override
  Widget build(BuildContext context) {
    // select * from high_score where "roomID" = '28961025-ee38-4172-a4ce-53c187b44c42'
    // final gameStream = supabase
    //     .from('high_score')
    //     .stream(primaryKey: ['id']).eq('roomID', widget.roomID);
    final gameStream = supabase
        .from('game')
        .stream(primaryKey: ['id']).eq('roomID', widget.roomID);

    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: gameStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final list = snapshot.data!;
          return Scaffold(
              body: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: ListView(
                  padding: const EdgeInsets.all(40.0),
                  children: [
                    ListTile(
                      title: Text('Code: ${widget.roomCode}'),
                    ),
                    for (var player in list)
                      ListTile(
                        title: Text(
                            '${player['playerName']}: ${player['points']}'),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.black, width: 1),
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
                              builder: (context) => LobbyPage(
                                    playerID: widget.playerID,
                                    playerName: widget.playerName,
                                  )));
                    },
                    child: const Text('Leave')),
              )
            ],
          ));
        });
  }
}
