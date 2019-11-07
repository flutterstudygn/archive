### JSON and serialization
> overall : JSON and Serialization docs 정리<br>
> author : huansuh<br>
> draft : 2019.11.07<br>
> reference : [flutter.dev/docs/...](https://flutter.dev/docs/development/data-and-backend/json)<br>



## 0. Background
### Serialization
* Encoding (serialization) : Data -> String
* Decoding (deserialization) : String -> Data

### Json libraries in Flutter
**Is there a GSON/Jackson/Moshi equivalent in Flutter?**
=> The simple answer is **NO**.

위와 같은 라이브러리들은 [runtime reflection](https://ko.wikipedia.org/wiki/%EB%B0%98%EC%98%81_(%EC%BB%B4%ED%93%A8%ED%84%B0_%EA%B3%BC%ED%95%99))이 필요하며, 생성해 놓은 코드를 통해 runtime에 serialize에 사용된다.
그러나 Dart의 [tree shaking](https://en.wikipedia.org/wiki/Tree_shaking) (최적화를 위해 release build 시 미사용 코드를 제거하는 동작)과 관련하여,
reflection을 사용할 경우 모든 코드를 자동으로 참조하게 되므로 tree shaking에 의한 최적화(app size 축소)에 어려움이 생긴다.

따라서 아래 제시하는 방법과 같이 직접 serialization code를 작성하거나, code generation을 사용하여야 한다.



## 1. Manual Serialization
- `dart:convert` 의 `jsonDecode()`를 사용
- 소규모 프로젝트에서 model의 개수가 적거나 복잡도가 낮을 때 주로 사용
- pros
	- 외부 종속성 및 setup 없이 손쉽게 사용할 수 있다.
- cons
	- Typo error가 발생할 수 있다.
	- 모델이 변경될 때 누락될 누락되는 경우가 발생할 수 있다.
	=> runtime exception

**1. Serializing JSON inline**

`dart:convert`의 `jsonDecode()`를 사용하여 아래와 같이 deserialize하여 데이터에 접근할 수 있다.
```dart
Map<String, dynamic> user = jsonDecode(jsonString);

print('Howdy, ${user['name']}!');
print('We sent the verification link to ${user['email']}.');
```
but, `jsonDecode()`는 `map`을 return하므로 `user['name']`과 같이 멤버 변수 이름으로 접근해야 하며, 이는 runtime exception을 발생시킬 수 있다.
<br>

**2. Serializing JSON inside model classes**

위와 같은 문제를 해결하기 위해, model class 내부에서 serialize, deserialize하도록 작성할 수 있다.
- Deserialize : `User.fromMappedJson(Map<String, dynamic> json)`과 같이 `map`을 인자로 하는 생성자를 생성하여 사용한다.
- Serialize : `Map<String, dynamic> toJson()`과 같이 `map`을 return하는 method를 추가하여 사용한다.
  ```dart
  class User {
      final String name;
      final String email;

      User(this.name, this.email);

      User.fromMappedJson(Map<String, dynamic> json)
        : name = json['name'],
          email = json['email'];

      Map<String, dynamic> toJson() =>
      {
        'name': name,
        'email': email,
      };
  }
  ```
- 위와 같이 생성한 model에 대해 아래와 같이 사용할 수 있다.
  ```dart
  // Deserialize
  Map userMap = jsonDecode(jsonString);
  var user = User.fromMappedJson(userMap);

  print('Howdy, ${user.name}!');
  print('We sent the verification link to ${user.email}.');

  // Serialize
  String json = jsonEncode(user);
  ```

## 2. Automated serialization using code generation
- 외부 라이브러리를 사용하여 encoding boilerplate를 생성하여 사용
- 프로젝트 규모나 model의 개수, 복잡도가 커질 때 주로 사용
- pros
	- runtime exception 발생 가능성이 적다.
- cons
	- 외부 종속성 설정 및 기타 설정이 필요하다.
	- 사용하는 라이브러리에 따라 enum, List, nested class 등에 대해 정상 동작하는지 확인이 필요하다.

아래에서 사용하는 예시는 [json_serializable](https://pub.dev/packages/json_serializable) 패키지를 사용한다.

**1. json_serializable 패키지 설정**

`pubspec.yaml`에 아래와 같이 추가 후, `flutter pub get` 실행.
```yaml
dependencies:
  # Your other regular dependencies here
  json_annotation: ^2.0.0

dev_dependencies:
  # Your other dev_dependencies here
  build_runner: ^1.0.0
  json_serializable: ^2.0.0
```
:: dev_dependencies : 개발 환경에서만 사용되며, app source code에 포함되지 않는다.
<br>

**2. Model class 작성**
```dart
import 'package:json_annotation/json_annotation.dart';

// This allows the `User` class to access private members in
// the generated file. The value for this is *.g.dart, where
// the star denotes the source file name.
part 'user.g.dart';

// An annotation for the code generator to know that this class needs the
// JSON serialization logic to be generated.
@JsonSerializable()
class User {
  User(this.name, this.email);

  String name;
  String email;

  // A necessary factory constructor for creating a new User instance
  // from a map. Pass the map to the generated `_$UserFromMappedJson()` constructor.
  // The constructor is named after the source class, in this case, User.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // `toJson` is the convention for a class to declare support for serialization
  // to JSON. The implementation simply calls the private, generated
  // helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```
- `import 'package:json_annotaion/json_annotation.dart` : json_annotaion 패키지 import
- `part 'user.g.dart'` : generated file에 접근하도록 명시. (처음에 해당 라인에서 error가 발생하여도 무시하고 진행)
- `@JsonSerializable()` : 아래 class가 serialization logic을 포함하도록 명시.
- `factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json)`
: generated file의 deserialize logic 호출
- `Map<String, dynamic> toJson() => _$UserToJson(this)` : generated file의 serialize logic 호출


※`JsonKey()` annotaion을 통해 serialization 속성을 설정할 수 있다.
```dart
@JsonKey(name: 'registration_date_millis')
final int registrationDateMillis;
```
- 다른 설정은 [json_annotaion docs](https://pub.dev/documentation/json_annotation/latest/json_annotation/JsonKey/JsonKey.html) 참고
<br>


**3. code generation 실행**
code generation을 통해 실제 serialization, deserialization logic을 포함한 boilerplate를 생성해 주어야 한다.
(위 예제에서의 user.g.dart 파일이 생성된다.)

::**3-1. One-time code generation**
- model class가 변경될 때마다 아래 동작을 수행해주어야 한다.
- `flutter pub run build_runner build`

::**3-2. Generation code continuously**
- Watcher를 통해 source file이 변경될때마다 필요한 파일에 대해 자동으로 code generation을 수행하는 방식
- `flutter pub run build_runner watch`
<br>

**4. Use in code**

```dart
// Deserialize
Map userMap = jsonDecode(jsonString);
var user = User.fromJson(userMap);

// Serialize
String json = jsonEncode(user);
```
<br>

**※ Nested class**

class의 member로 다른 class가 있는 경우.
- `@JsonSerializable(explicitToJson: true)` 설정을 사용하여야 한다.

```dart
/// address.dart
import 'package:json_annotation/json_annotation.dart';
part 'address.g.dart';

@JsonSerializable()
class Address {
  String street;
  String city;
  
  Address(this.street, this.city);
  
  factory Address.fromMappedJson(Map<String, dynamic> json) => _$AddressFromMappedJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this); 
}

...
/// user.dart
import 'address.dart';
import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  String firstName;
  Address address;
  
  User(this.firstName, this.address);

  factory User.fromMappedJson(Map<String, dynamic> json) => _$UserFromMappedJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```
