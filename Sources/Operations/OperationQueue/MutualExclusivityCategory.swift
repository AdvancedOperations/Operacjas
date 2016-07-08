//
//  MutualExclusivityCategory.swift
//  Operations
//
//  Created by Oleg Dreyman on 08.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public protocol MutualExclusivityCategory {
    
    var identifier: String { get }
    
}

extension MutualExclusivityCategory where Self: RawRepresentable, Self.RawValue == String {
    
    public var identifier: String {
        return rawValue
    }
    
}
