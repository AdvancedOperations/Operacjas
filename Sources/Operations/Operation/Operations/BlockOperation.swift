/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This code shows how to create a simple subclass of DriftOperation.
*/

import Foundation

/// A closure type that takes a closure as its parameter.
public typealias DriftOperationBlock = (Void -> Void) -> Void

@available(*, unavailable, renamed="BlockDriftOperation")
public typealias BlockOperation = BlockDriftOperation

/// A sublcass of `DriftOperation` to execute a closure.
public final class BlockDriftOperation: DriftOperation {
    private let block: DriftOperationBlock?
    
    /**
        The designated initializer.
        
        - parameter block: The closure to run when the operation executes. This
            closure will be run on an arbitrary queue. The parameter passed to the
            block **MUST** be invoked by your code, or else the `BlockOperation`
            will never finish executing. If this parameter is `nil`, the operation
            will immediately finish.
    */
    public init(block: DriftOperationBlock? = nil) {
        self.block = block
        super.init()
    }
    
    /**
        A convenience initializer to execute a block on the main queue.
        
        - parameter mainQueueBlock: The block to execute on the main queue. Note
            that this block does not have a "continuation" block to execute (unlike
            the designated initializer). The operation will be automatically ended
            after the `mainQueueBlock` is executed.
    */
    public convenience init(mainQueueBlock: dispatch_block_t) {
        self.init(block: { continuation in
            dispatch_async(dispatch_get_main_queue()) {
                mainQueueBlock()
                continuation()
            }
        })
    }
    
    override public func execute() {
        guard let block = block else {
            finish()
            return
        }
        
        block {
            self.finish()
        }
    }
}
