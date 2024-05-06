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
  final rooms = supabase.from('room').select('code');
  late bool roomExists;

  joinGame(playerID, roomID) async {
    await supabase.from('game').insert({
      'roomID': roomID,
      'playerID': playerID,
      'host': 'true',
      'drawing': 'true'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 30.0, right: 30.0, bottom: 30.0, top: 300.0),
          child: Column(children: <Widget>[
            TextField(
              controller: codeController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Enter code'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: ElevatedButton(
                  onPressed: null,
                  // onPressed: () { roomExists = rooms['code'].contains(codeController.text);
                  // if (){
                  //   joinGame(widget.playerID, codeController.text);}
                  // },
                  child: const Text('Join')),
            )
          ]),
        ),
      ),
    );
  }
}
