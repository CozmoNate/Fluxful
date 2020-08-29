//
//  MockStore.swift
//  ReactiveStoreTests
//
//  Created by Natan Zalkin on 17/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

@testable import Fluxful
@testable import ReactiveFluxful

class MockStore: Store {

    private(set) var value = "initial"
    private(set) var number = 0
    
    var reducers: [ObjectIdentifier: Any] = [:]
    var middlewares: [Middleware] = []
    var lastQueueIdentifier: UUID!
    
    init() {
        middlewares.append(MockMiddleware(dispatcher: self))
        
        register(MockAction.SetValue.self) { (subject, action) in
            subject.lastQueueIdentifier = DispatchQueue.getSpecific(key: FluxfulQueueIdentifierKey)
            subject.value = action.value
            subject.notify(keyPathsChanged: [\MockStore.value])
        }
        
        register(MockAction.SetNumber.self) { (subject, action) in
            subject.lastQueueIdentifier = DispatchQueue.getSpecific(key: FluxfulQueueIdentifierKey)
            subject.number = action.number
            subject.notify(keyPathsChanged: [\MockStore.number])
        }
    }
}

