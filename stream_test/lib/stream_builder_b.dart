import 'package:flutter/material.dart';
import 'package:stream_test/streams.dart';

class StreamBuilderB extends StatelessWidget {
  final int _initialNumber;

  const StreamBuilderB(this._initialNumber, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('StreamBuilderB'),
        ),
        body: StreamBuilder(
          initialData: _initialNumber,
          stream: globalPeriodic,
          builder: (context, snapshot) {
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Pop this page',
                    ),
                  ),
                  Text('현재 StreamBuilderB에 가려져있는 Widget인 StreamBuilderA또한 Stream이 업데이트 될 떄마다 build함수가 실행되고있다.'),
                ],
              ),
            );
          },
        ));
  }
}
