//
//  Sounds.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 11/18/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation
import AudioToolbox

// http://iphonedevwiki.net/index.php/AudioServices

public func playErrorSound() {
    AudioServicesPlaySystemSound(1073)
}

public func playKeyPressedSound() {
    AudioServicesPlaySystemSound(1104)
}

