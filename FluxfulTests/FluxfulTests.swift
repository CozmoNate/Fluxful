//
//  FluxfulTests.swift
//  FluxfulTests
//
//  Created by Natan Zalkin on 25/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Quick
import Nimble

@testable import Fluxful
@testable import ReactiveFluxful

class FluxfulTests: QuickSpec {
    override func spec() {
        describe("Fluxful") {
            var subject: MockStore!
            
            beforeEach {
                subject = MockStore()
            }
            
            it("registered an actions correctly") {
                expect(subject.reducers[ObjectIdentifier(MockAction.SetValue.self)] as? MockStore.Reducer<MockAction.SetValue>).toNot(beNil())
                expect(subject.reducers[ObjectIdentifier(MockAction.SetNumber.self)] as? MockStore.Reducer<MockAction.SetNumber>).toNot(beNil())
            }
            
            context("when executing registered action") {
                
                beforeEach {
                    subject.dispatch(MockAction.SetValue(value: "sync test"))
                }
                
                it("handles the action and reduces the state correctly") {
                    expect(subject.value).to(equal("sync test"))
                }
            }
            
            context("when executing asynchronous action") {
                beforeEach {
                    subject.dispatch(MockAction.UpdateValue(value: "async test"))
                }
                
                it("can handles the action and correctly changes the state") {
                    expect(subject.value).to(equal("reset"))
                    expect(subject.value).toEventually(equal("async test"))
                }
            }
            
            context("when unregistered specific action") {
                beforeEach {
                    subject.unregister(MockAction.SetValue.self)
                    subject.dispatch(MockAction.SetValue(value: "test"))
                }

                it("does not handle unregistered action") {
                    expect(subject.reducers.count).to(equal(1))
                    expect(subject.value).to(equal("initial"))
                }
            }

            context("when unregistered all actions") {
                beforeEach {
                    subject.unregisterAll()
                }

                it("has no registered actions") {
                    expect(subject.reducers).to(beEmpty())
                }
            }
            
            context("when unregistered middleware handler") {
                var middleware: Middleware!
                
                beforeEach {
                    middleware = subject.middlewares[0]
                    middleware.unregister(MockAction.UpdateValue.self, for: MockStore.self)
                }
                
                it("does not the action") {
                    expect(middleware.handlers.count).to(equal(1))
                }
            }
            
            context("when unregistered all middleware handlers") {
                var middleware: Middleware!
                
                beforeEach {
                    middleware = subject.middlewares[0]
                    middleware.unregisterAll()
                }
                
                it("does not the action") {
                    expect(middleware.handlers).to(beEmpty())
                }
            }
            
            context("when intercepted action with middleware") {
                var middleware: Middleware!
                
                beforeEach {
                    middleware = subject.middlewares[0]
                    middleware.register(MockAction.SetValue.self, for: MockStore.self) { (action, store) in
                        return .stop()
                    }
                    subject.dispatch(MockAction.SetValue(value: "intercept"))
                }
                
                it("intercepts the action") {
                    expect(subject.value).to(equal("initial"))
                }
            }
            
            context("when subscribed to ANY changes and executes action") {
                var subscriptions: [Subscription]!
                var keyPaths: Set<PartialKeyPath<MockStore>>?
                
                beforeEach {
                    subscriptions = []
                    subject.addObserver { (store, paths) in
                        keyPaths = paths
                    }.store(in: &subscriptions)
                    subject.dispatch(MockAction.SetValue(value: "subscribe"))
                }
                
                it("notifies subscribers") {
                    expect(keyPaths).toEventually(equal(Set([\MockStore.value])))
                    expect(subject.value).toEventually(equal("subscribe"))
                }
                
                context("when canceled subscription and executed action") {
                    beforeEach {
                        subscriptions.forEach { $0.cancel() }
                        keyPaths = nil
                        subject.dispatch(MockAction.SetValue(value: "unsubscribe"))
                    }
                    
                    it("does not notify subscribers") {
                        expect(keyPaths).to(beNil())
                        expect(subject.value).to(equal("unsubscribe"))
                    }
                }
            }
            
            context("when subscribed to SPECIFIC changes and executes action") {
                var subscriptions: [Subscription]!
                var changed: Bool?
                
                beforeEach {
                    subscriptions = []
                    subject.addObserver(for: [\MockStore.value]) { (store) in
                        changed = true
                    }.store(in: &subscriptions)
                    subject.dispatch(MockAction.SetValue(value: "subscribe"))
                }
                
                it("notifies subscribers") {
                    expect(changed).toEventually(beTruthy())
                    expect(subject.value).toEventually(equal("subscribe"))
                }
                
                context("when canceled subscription and executed action") {
                    beforeEach {
                        subscriptions.forEach { $0.cancel() }
                        changed = nil
                        subject.dispatch(MockAction.SetValue(value: "unsubscribe"))
                    }
                    
                    it("does not notify subscribers") {
                        expect(changed).to(beNil())
                        expect(subject.value).to(equal("unsubscribe"))
                    }
                }
            }
        }
    }
}
