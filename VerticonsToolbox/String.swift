//
//  String.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 5/14/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

public struct StringEncoding : RawRepresentable, CustomStringConvertible {
    
    private static var encodings: [String.Encoding]  = [.ascii, .iso2022JP, .isoLatin1, .isoLatin2, .japaneseEUC, .macOSRoman,
                                                        .nextstep, .nonLossyASCII, .shiftJIS, .symbol, .unicode, .utf16, .utf16BigEndian,
                                                        .utf16LittleEndian, .utf32BigEndian, .utf32LittleEndian, .utf8, .windowsCP1250,
                                                        .windowsCP1251, .windowsCP1252, .windowsCP1253, .windowsCP1254]
    public static var all: [StringEncoding]  = {
        return encodings.map { StringEncoding(rawValue: $0)! }
        
    }()
    
    public let rawValue: String.Encoding
    
    public init?(rawValue: String.Encoding) {
        guard StringEncoding.encodings.contains(rawValue) else { return nil }
        self.rawValue = rawValue
        switch rawValue {
        case String.Encoding.ascii: name = "ascii"
        case String.Encoding.iso2022JP: name = "iso2022JP"
        case String.Encoding.isoLatin1: name = "isoLatin1"
        case String.Encoding.isoLatin2: name = "isoLatin2"
        case String.Encoding.japaneseEUC: name = "japaneseEUC"
        case String.Encoding.macOSRoman: name = "macOSRoman"
        case String.Encoding.nextstep: name = "nextstep"
        case String.Encoding.nonLossyASCII: name = "nonLossyASCII"
        case String.Encoding.shiftJIS: name = "shiftJIS"
        case String.Encoding.symbol: name = "symbol"
        case String.Encoding.unicode: name = "unicode"
        case String.Encoding.utf16: name = "utf16"
        case String.Encoding.utf16BigEndian: name = "utf16BigEndian"
        case String.Encoding.utf16LittleEndian: name = "utf16LittleEndian"
        case String.Encoding.utf32: name = "utf32"
        case String.Encoding.utf32BigEndian: name = "utf32BigEndian"
        case String.Encoding.utf32LittleEndian: name = "utf32LittleEndian"
        case String.Encoding.utf8: name = "utf8"
        case String.Encoding.windowsCP1250: name = "windowsCP1250"
        case String.Encoding.windowsCP1251: name = "windowsCP1251"
        case String.Encoding.windowsCP1252: name = "windowsCP1252"
        case String.Encoding.windowsCP1253: name = "windowsCP1253"
        case String.Encoding.windowsCP1254: name = "windowsCP1254"
        default: name = "<Unrecognized String.Encoding>"
        }
    }

    public let  name: String

    
    public var description: String { return self.name }
    
    /// The index of this StringEncoding in the StringEncoding.all array
    public var index: Int? {
        return StringEncoding.all.firstIndex { self == $0 }
    }
}
