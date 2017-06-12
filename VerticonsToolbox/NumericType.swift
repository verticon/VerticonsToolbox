//
//  NumericType.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 6/9/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

public enum NumericType : CustomStringConvertible {
    
    case int8
    case uint8
    case int16
    case uint16
    case int32
    case uint32
    case int64
    case uint64
    case float
    case double
    
    public static let all: [NumericType] = [.int8, .uint8, .int16, .uint16, .int32, .uint32, .int64, .uint64, .float, .double]
    
    public var description: String { return self.name }
    
    public var name: String {
        switch self {
        case .int8: return "\(Int8.self)"
        case .uint8: return "\(UInt8.self)"
        case .int16: return "\(Int16.self)"
        case .uint16: return "\(UInt16.self)"
        case .int32: return "\(Int32.self)"
        case .uint32: return "\(UInt32.self)"
        case .int64: return "\(Int64.self)"
        case .uint64: return "\(UInt64.self)"
        case .float: return "\(Float.self)"
        case .double: return "\(Double.self)"
        }
    }
    
    /// The index of this numeric type in the NumericType.all array
    public var index: Int {
        return NumericType.all.index { self == $0 }!
    }
    
    public func valueToData(value: String) -> Data? {
        
        switch self {
            
        case .int8:
            return Int8(value)?.data

        case .uint8:
            return UInt8(value)?.data
            
        case .int16:
            return Int16(value)?.data
            
        case .uint16:
            return UInt16(value)?.data
            
        case .int32:
            return Int32(value)?.data
            
        case .uint32:
            return UInt32(value)?.data
            
        case .int64:
            return Int64(value)?.data
            
        case .uint64:
            return UInt64(value)?.data
            
        case .float:
            return Float(value)?.data
            
        case .double:
            return Double(value)?.data
        }
    }
    
    public func valueFromData(data: Data, hex: Bool) -> String? {
        
        switch self {
            
        case .int8:
            guard let number = Int8(data: data) else { return nil }
            return String(format: hex ? "%02hhX" : "%hhd", number)
            
        case .uint8:
            guard let number = UInt8(data: data) else { return nil }
            return String(format: hex ? "%02hhX" : "%hhu", number)
            
        case .int16:
            guard let number = Int16(data: data) else { return nil }
            return String(format: hex ? "%04hX " : "%hd ", number)
            
        case .uint16:
            guard let number = UInt16(data: data) else { return nil }
            return String(format: hex ? "%04hX " : "%hu ", number)
            
        case .int32:
            guard let number = Int32(data: data) else { return nil }
            return String(format: hex ? "%08X " : "%d ", number)
            
        case .uint32:
            guard let number = UInt32(data: data) else { return nil }
            return String(format: hex ? "%08X " : "%u ", number)
            
        case .int64:
            guard let number = Int64(data: data) else { return nil }
            return String(format: hex ? "%016X " : "%ld ", number)
            
        case .uint64:
            guard let number = UInt64(data: data) else { return nil }
            return String(format: hex ? "%016X " : "%lu ", number)
            
        case .float:
            guard let number = Float(data: data) else { return nil }
            return String(format: "%f ", number)
            
        case .double:
            guard let number = Double(data: data) else { return nil }
            return String(format: "%f ", number)
        }
    }
}
