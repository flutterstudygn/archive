import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_test/streams.dart';

class ProviderB extends StatelessWidget {
  final PeriodicProvider _provider;

  const ProviderB(this._provider, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ProviderB'),
      ),
      body: ChangeNotifierProvider<PeriodicProvider>.value(
        value: _provider,
        child: Consumer<PeriodicProvider>(
          builder: (context, provider, buttonAndText) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    provider.num.toString(),
                    textAlign: TextAlign.center,
                  ),
                  buttonAndText
                ],
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RaisedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Pop this page',
                ),
              ),
              Text(
                  '현재 ProviderB에 가려져있는 Widget인 ProviderA또한 PeriodicProvider의 notifyListeners가 호출될 떄마다 build함수가 실행되고있다.'),
            ],
          ),
        ),
      ),
    );
  }
}
