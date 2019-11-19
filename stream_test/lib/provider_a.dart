import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_test/provider_b.dart';
import 'package:stream_test/streams.dart';

class ProviderA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ProviderA'),
      ),
      body: Consumer<PeriodicProvider>(
        builder: (context, provider, button) {

          print('Beep from A');

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
                button
              ],
            ),
          );
        },
        child: RaisedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProviderB(Provider.of<PeriodicProvider>(context)),
            ),
          ),
          child: Text(
            'Push ProviderB',
          ),
        ),
      ),
    );
  }
}
