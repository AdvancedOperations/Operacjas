//
//  OperationsTests.swift
//  OperationsTests
//
//  Created by Oleg Dreyman on 29.04.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operations

class OperationsTests: XCTestCase {
    
    let queue = OperationQueue()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegularBuilder() {
        let expectation = expectationWithDescription("Operation waiting")
        let operation = BlockOperation {
            print("here")
        }
        operation.observe {
            $0.didStart {
                print("Started")
            }
            $0.didSuccess {
                expectation.fulfill()
            }
            $0.didFail { errors in
                print(errors)
            }
        }
        queue.addOperation(operation)
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testBuilderWithFinished() {
        let expectation = expectationWithDescription("Operation waiting")
        let operation = BlockOperation {
            print("here")
        }
        operation.observe {
            $0.didFinishWithErrors { _ in
                expectation.fulfill()
            }
            $0.didSuccess {
                XCTFail()
            }
            $0.didFail { _ in
                XCTFail()
            }
        }
        queue.addOperation(operation)
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    // MARK: - NFD Tests
    
    class FailOperation: Operation {
        enum Error: ErrorType {
            case JustGoAway
        }
        override func execute() {
            finishWithError(Error.JustGoAway)
        }
    }
    class NoFailOperation: Operation {
        override func execute() {
            print("No fail")
            finish()
        }
    }
    
    func testNoFailed() {
        let fail1 = FailOperation()
        let noFail1 = NoFailOperation()
        
        let expectation = expectationWithDescription("No Fail Main")
        let noFailMain = NoFailOperation()
        noFailMain.observe { (operation) in
            operation.didFinishWithErrors { errors in
                XCTAssertTrue(!errors.isEmpty)
                debugPrint(errors)
                expectation.fulfill()
            }
        }
        
        noFailMain.addDependencies([fail1, noFail1])
        noFailMain.addCondition(NoFailedDependencies())
        queue.addOperation(fail1)
        queue.addOperation(noFail1)
        queue.addOperation(noFailMain)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testNoFailedOne() {
        let fail1 = FailOperation()
        let noFail1 = NoFailOperation()
        
        let expectation = expectationWithDescription("No Fail Main")
        let noFailMain = NoFailOperation()
        noFailMain.observe { (operation) in
            operation.didFinishWithErrors({ (errors) in
                XCTAssertEqual(errors.count, 1)
                debugPrint(errors)
                expectation.fulfill()
            })
        }
        
        noFailMain.addDependency(fail1, expectSuccess: true)
        noFailMain.addDependency(noFail1, expectSuccess: true)
        queue.addOperation(fail1)
        queue.addOperation(noFail1)
        queue.addOperation(noFailMain)
        
    func testMutually() {
        enum Category: String, MutualExclusivityCategory {
            case A
            case B
        }
        
        let operationA = BlockOperation {
            print("First")
        }
        operationA.setMutuallyExclusive(inCategory: Category.A)
        
        let expectation = expectationWithDescription("Waiting for second operation")
        let operationB = BlockOperation {
            print("Second")
            expectation.fulfill()
        }
        operationB.setMutuallyExclusive(inCategory: Category.A)
        operationB.observe { operation in
            operation.didStart {
                if !operationA.finished {
                    XCTFail()
                }
                print(operationA.finished)
            }
        }
        queue.addOperation(operationA)
        queue.addOperation(operationB)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
}
