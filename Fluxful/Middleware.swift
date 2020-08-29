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

import Foundation

/// Middleware is an object that handles the action before the store will apply it. Middleware can run asynchronous work and update store when needed. Middleware can intercept an action before the store will receive it.
public protocol Middleware: AnyObject {
    
    /// A reducer closure associated with actions of specific type. Reducer synchronously apply changes to store.
    typealias Handler<Action, Subject: Store> = (_ action: Action, _ store: Subject) -> Composer

    /// The list of type-erased reducer closures associated with specific types of actions and stores.
    var handlers: [ObjectIdentifier: Any] { get set }
}

public extension Middleware {
    
    /// Associates a handler with the specific actions/store type combination.
    /// - Parameters:
    ///   - action: The type of the actions associated with the reducer.
    ///   - store: The type of the store associated with the reducer.
    ///   - handler: The handler closure that will be invoked when the action received.
    func register<Action, Subject: Store>(_ action: Action.Type, for store: Subject.Type, handler: @escaping Handler<Action, Subject>){
        handlers.updateValue(handler, forKey: ObjectIdentifier(Handler<Action, Subject>.self))
    }
    
    /// Unregisters handler associated with the specific action/store type combination.
    /// - Parameters:
    ///   - action: The type of the actions associated with the reducer.
    ///   - store: The type of the store associated with the reducer.
    func unregister<Action, Subject: Store>(_ action: Action.Type, for store: Subject.Type) {
        handlers.removeValue(forKey: ObjectIdentifier(Handler<Action, Subject>.self))
    }
    
    /// Unregisters all  reducers
    func unregisterAll() {
        handlers.removeAll()
    }
    
    /// Handles the action and optionally transforms or cancels the action passed to the store.
    /// - Parameters:
    ///   - action: The action to be transformed, cancelled or passed as is.
    ///   - store: The instance of the store that will apply the action.
    /// - Returns: The ActionReducer object that carries the next action.
    func handle<Action, Subject: Store>(_ action: Action, from store: Subject) -> Composer {
        guard let handle = handlers[ObjectIdentifier(Handler<Action, Subject>.self)] as? Handler<Action, Subject> else {
            return .next(action) // Pass the action as is
        }
        
        return handle(action, store)
    }
}
