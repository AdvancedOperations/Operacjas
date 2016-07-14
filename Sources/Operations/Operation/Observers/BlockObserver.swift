/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperationObserver protocol.
*/

import Foundation

/**
    The `BlockObserver` is a way to attach arbitrary blocks to significant events
    in an `Operation`'s lifecycle. Deprecated.
 
    - Note: Use `BlockObserver` only as a reusable object. For individual observing, use `operation.observe` instead.
*/
public struct BlockObserver: OperationObserver {
    // MARK: Properties
    
    private let enqueuingHandler: ((Operation) -> Void)?
    private let startHandler: ((Operation) -> Void)?
    private let produceHandler: ((Operation, NSOperation) -> Void)?
    private let finishHandler: ((Operation, [ErrorType]) -> Void)?
    
    public init(enqueuingHandler: ((Operation) -> Void)? = nil, startHandler: (Operation -> Void)? = nil, produceHandler: ((Operation, NSOperation) -> Void)? = nil, finishHandler: ((Operation, [ErrorType]) -> Void)? = nil) {
        self.enqueuingHandler = enqueuingHandler
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperationObserver
    
    public func operationDidEnqueue(operation: Operation) {
        enqueuingHandler?(operation)
    }
    
    public func operationDidStart(operation: Operation) {
        startHandler?(operation)
    }
    
    public func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        produceHandler?(operation, newOperation)
    }
    
    public func operationDidFinish(operation: Operation, errors: [ErrorType]) {
        finishHandler?(operation, errors)
    }
}
