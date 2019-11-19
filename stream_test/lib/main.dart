import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_test/provider_a.dart';
import 'package:stream_test/stream_builder_a.dart';
import 'package:stream_test/streams.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'example app',
      theme: ThemeData(
        textTheme: TextTheme(
          body1: TextStyle(
            fontSize: 30.0,
          ),
          button: TextStyle(
            fontSize: 30.0,
          ),
        ),
      ),
      home: _RootPage(),
    );
  }
}

class _RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Widget with Stream'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StreamBuilderA(),
                ),
              ),
              child: Text('StreamBuilder'),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider<PeriodicProvider>(
                    builder: (_) => PeriodicProvider(),
                    child: ProviderA(),
                  ),
                ),
              ),
              child: Text('Provider'),
            ),
          ],
        ),
      ),
    );
  }
}
