import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stream_test/stream.dart';

class StatefulB extends StatefulWidget {
  static const tag = 'StatefulB';

  final int _initSeconds;

  const StatefulB(this._initSeconds, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StatefulBState();
}

class _StatefulBState extends State<StatefulB> {
  StreamSubscription _stopwatchListener;

  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    print('[${StatefulB.tag}] on initState');
    _stopwatchListener = stopwatch.listen(
      (i) => setState(() {
        _seconds = i;
      }),
    );
    print('[${StatefulB.tag}] start listening stopwatch');
  }

  @override
  void dispose() {
    print('[${StatefulB.tag}] on dispose');
    _stopwatchListener.cancel();
    print('[${StatefulB.tag}] cancel listening stopwatch');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[${StatefulB.tag}] build called');

    return Scaffold(
      appBar: AppBar(
        title: Text('StatefulB'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              (widget._initSeconds + _seconds).toString(),
              textAlign: TextAlign.center,
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Pop this page',
              ),
            )
          ],
        ),
      ),
    );
  }
}
