# Key in flutter

A Key is an identifier for Widgets, Elements ans SemanicsNodes.

## Widget.key
Controls how one widget replaces another widget in the tree.
* tree 내에서 runtimeType과 Key 속성이 둘다 같으면 새로운 widget은 기존 widget의 element를 재사용(update)지만, 그렇지 않으면 기존 element가 제거되고 새로운 element를 생성하여 삽입한다.
* GlobalKey를 widget의 key로 사용하면, 해당 element가 tree 상에서 이동되어도 state를 유지할 수 있다.


## When do you use widget key
* 대부분은 필요 없다.
* 스크롤 위치를 유지하거나, 컬렉션의 수정상태를 보존하는 등의 경우에 사용

## Where to put key
* local key는 one-level child 에서만 비교
* 보존하고자 하는 위젯 트리의 제일 상단에 Key를 넣어라


## Key의 종류
- Local Key : 같은 부모 아래에서 유일한 값을 가져야 한다.
	* Value Key : key의 unique 비교 값으로 value를 받는 Key
	```dart
    class ValueKey<T> extends LocalKey {
    	// Creates a key that delegates its [operator==] to the given value.
	    const ValueKey(this.value);

    	// The value to which this key delegates its [operator==]
	    final T value;
    	...
    }
    ```
	* Object Key : key의 unique 비교 값으로 Object를 받는 Key
	```dart
    class ObjectKey extends LocalKey {
        // Creates a key that uses [identical] on [value] for its [operator==].
        const ObjectKey(this.value);

        // The object whose identity is used by this key's [operator==].
        final Object value;
        ...
	}
	```
	* Unique Key : key의 unique 비교 값으로 unique hash를 받는 Key
	```dart
    class UniqueKey extends LocalKey {
        // Creates a key that is equal only to itself.
        // ignore: prefer_const_constructors_in_immutables , never use const for this class
        UniqueKey();

        @override
        String toString() => '[#${shortHash(this)}]';
    }
	```
	don't use random number as key
- GlobalKey : App 전체에 걸쳐 유일한 값을 갖도록 하는 key.
	- BuildContext나 StatefulWidget의 State 등 해당 element와 연관된 객체에 접근을 제공해준다.
	```dart
    abstract class GlobalKey<T extends State<StatefulWidget>> extends Key {
    /// Creates a [LabeledGlobalKey], which is a [GlobalKey] with a label used for
    /// debugging.
    ///
    /// The label is purely for debugging and not used for comparing the identity
    /// of the key.
    factory GlobalKey({ String debugLabel }) => LabeledGlobalKey<T>(debugLabel);

    /// Creates a global key without a label.
    ///
    /// Used by subclasses because the factory constructor shadows the implicit
    /// constructor.
    const GlobalKey.constructor() : super.empty();
	```
- Key
```dart
class UniqueKey extends LocalKey {
  // Creates a key that is equal only to itself.
  // ignore: prefer_const_constructors_in_immutables , never use const for this class
  UniqueKey();

  @override
  String toString() => '[#${shortHash(this)}]';
}
```


### 위젯 트리 내에서 상태를 보존하고 싶은 경우에 Key를 사용해라!

https://medium.com/flutter/keys-what-are-they-good-for-13cb51742e7d
