//
//  ActionReducer.swift
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

/// ActionReducer is an object used by middleware to transform or pass  actions to another reducer or to apply action to the store.
public struct ActionReducer {
    
    /// Passes the action to next reducer.
    public static func next<Action, Subject: Store>(_ action: Action, _ store: Subject) -> ActionReducer {
        return ActionReducer(reduce: { $0.handle(action, store) }, apply: { store.apply(action) })
    }

    /// Stops action propagation.
    public static func stop() -> ActionReducer {
        return ActionReducer()
    }
    
    private var reduce: ((Middleware) -> ActionReducer)?
    private var apply: (() -> Void)?
    
    /// Dispatches underlying action to middleware and return reducer with the action passed by the middleware.
    internal func handle(with middleware: Middleware) -> ActionReducer {
        return reduce?(middleware) ?? ActionReducer(apply: apply)
    }
    
    /// Applies underlying action to underlying store.
    internal func applyToStore() {
        apply?()
    }
}
