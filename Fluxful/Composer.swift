//
//  Composer.swift
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

/// Composer is an opaque container that can transform, pass or stop action propagation.
public struct Composer {
    
    /// Passes the action to next reducer.
    public static func next<Action>(_ action: Action) -> Composer {
        return Composer(action)
    }

    /// Stops action propagation.
    public static func stop() -> Composer {
        return Composer()
    }
    
    internal var container: ActionContainer?
    
    internal init() {}
    
    internal init<Action>(_ action: Action) {
        container = Container(action)
    }
    
    /// Passes the action to middleware
    internal func pass<Subject: Store>(to middleware: Middleware, from store: Subject) -> Composer {
        return container?.pass(to: middleware, from: store) ?? self
    }
    
    /// Applies the action to the store.
    internal func apply<Subject: Store>(to store: Subject) {
        container?.apply(to: store)
    }
}

internal protocol ActionContainer {
    
    /// Passes the action to middleware
    func pass<Subject: Store>(to middleware: Middleware, from store: Subject) -> Composer
    
    /// Applies the action to the store.
    func apply<Subject: Store>(to store: Subject)
    
}

internal extension Composer {
    struct Container<Action>: ActionContainer {
        
        let action: Action
        
        init(_ action: Action) {
            self.action = action
        }
        
        func pass<Subject: Store>(to middleware: Middleware, from store: Subject) -> Composer {
            return middleware.handle(action, from: store)
        }
        
        func apply<Subject: Store>(to store: Subject) {
            store.apply(action)
        }
    }
}
