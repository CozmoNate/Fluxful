//
//  MockMiddleware.swift
//  FluxfulTests
//
//  Created by Natan Zalkin on 25/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

@testable import Fluxful

class MockMiddleware: Middleware {
    
    var handlers: [ObjectIdentifier: Any] = [:]
    
    init(dispatcher: Dispatcher) {
        register(MockAction.UpdateValue.self) { [weak dispatcher] (subject, action) in
            
            // Simulate background activity and event dispatched with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                dispatcher?.dispatch(MockAction.SetValue(value: action.value))
            }
            
            return .next(MockAction.SetValue(value: "reset"))
        }
        
        register(MockAction.UpdateNumber.self) { [weak dispatcher] (subject, action) in
            
            // Simulate background activity and event dispatched with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                dispatcher?.dispatch(MockAction.SetNumber(number: action.number))
            }
            
            return .stop()
        }
    }
}
