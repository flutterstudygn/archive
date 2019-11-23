import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_test/bloc/stopwatch_bloc.dart';
import 'package:stream_test/bloc/page_navigation_bloc.dart';
import 'package:stream_test/provider_b.dart';

class ProviderA extends StatelessWidget {
  static const tag = 'ProviderA';

  @override
  Widget build(BuildContext context) {
    print('[$tag] on builder called');

    return Scaffold(
      appBar: AppBar(
        title: Text('ProviderA'),
      ),
      // 여러개의 Provider를 사용하기 위한 클래스.
      // (https://pub.dev/documentation/provider/latest/provider/MultiProvider-class.html)
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            // Bloc을 등록시킴과 동시에 초읽기 시작.
            builder: (_) => StopwatchBloc()..start(),
          ),
          ChangeNotifierProvider(
            builder: (_) => PageNavigationBloc(),
          ),
        ],
        // 두 개의 Provider에 대한 Consumer 클래스.
        // (https://pub.dev/documentation/provider/latest/provider/Consumer2-class.html)
        child: Consumer2<StopwatchBloc, PageNavigationBloc>(
          builder: (context, periodicBloc, pageNavigationBloc, _) {
            print('[$tag] on consumer builder called');

            // 현재 페이지가 가려졌다면 바로 빈 Widget인 SizedBox를 return한다.
            // 이 처리부분이 없으면 Flutter의 framework는 계속 이하 Widget을 그리게 되고
            // print('Tick from [$tag]')도 출력하게 된다. 
            // 만약 해당 코드가 로그가 아니라 시계 소리 출력이었다면 문제가 된다.
            // (혹은 유료 API call이라거나...)
            if (pageNavigationBloc.visibility == PageVisibility.covered) {
              return SizedBox();
            }

            print('Tick from [$tag]');

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    periodicBloc.seconds.toString(),
                    textAlign: TextAlign.center,
                  ),
                  RaisedButton(
                    onPressed: () => pageNavigationBloc.onCover(
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ProviderB(periodicBloc)),
                      ),
                    ),
                    child: Text(
                      'Push ProviderB',
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
