# Operations
**Operations** is an open-source implementation of concepts from [Advanced NSOperations](https://developer.apple.com/videos/play/wwdc2015/226/) talk.

`0.0.x` versions contains code directly from Apple's [sample project](https://developer.apple.com/sample-code/wwdc/2015/downloads/Advanced-NSOperations.zip).

## Usage

> *WARNING*: **Operations** are un-swifty as hell, with all these subclassing and reference semantics everywhere. But the goal of **Operations** is not to make `NSOperation` "swifty", but to make it more powerful *using* Swift. Operations are still a very great concept that can dramatically simplify the structure of your app, they are system-aware and they *just work*. So use them, why not ¯\_(ツ)_/¯

Before reading the **Usage** section, please go watch [Advanced NSOperations](https://developer.apple.com/videos/play/wwdc2015/226/) talk from Apple, it will help you to understand what's going on, especially if you're new to `NSOperation` and `NSOperationQueue`.

### Operations
Operations are abstract distinctive pieces of work. Each operation must accomplish some task, and the only thing it cares about is that task. **Operations** introduces `Operation` - an `NSOperation` subclass which add some new concepts and redefines readyness state, and `OperationQueue` - `NSOperationQueue` subclass which supports this concepts.

##### Creation of `Operation`
The best way to create an operation is to subclass `Operation`. Unlike `NSOperation`, here you only need to override new `execute()` method.

```swift
// WARNING! The operation below is absolutely useless
class LogOperation<T>: Operation {
    
    private let value: T
    init(value: T) {
        self.value = value
    }
    
    override func execute() {
        guard !cancelled else {
            finish()
            return
        }
        print(value)
        finish()
    }
    
}
```

> *TIP*: Better check `cancelled` property in a `guard` statement (not `if cancelled { ...`), because when the operation is `cancelled`, you need to *both* `finish()` and `return`, and sometimes that's easy to forget. `guard` guarantees that you're gonna return from the function.

Then you just add your operation to the queue:

```swift
let queue = OperationQueue()
let logOperation = LogOperation(value: "Test")
queue.addOperation(logOperation)
```

You can also use `BlockOperation` and create operation simply from the closure, like this:

```swift
let operation = BlockOperation {
    self.performSegueWithIdentifier("showEarthquake", sender: nil)
}
operationQueue.addOperation(operation)
```

##### Dependencies
Operations can depend on another operations. Adding dependencies is simple:

```swift
let first = OperationA()
let second = OperationB()
second.addDependency(first)
```

That means that `second` operation will not start before `first` operation enters it's `finished` state. Dependencies are also queue-independent, i.e. operations from different queues can depend on each other.

> *WARNING*: If the operation depends on itself, it's never gonna be executed, so don't do that. It may sound like an obvious thing, but seriously - always keep that in mind. If your operation queue is stalled, you've probably deadlocked yourself somewhere. Also, if some operation A depends on B, and B depends on A - your app is deadlocked again.

##### Operation observing
You can observe operation lifecycle by assigning one or more *observers* to it. *Observer* is an implementor of `OperationObserver` protocol:

```swift
final class LogObserver: OperationObserver {
    
    func operationDidStart(operation: Operation) {
        debugPrint("\(operation) did start")
    }
    
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        debugPrint("\(operation) did produce \(newOperation)")
    }
    
    func operationDidFinish(operation: Operation, errors: [ErrorType]) {
        if errors.isEmpty {
            debugPrint("\(operation) did finish succesfully")
        } else {
            debugPrint("\(operation) did failed with \(errors)")
        }
    }
    
}
```

```swift
let logger = LogObserver()
let operation = OperationA()
operation.addObserver(logger)
queue.addOperation(operation)
```

It's a good practice to implement `OperationObserver` directly if you want your observer to be reusable. However, if you only want to observe individual `Operation`, consider using `.observe(_:)` method on an `Operation` object, which makes observing very easy:

```swift
let myOperation = MyOperation()
myOperation.observe {
    $0.didStart {
        // operation did start
    }
    $0.didProduceAnotherOperation { operation in
        // operation did produce another operation
    }
    $0.didSuccess {
        // operation did finish successfuly
    }
    $0.didFail { errors in
        // operation did fail
    }
}
```
That creates a new observer and automatically assigns it to `myOperation`.

Instead of using `didSuccess` and `didFail`, you can also use `didFinishWithErrors`, which is gonna be notified when operation finishes, no matter successfuly or not. Also keep in mind that if you specify `didFinishWithErrors`, `didSuccess` and `didFail` will be ignored. In most cases, using `didSuccess` and `didFail` is the best option.
