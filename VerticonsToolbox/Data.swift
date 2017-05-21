//
//  Data.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 5/17/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

// TODO: Rethink the forced unwrapping of the String initializers
public extension Data {
    
    public init(with: String, using: String.Encoding = .utf8) {
        self.init()
        self.append(with.data(using: using)!)
        self.append(0)
    }
    
    public init(with: [String], using: String.Encoding = .utf8) {
        self.init()
        with.forEach { self.append(Data(with: $0, using: using)) }
    }
    
    public func toString(encoding: String.Encoding = .utf8) -> String {
        return String(data: self, encoding: encoding)!
    }
    
    public func toStringArray(encoding: String.Encoding = .utf8) -> [String] {
        
        return withUnsafeBytes { (ptr: UnsafePointer<Int8>) in
            
            var strings = [String]()
            
            var start = ptr
            for offset in 0 ..< self.count {
                
                let current = ptr + offset
                
                if current != start && current.pointee == 0 {
                    // if we cannot decode the string, append a unicode replacement character
                    // feel free to handle this another way.
                    strings.append(String(cString: start, encoding: encoding) ?? "\u{FFFD}")
                    start = current + 1
                }
            }
            
            return strings
        }
    }
    
    public func toHexString(seperator: String) -> String {
        return self.map { String(format: "%02hhX", $0) }.joined(separator: seperator)
    }
}

// http://stackoverflow.com/questions/38023838/round-trip-swift-number-types-to-from-data
public extension Data {
    
    public init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    public func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    public init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }
    
    public func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
}

public enum NumericType {
    
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
    
    public var type: Any {
        switch self {
        case .int8: return Int8.self
        case .uint8: return UInt8.self
        case .int16: return Int16.self
        case .uint16: return UInt16.self
        case .int32: return Int32.self
        case .uint32: return UInt32.self
        case .int64: return Int64.self
        case .uint64: return UInt64.self
        case .float: return Float.self
        case .double: return Double.self
        }
    }
    
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
    public var index: Int? {
        for index in 0 ..< NumericType.all.count {
            if self == NumericType.all[index].type {
                return index
            }
        }
        return nil
    }
    
    public struct Wrapper : CustomStringConvertible {
        public let type: NumericType
        public var description: String { return type.name }
    }
    
    public static let all: [Wrapper] = {
        var wrappers = [Wrapper]()
        
        wrappers.append(Wrapper(type: .int8))
        wrappers.append(Wrapper(type: .uint8))
        wrappers.append(Wrapper(type: .int16))
        wrappers.append(Wrapper(type: .uint16))
        wrappers.append(Wrapper(type: .int32))
        wrappers.append(Wrapper(type: .uint32))
        wrappers.append(Wrapper(type: .int64))
        wrappers.append(Wrapper(type: .uint64))
        wrappers.append(Wrapper(type: .float))
        wrappers.append(Wrapper(type: .double))
        
        return wrappers
    }()
    
}
