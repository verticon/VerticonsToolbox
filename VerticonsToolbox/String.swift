//
//  String.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 5/14/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

public extension String.Encoding {

    public struct Wrapper : CustomStringConvertible{
        public let encoding: String.Encoding
        public var name: String
        public var description: String { return name }
    }

    /// All possible values of String.Encoding
    public static let all: [Wrapper] = {
        var wrappers = [Wrapper]()
        
        wrappers.append(Wrapper(encoding: String.Encoding.ascii, name: "ascii"))
        wrappers.append(Wrapper(encoding: String.Encoding.iso2022JP, name: "iso2022JP"))
        wrappers.append(Wrapper(encoding: String.Encoding.isoLatin1, name: "isoLatin1"))
        wrappers.append(Wrapper(encoding: String.Encoding.isoLatin2, name: "isoLatin2"))
        wrappers.append(Wrapper(encoding: String.Encoding.japaneseEUC, name: "japaneseEUC"))
        wrappers.append(Wrapper(encoding: String.Encoding.macOSRoman, name: "macOSRoman"))
        wrappers.append(Wrapper(encoding: String.Encoding.nextstep, name: "nextstep"))
        wrappers.append(Wrapper(encoding: String.Encoding.nonLossyASCII, name: "nonLossyASCII"))
        wrappers.append(Wrapper(encoding: String.Encoding.shiftJIS, name: "shiftJIS"))
        wrappers.append(Wrapper(encoding: String.Encoding.symbol, name: "symbol"))
        wrappers.append(Wrapper(encoding: String.Encoding.unicode, name: "unicode"))
        wrappers.append(Wrapper(encoding: String.Encoding.utf16, name: "utf16"))
        wrappers.append(Wrapper(encoding: String.Encoding.utf16BigEndian, name: "utf16BigEndian"))
        wrappers.append(Wrapper(encoding: String.Encoding.utf16LittleEndian, name: "utf16LittleEndian"))
        wrappers.append(Wrapper(encoding: String.Encoding.utf32, name: "utf32"))
        wrappers.append(Wrapper(encoding: String.Encoding.utf32BigEndian, name: "utf32BigEndian"))
        wrappers.append(Wrapper(encoding: String.Encoding.utf32LittleEndian, name: "utf32LittleEndian"))
        wrappers.append(Wrapper(encoding: String.Encoding.utf8, name: "utf8"))
        wrappers.append(Wrapper(encoding: String.Encoding.windowsCP1250, name: "windowsCP1250"))
        wrappers.append(Wrapper(encoding: String.Encoding.windowsCP1251, name: "windowsCP1251"))
        wrappers.append(Wrapper(encoding: String.Encoding.windowsCP1252, name: "windowsCP1252"))
        wrappers.append(Wrapper(encoding: String.Encoding.windowsCP1253, name: "windowsCP1253"))
        wrappers.append(Wrapper(encoding: String.Encoding.windowsCP1254, name: "windowsCP1254"))
        
        return wrappers
    }()

    /// A textual name for this encoding
    var name: String? {
        for wrapper in String.Encoding.all {
            if self == wrapper.encoding {
                return wrapper.name
            }
        }
        return nil
    }

    /// The index of this encoding in the String.Encoding.all array
    var index: Int? {
        for index in 0 ..< String.Encoding.all.count {
            if self == String.Encoding.all[index].encoding {
                return index
            }
        }
        return nil
    }
}
