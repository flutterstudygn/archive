import 'package:flutter/material.dart';
import 'package:stream_test/stream_builder_b.dart';
import 'package:stream_test/streams.dart';

class StreamBuilderA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('StreamBuilderA'),
        ),
        body: StreamBuilder(
          initialData: 0,
          stream: globalPeriodic,
          builder: (context, snapshot) {

            print('Beep from A');

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    snapshot.data.toString(),
                    textAlign: TextAlign.center,
                  ),
                  RaisedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StreamBuilderB(snapshot.data),
                      ),
                    ),
                    child: Text(
                      'Push StreamBuilderB',
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }
}
