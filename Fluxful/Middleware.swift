//
//  Middleware.swift
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

/// Middleware is an object that handles the action before the store will apply it. Middleware can run asynchronous work and update store when needed. Middleware can intercept an action before the store will receive it.
public protocol Middleware: AnyObject {
    
    /// A handler closure associated with actions of specific type.
    typealias Handler<Action> = (_ subject: Self, _ action: Action) -> Composer

    /// The list of type-erased handler closures associated with specific types of actions.
    var handlers: [ObjectIdentifier: Any] { get set }
    
    /// Handles the action and optionally transforms or cancels the action by returning appropriate action composer.
    /// - Parameters:
    ///   - action: The action to be transformed, cancelled or passed as is.
    ///   - store: The instance of the store that will apply the action.
    /// - Returns: The action composer object that carries the next action.
    func handle<Action>(_ action: Action) -> Composer
}

public extension Middleware {
    
    /// Associates a handler with the specific actions/store type combination.
    /// - Parameters:
    ///   - action: The type of the actions associated with the reducer.
    ///   - handler: The handler closure that will be invoked when the action received.
    func register<Action>(_ action: Action.Type, handler: @escaping Handler<Action>){
        handlers.updateValue(handler, forKey: ObjectIdentifier(Handler<Action>.self))
    }
    
    /// Unregisters handler associated with the specific action/store type combination.
    /// - Parameters:
    ///   - action: The type of the actions associated with the reducer.
    ///   - store: The type of the store associated with the reducer.
    func unregister<Action>(_ action: Action.Type) {
        handlers.removeValue(forKey: ObjectIdentifier(Handler<Action>.self))
    }
    
    /// Unregisters all  reducers
    func unregisterAll() {
        handlers.removeAll()
    }
    
    func handle<Action>(_ action: Action) -> Composer {
        guard let handle = handlers[ObjectIdentifier(Handler<Action>.self)] as? Handler<Action> else {
            return .next(action) // Pass the action as is
        }
        
        return handle(self, action)
    }
}
