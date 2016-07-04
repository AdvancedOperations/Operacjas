//
//  VitalOperationsTests.swift
//  Operations
//
//  Created by Oleg Dreyman on 04.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operations

class VitalOperationsTests: XCTestCase {

    func testVitalOperation() {
        let testQueue = OperationQueue()
        let importantPrinter = BlockOperation {
            print("I am so freaking important so I'll make anyone wait for me, bitches")
        }
        importantPrinter.vital = true
        testQueue.addOperation(importantPrinter)
        let expectation = expectationWithDescription("Waiting for next operation to start")
        let lessImportantPrinter = BlockOperation {
            print("I am just a regular printer")
        }
        lessImportantPrinter.observe { operation in
            operation.didStart {
                if !importantPrinter.finished {
                    XCTFail("This operation should wait for vitals")
                }
            }
            operation.didSuccess {
                expectation.fulfill()
            }
        }
        testQueue.addOperation(lessImportantPrinter)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testMultipleVitals() {
        let testQueue = OperationQueue()
        var last = -1
        for index in 0 ... 5 {
            let important = BlockOperation {
                XCTAssertEqual(last, index - 1)
                print("I am so \(index) important")
                last = index
            }
            important.vital = true
            testQueue.addOperation(important)
        }
        let expectation = expectationWithDescription("Waiting for start of non-vital operation")
        let nonImportant = BlockOperation {
            print("Regular is my style")
        }
        nonImportant.observe {
            $0.didSuccess {
                expectation.fulfill()
            }
        }
        testQueue.addOperation(nonImportant)
        waitForExpectationsWithTimeout(8.0, handler: nil)
    }

}
