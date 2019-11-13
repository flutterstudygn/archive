### Infinite Scroll ListView
> overall : 무한스크롤 리스트뷰<br>
> author : huansuh<br>
> draft : 2019.11.13<br>

<br>
ListView widget을 통해 아래와 같이 무한스크롤을 구현할 수 있다.

```dart
ListView.builder(
  itemCount: itemList.length + 1,	// 실제 데이터수 + 1
  itemBuilder: (context, idx) {
    // 최하단 체크
    if(idx == itemCount) {
      // 데이터 요청 여부(end of data) 체크
      if(canLoadMore() == true) {
        loadMore();	// 추가 데이터 요청

        // 로딩 프로그레스 return
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        // 더 이상 데이터를 요청하지 않을 시 공백 Conatiner return
        return Container();
      }
    }
    return _buildItemRow(itemList[idx]); //  실제 개별 item view
  }
)
```
