//
//  Dispatcher.swift
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

/// Dispatcher is a protocol describing an object that dispatches actions
public protocol Dispatcher: AnyObject {
    
    /// Dispatches the action
    func dispatch<Action>(_ action: Action)
}

extension Dispatcher {
    
    /// Asynchronously dispatches the action on specified queue using barrier flag (serially). If already running on the specified queue, dispatches the action synchronously.
    /// - Parameters:
    ///   - action: The action to dispatch.
    ///   - queue: The queue to dispatch action on.
    func dispatch<Action>(_ action: Action, on queue: DispatchQueue) {
        if DispatchQueue.isRunning(on: queue) {
            dispatch(action)
        } else {
            queue.async(flags: .barrier) {
                self.dispatch(action)
            }
        }
    }
}

internal let FluxfulQueueIdentifierKey = DispatchSpecificKey<UUID>()

internal extension DispatchQueue {
    
    static func isRunning(on queue: DispatchQueue) -> Bool {
        var identifier: UUID! = queue.getSpecific(key: FluxfulQueueIdentifierKey)
        if identifier == nil {
            identifier = UUID()
            queue.setSpecific(key: FluxfulQueueIdentifierKey, value: identifier)
        }
        return DispatchQueue.getSpecific(key: FluxfulQueueIdentifierKey) == identifier
    }
}
