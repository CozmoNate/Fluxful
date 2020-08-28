# Fluxful

[![License](https://img.shields.io/badge/license-MIT-ff69b4.svg)](https://github.com/kzlekk/Fluxful/raw/master/LICENSE)
[![Language](https://img.shields.io/badge/swift-5.0-orange.svg)](https://swift.org/blog/swift-5-released/)
[![Build Status](https://travis-ci.com/kzlekk/Fluxful.svg?branch=master)](https://travis-ci.com/kzlekk/Fluxful)
[![Coverage Status](https://coveralls.io/repos/github/kzlekk/Fluxful/badge.svg?branch=master)](https://coveralls.io/github/kzlekk/Fluxful?branch=master)

## About

Fluxful is a minimalistic framework provides protocols and extensions for managing global application state following Flux pattern practices. Fluxful is written in Swift 5 and designed to produce standalone modules incapsulating distinct parts of application business logic. Fluxful modules provide tools allowing to easily follow store changes and render UI that always in sync with the current state.

You can read more about Flux pattern [here](https://facebook.github.io/flux/docs/in-depth-overview/)

Fluxful flow diagram is similar to Redux. You can read about [here](http://slides.com/jenyaterpil/redux-from-twitter-hype-to-production#/11)

![Redux](redux-diagram.gif)

## Installation

### Swift Package Manager

Add "Fluxful" dependency in XCode

### CocoaPods

```ruby
pod 'Fluxful'
```

Add extension to support "conventional" observing:

```ruby
pod 'Fluxful/Reactive'
```

This will install the extension to Fluxful that enables possibility to observe store changes without using Combine or other libraries. With this extension you'll be able to subscribe to store changes by calling "addObserver" method and providing a change handler closure. "addObserver" returns a subscription object. Store subscription will be active until cancelled or the subscription object is disposed. You can use "notify" method inside the store action handlers and send notifications to subscribers with the information about which store properties has being changed by passing an array of "PartialKeyPath" objects.

## Usage


First you need to declare actions:

```swift

struct SetAmountAction {
    let value: UInt
}
    
struct FetchAmountAction {}
```


When you can implement middleware, that handles specific actions, run asynchronous work and updates the store:

```swift

class MyMiddleware: Middleware {
    
    var handlers: [ObjectIdentifier: Any] = [:]
    
    init() {
        register(FetchAmountAction.self, for: MyStore.self) { (action, store) in
            
            /* Here you can run code in background or make API call */ 
            
            // After that you should back to main thread and update the store
            DispatchQueue.main.async { [weak store] in
                store?.dispatch(SetAmountAction(value: /* Value received */))
            }
            
            // You can just intercept the action if it will not being handled in the store anyway
            return .stop()
        }
    }
}
```


And the store is just a state container:

``` swift
class MyStore: Store {

    private(set) var amount = 0
    
    var reducers: [ObjectIdentifier: Any]
    var middlewares: [Middleware]
    
    init() {
        reducers = [:]
        
        // Connect middleware
        middlewares = [MockMiddleware()]
        
        register(SetAmountAction.self) { (store, action) in
            // Mutate state
            store.amount = action.value
            // Notify observers. When using with SwiftUI, this part is not needed, if you marked mutable properties with @Published
            store.notify(keyPathsChanged: [\MyStore.amount])
        }
    }
}
```


That's it! Now store will send notification every time its state changes when the action was dispatched to the store. By adding the observers with 'addObserver' method, you can track state changes and update UI accordingly.

## Author


Natan Zalkin natan.zalkin@me.com

## License


Fluxful is available under the MIT license. See the LICENSE file for more info.
