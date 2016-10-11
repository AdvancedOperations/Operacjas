/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The file shows how to make an OperacjaCondition that composes another OperacjaCondition.
*/

import Foundation

/**
    A simple condition that causes another condition to not enqueue its dependency.
    This is useful (for example) when you want to verify that you have access to
    the user's location, but you do not want to prompt them for permission if you
    do not already have it.
*/
public struct SilentCondition<T : OperacjaCondition> : OperacjaCondition {
    public let condition: T
    
    public static var name: String {
        return "Silent<\(T.name)>"
    }
        
    public init(condition: T) {
        self.condition = condition
    }
    
    public func dependency(for operation: Operacja) -> Operation? {
        // Returning nil means we will never a dependency to be generated.
        return nil
    }
    
    public func evaluate(for operation: Operacja, completion: (OperacjaConditionResult) -> Void) {
        condition.evaluate(for: operation, completion: completion)
    }
}
