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
    public static func next<Action, Subject: Store>(_ action: Action, _ store: Subject) -> Composer {
        return Composer(pass: { $0.handle(action, store) }, apply: { $0.apply(action) })
    }

    /// Stops action propagation.
    public static func stop() -> Composer {
        return Composer()
    }
    
    internal var pass: ((Middleware) -> Composer)?
    internal var apply: ((Store) -> Void)?
    
    internal init(pass: ((Middleware) -> Composer)? = nil, apply: ((Store) -> Void)? = nil) {
        self.pass = pass
        self.apply = apply
    }
}

internal extension Composer {
    
    /// Dispatches the underlying action to middleware and return reducer with the action passed by the middleware.
    func pass(to middleware: Middleware) -> Composer {
        return pass?(middleware) ?? Composer(apply: apply)
    }
    
    /// Applies the underlying action to the store.
    func apply(to store: Store) {
        apply?(store)
    }
}
