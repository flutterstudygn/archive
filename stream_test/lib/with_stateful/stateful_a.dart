import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stream_test/with_stateful/stateful_b.dart';
import 'package:stream_test/stream.dart';

class StatefulA extends StatefulWidget {
  static const tag = 'StatefulA';

  @override
  State<StatefulWidget> createState() => _StatefulAState();
}

class _StatefulAState extends State<StatefulA> {
  StreamSubscription _stopwatchListener;

  int _seconds = 0;

  bool _covered = false;

  @override
  void initState() {
    super.initState();
    print('[${StatefulA.tag}] on initState');
    _stopwatchListener = stopwatch.listen(
      (i) => setState(() {
        _seconds = i;
      }),
    );
    print('[${StatefulA.tag}] start listening stopwatch');
  }

  @override
  void dispose() {
    print('[${StatefulA.tag}] on dispose');
    _stopwatchListener.cancel();
    print('[${StatefulA.tag}] cancel listening stopwatch');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[${StatefulA.tag}] build called');

    // 현재 페이지가 가려졌다면 바로 빈 Widget인 SizedBox를 return한다.
    // 이 처리부분이 없으면 Flutter의 framework는 계속 이하 Widget을 그리게 되고
    // print('Tick from [$tag]')도 출력하게 된다.
    // 만약 해당 코드가 로그가 아니라 시계 소리 출력이었다면 문제가 된다.
    // (혹은 유료 API call이라거나...)
    if (_covered) {
      return SizedBox();
    }

    print('Tick from [${StatefulA.tag}]');

    return Scaffold(
      appBar: AppBar(
        title: Text('StatefulA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _seconds.toString(),
              textAlign: TextAlign.center,
            ),
            RaisedButton(
              onPressed: () async {
                _covered = true;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StatefulB(_seconds),
                  ),
                );
                _covered = false;
              },
              child: Text(
                'Push StatefulB',
              ),
            )
          ],
        ),
      ),
    );
  }
}
