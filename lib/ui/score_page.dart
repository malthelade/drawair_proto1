import 'package:drawair_proto1/main.dart';
import 'package:drawair_proto1/ui/lobby_page.dart';
import 'package:drawair_proto1/ui/pre_draw_page.dart';
import 'package:drawair_proto1/ui/pre_guess_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late final RealtimeChannel _channelRoom;
  late List<Map<String, dynamic>> _gameList;
  late String _currentDrawer;

  @override
  void initState() {
    super.initState();
    _channelRoom = supabase.channel(widget.roomID,
        opts: const RealtimeChannelConfig(self: true));
    _channelRoom
        .onBroadcast(
            event: 'start_game', callback: (payload) => startGameRecieved())
        .subscribe();
  }

  getCurrentDrawer() async {
    final drawerPull = await supabase
        .from('current_prompt')
        .select('playerID')
        .eq('roomID', widget.roomID);
    _currentDrawer = drawerPull[0]['playerID'];
  }

  startGameRecieved() async {
    if (_currentDrawer == widget.playerID) {
      await chooseNextDrawer();
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => PreDrawPage(
                  playerName: widget.playerName,
                  playerID: widget.playerID,
                  roomID: widget.roomID,
                  roomCode: widget.roomCode,
                  playerCount: _gameList.length))));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => PreGuessPage(
                  playerName: widget.playerName,
                  playerID: widget.playerID,
                  roomID: widget.roomID,
                  roomCode: widget.roomCode,
                  playerCount: _gameList.length))));
    }
  }

  chooseNextDrawer() async {
    final playerList = [];
    for (var player in _gameList) {
      playerList.add(player['playerID']);
    }
    int nextDrawerIndex = playerList.indexOf(_currentDrawer) + 1;
    if (nextDrawerIndex > playerList.length - 1) {
      nextDrawerIndex = 0;
    }
    await supabase
        .from('current_prompt')
        .update({'playerID': playerList[nextDrawerIndex]}).match(
            {'roomID': widget.roomID});
  }

  @override
  Widget build(BuildContext context) {
    final gameStream = supabase
        .from('game')
        .stream(primaryKey: ['id'])
        .eq('roomID', widget.roomID)
        .order('id', ascending: true);

    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: gameStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          _gameList = snapshot.data!;
          getCurrentDrawer();
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
                    for (var player in _gameList)
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
                onPressed: () {
                  _channelRoom.sendBroadcastMessage(
                      event: 'start_game',
                      payload: {'message': 'game started'});
                },
                child: const Text('Start'),
              )),
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
