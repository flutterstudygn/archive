# State management
> Overall : Flutter State management 개요<br>
> author: huansuh<br>
> draft : 191104<br>
> reference : [flutter.dev/docs/...](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)

## Think declaratively

- Flutter is declarative.
![](https://flutter.dev/assets/development/data-and-backend/state-mgmt/ui-equals-function-of-state-54b01b000694caf9da439bd3f774ef22b00e92a62d3b2ade4f2e95c8555b8ca7.png)
  - UI : The layout on the screen
  - f : build methods
  - state : the application state

:: App의 state가 변경되면, redraw 를 trigger 하므로, `widget.setText`와 같이 UI를 직접 변경하지 않는다.
- Declarative UI vs Imperative UI
  ```dart
  // Declarative style
  return ViewB(
      color: red,
      child: ViewC(...),
  );
  ```
  ```java
  // Imperative style
  b.setColor(red);
  b.clearChildren();
  ViewC c3 = new ViewC(...);
  b.add(c3);
  ```

## Ephemeral state & App state
Base) App이 실행되는 동안 메모리 상에 올라가는 모든 것들이 state다.

1. UI를 rebuild하기 위해 필요한 모든 데이터
2. 이러한 데이터는 ephemeral(수명이 짧은) state와 app state로 구분된다.


- **Ephemeral state**
    - a.k.a. UI state or local state
    - 단일 위젯에 포함되는 state
    - 다른 Widget에서 접근할 필요가 없다. ⇒ All you need is a **StatefulWidget**
    - ex : **current page** in PageView, **current progress** of a complex animation, **current selected tab** in a BottomNavigationBar
		```dart
        class MyHomepage extends StatefulWidget {
          @override
          _MyHomepageState createState() => _MyHomepageState();
        }

        class _MyHomepageState extends State<MyHomepage> {
          int _index = 0;

          @override
          Widget build(BuildContext context) {
            return BottomNavigationBar(
              currentIndex: _index,
              onTap: (newIndex) {
                setState(() {
                  _index = newIndex;
                });
              },
              // ... items ...
            );
          }
        }
        ```

<br>

- **App state**
    - a.k.a. shared state
    - App 상의 다양한 Widget에서 공유되어 사용되는 데이터
또는 user sessions 상에 유지되는 데이터
    - ex: User preferences, Login info, Notifications in a social networking app, The shopping cart in an e-commerce app, Read/unread state of articles in a news app

- There is no clear-cut rule, Do whatever is less awkward.

## Simple app state management

- Flutter를 처음 접하거나, 다른 방법을 사용할 필요가 굳이 없다면 **Provider**

