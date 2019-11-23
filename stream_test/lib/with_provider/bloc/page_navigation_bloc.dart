import 'package:flutter/cupertino.dart';

enum PageVisibility { visible, covered }

/// [Navigator]에 의한 [Widget]의 상태 관리 Bloc.
class PageNavigationBloc extends ChangeNotifier {
  PageVisibility _visibility = PageVisibility.visible;

  PageVisibility get visibility => _visibility;

  /// [Navigator.push]에 의해 다른 [Widget]에게 덮히는 경우
  /// 해당 push의 반환 [Future]를 [resumeSignal]로 주면
  /// [_visibility]를 [PageVisibility.covered]로 바꿨다가
  /// 상위 [Widget]이 pop된 경우 [PageVisibility.visible]로
  /// 다시 바꾸어준다.
  void onCover(Future resumeSignal) async {
    _visibility = PageVisibility.covered;
    await resumeSignal;
    _visibility = PageVisibility.visible;
  }
}
