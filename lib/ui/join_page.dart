import 'package:drawair_proto1/main.dart';
import 'package:flutter/material.dart';

class JoinPage extends StatefulWidget {
  final String playerID;

  const JoinPage({super.key, required this.playerID});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final codeController = TextEditingController();
  final _future = supabase.from('room').select('*');
  bool roomExists = false;
  late String roomID;

  joinGame(playerID, roomCode) async {
    await supabase.from('game').insert({
      'roomID': roomID,
      'playerID': playerID,
      'host': 'false',
      'drawing': 'false'
    });
  }

  doesRoomExist(rooms, roomCode) {
    for (final room in rooms) {
      if (room['code'] == roomCode) {
        roomExists = true;
        roomID = room['id'];
        break;
      }
    }
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
            final rooms = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(
                  left: 30.0, right: 30.0, bottom: 30.0, top: 300.0),
              child: Column(children: <Widget>[
                TextField(
                  controller: codeController,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter code'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        await doesRoomExist(
                            rooms, int.parse(codeController.text));
                        if (roomExists) {
                          joinGame(widget.playerID, roomID);
                        } else {
                          showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (context) => const AlertDialog(
                                  title: Text('Rummet findes ikke'),
                                  content: Text(
                                      'Du har ikke skrevet en kode der passer til et rum')));
                        }
                      },
                      child: const Text('Join')),
                )
              ]),
            );
          }),
    );
  }
}