![](https://flutter.dev/assets/development/data-and-backend/state-mgmt/simple-widget-tree-19cb2528c56ef04924de364b4d0e08b73f4bcf7231aad0d6bc0eb1919e543fb9.png)

### * Lifting state up

state를 사용하는 widget 보다 상위에 state를 두어라

```dart
// BAD: DO NOT DO THIS
void myTapHandler() {
  var cartWidget = somehowGetMyCartWidget();
  cartWidget.updateWith(item);
}

class MyCartWidget extends ...Widget {
    Widget build(BuildContext context) {
      return SomeWidget(
        // The initial state of the cart.
      );
    }

    void updateWith(Item item) {
      // Somehow you need to change the UI from here.
    }
}
```

```dart
// GOOD
void myTapHandler(BuildContext context) {
  var cartModel = somehowGetMyCartModel(context);
  cartModel.add(item);
}

class MyCartWidget extends ...Widget {
    Widget build(BuildContext context) {
      var cartModel = somehowGetMyCartModel(context);
      return SomeWidget(
        // Just construct the UI once, using the current state of the cart.
      );
    }
}
```

![](https://flutter.dev/assets/development/data-and-backend/state-mgmt/simple-widget-tree-with-cart-088b22c4ef4e4389a1cababaceaadcd36ba3de37613080942885263c36e29595.png)

### * Accessing the state

<h4>1. Passing callback</h4>

callback을 전달하여 사용하는 방법
```dart
@override
Widget build(BuildContext context) {
  return SomeWidget(
    // Construct the widget, passing it a reference to the method above.
    MyListItem(myTapCallback),
  );
}

void myTapCallback(Item item) {
  print('user tapped on $item');
}
```
* but, 여러군데에서 사용될 경우, callback을 계속 전달해주어야 한다.
* Flutter에서는 descendants(not just their child, but any widgets below them)에 data와 service를 전달해 주는 방법이 존재한다. InheritedWidget, InheritedNotifier, InheritedModel, ...

<h4>2. Provider</h4>

Provider를 사용하면 callback, InheriedWidget 같은 개념에 크게 걱정할 필요없이 ChangeNotifier, ChangeNotifierProvider, Consumer만 잘 알아두면 된다.

- ChangeNotifier
	- 변경 알림(change notification)을 listener에게 제공한다.
	- Provider에서 ChangeNotifier는 app state를 캡슐화하는 방법으로 사용된다.
	- ChangeNotifier는 App의 scope, model에 따라 하나만 사용될 수도, 여러 개가 사용될 수도 있다.
	- ChangeNotifier와 provider가 함께 사용될 필요는 없지만 함께 사용되기 용이하다.
    ```dart
    class CartModel extends ChangeNotifier {
    	/// Internal, private state of the cart.
        final List<Item> _items = [];

    	/// An unmodifiable view of the items in the cart.
        UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

    	/// The current total price of all items (assuming all items cost $42).
        int get totalPrice => _items.length * 42;

    	/// Adds [item] to cart. This is the only way to modify the cart from outside.
        void add(Item item) {
            _items.add(item);
            // This call tells the widgets that are listening to this model to rebuild.
            notifyListeners();
        }
    }
    ```
    - model이 변경될 시 `notifyListener()`를 호출하면, model을 subscribe하는 widget(UI)가 변경된다.
<br>

- ChangeNotifierProvider
	- ChangeNotifierProvider는 ChangeNotifier를 자손으로 제공하는 widget이다.
	- 'Lifting state up'에 따라 ChangeNotifierProvider는 해당 model을 사용하는 widget의 최 상위에 구현한다.
    ```dart
    void main() {
        runApp(
            ChangeNotifierProvider(
                builder: (context) => CartModel(),
                child: MyApp(),
            ),
        );
    }
    ```
	- builder 에서 model을 build한다.
	- ChangeNotifierProvider에서 model이 rebuild되지 않도록 하며, model instance의 dispose를 자동 호출한다.
	- 여러 model을 사용한 경우 MultiProvider를 사용할 수 있다.
    ```dart
    void main() {
        runApp(
            MultiProvider(
                providers: [
                    ChangeNotifierProvider(builder: (context) => CartModel()),
                    Provider(builder: (context) => SomeOtherClass()),
                ],
                child: MyApp(),
            ),
        );
    }
    ```
<br>

- Consumer
	- 이제 ChangeNotifier는 ChangeNotifierProvider를 통해 Widget에 전달될 수 있다.
	- Consumer Widget을 통해 변경 사항을 수집할 수 있다.
	```dart
	return Consumer<CartModel>(
    	builder: (context, cart, child) {
        	return Text("Total price: ${cart.totalPrice}");
        },
    );
	```
	- Consumer Widget에서 사용할 Model을 generic으로 명시해주어야 한다. `Consumer<CartModel>`
	- ChangeNotifier가 변경될 때마다 `builder`가 호출된다.
(`notifyListeners()`가 호출될 때마다 해당 Model과 연관된 모든 Consumer의 `builder`가 호출된다.)

* Optimization
	1. Consumer는 최대한 하위 Widget에 위치하도록 한다.
    ```dart
    // Bad case
    return Consumer<CartModel>(
        builder: (context, cart, child) {
            return HumongousWidget(
                // ...
                child: AnotherMonstrousWidget(
                    // ...
                    child: Text('Total price: ${cart.totalPrice}'),
                ),
            );
        },
    );
    ```

	```dart
    // Good case
    return HumongousWidget(
        // ...
        child: AnotherMonstrousWidget(
            // ...
            child: Consumer<CartModel>(
                builder: (context, cart, child) {
                	return Text('Total price: ${cart.totalPrice}');
                },
            ),
        ),
    );
	```
    2. 변경과 무관한 widget은 child(3rd parameter)를 활용한다.
	```dart
    return Consumer<CartModel>(
      builder: (context, cart, child) => Stack(
            children: [
              // Use SomeExpensiveWidget here, without rebuilding every time.
              child,
              Text("Total price: ${cart.totalPrice}"),
            ],
          ),
      // Build the expensive widget here.
      child: SomeExpensiveWidget(),
    );
	```
- Provider.of
	- data 값이나, 해당 data로 인해 rebuild가 필요하지 않지만, data/service에 대한 접근이 필요한 경우가 있다. 이러한 경우 Consumer를 사용해도 무방하지만 wasteful.
	- 아래와 같이 사용하면, build 메소드 내부에서 사용해도 해당 widget이 rebuild되지 않는다.
    ```dart
    Provider.of<CartModel>(context, listen: false).clearAll()
    ```
