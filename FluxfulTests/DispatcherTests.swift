//
//  DispatcherTests.swift
//  FluxfulTests
//
//  Created by Natan Zalkin on 29/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Quick
import Nimble

@testable import Fluxful

class DispatcherTests: QuickSpec {

    override func spec() {
        describe("Dispatcher") {

            var dispatcher: MockStore!
            var queue: DispatchQueue!

            beforeEach {
                dispatcher = MockStore()
                queue = DispatchQueue(label: "Test", qos: .background)
            }
            
            context("when dispatched action on queue") {

                beforeEach {
                    dispatcher.dispatch(MockAction.SetValue(value: "queue test"), on: queue)
                }

                it("performs action") {
                    expect(dispatcher.value).toEventually(equal("queue test"))
                    expect(dispatcher.lastQueueIdentifier).toEventually(equal(queue.getSpecific(key: FluxfulQueueIdentifierKey)))
                }
            }
            
            context("when dispatched action from another queue") {

                beforeEach {
                    DispatchQueue.main.async {
                        dispatcher.dispatch(MockAction.SetValue(value: "another queue test"), on: queue)
                    }
                }

                it("performs action") {
                    expect(dispatcher.value).toEventually(equal("another queue test"))
                    expect(dispatcher.lastQueueIdentifier).toEventually(equal(queue.getSpecific(key: FluxfulQueueIdentifierKey)))
                }
            }
        }
    }

}
