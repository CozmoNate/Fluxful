//
//  Action.swift
//  FluxfulTests
//
//  Created by Natan Zalkin on 25/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

enum MockAction {
    
    struct SetValue {
        let value: String
    }
    
    struct SetNumber {
        let number: Int
    }
    
    struct UpdateValue {
        let value: String
    }
    
    struct UpdateNumber {
        let number: Int
    }
    
}
