//
//  Store.swift
//
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

/*
* Copyright (c) 2020 Natan Zalkin
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
*/

/// Store is an object that represents a state and mutates itself by handling dispatched actions.
public protocol Store: Dispatcher {
    
    /// A reducer closure associated with actions of specific type. Reducer synchronously apply changes to store.
    typealias Reducer<Action> = (_ subject: Self, _ action: Action) -> Void
    
    /// The list of type-erased reducer closures associated with specific types of actions.
    var reducers: [ObjectIdentifier: Any] { get set }
    
    /// The list of  middlewares.
    var middlewares: [Middleware] { get set }
    
    /// Applies the action bypassing middlewares.
    /// - Parameter action: The action to apply
    func apply<Action>(_ action: Action)
}
    
public extension Store {
    
    /// Associates a handler with actions of the specified type.
    /// - Parameters:
    ///   - action: The type of the actions to associate with the handler.
    ///   - reducer: The handler closure that will be invoked when the action received.
    func register<Action>(_ action: Action.Type, reducer: @escaping Reducer<Action>) {
        reducers.updateValue(reducer, forKey: ObjectIdentifier(Action.self))
    }
    
    /// Unregisters handler associated with actions of the specified type.
    /// - Parameter action: The action for which the associated handler should be removed.
    func unregister<Action>(_ action: Action.Type) {
        reducers.removeValue(forKey: ObjectIdentifier(Action.self))
    }
    
    /// Unregisters all action handlers
    func unregisterAll() {
        reducers.removeAll()
    }

    func apply<Action>(_ action: Action) {
        if let apply = reducers[ObjectIdentifier(Action.self)] as? Reducer<Action> {
            apply(self, action)
        }
    }
    
    func dispatch<Action>(_ action: Action) {
        middlewares
            .reduce(Composer(action)) { $0.handle(with: $1, from: self) }
            .apply(to: self)
    }
}
