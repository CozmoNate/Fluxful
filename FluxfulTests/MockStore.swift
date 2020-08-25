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
    var middlewares: [Middleware] = [MockMiddleware()]
    
    init() {
        register(MockAction.SetValue.self) { (store, action) in
            store.value = action.value
            store.notify(keyPathsChanged: [\MockStore.value])
        }
        
        register(MockAction.SetNumber.self) { (store, action) in
            store.number = action.number
            store.notify(keyPathsChanged: [\MockStore.number])
        }
    }
}

