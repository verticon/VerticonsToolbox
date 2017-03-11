//
//  HexadecimalInputView
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 3/10/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import UIKit

public protocol HexadecimalInputViewDelegate: class {
    func newInput(character: String)
}

public class HexadecimalInputView: UIView {
    
    public enum ErrorCode : Error {
        case CannotLoadView
    }
    
    public weak var delegate: HexadecimalInputViewDelegate?
    
    @IBAction func keyTapped(_ sender: UIButton) {
        self.delegate?.newInput(character: sender.titleLabel!.text!)
    }

    public static func setupHexadecimalInput(to: UITextField, delegate: HexadecimalInputViewDelegate) throws {
        if let inputView = Bundle(for: HexadecimalInputView.self).loadNibNamed("HexadecimalInputView", owner: nil)?[0] as? HexadecimalInputView {
            inputView.delegate = delegate
            to.inputView = inputView
        }
        else {
            throw ErrorCode.CannotLoadView
        }
    }
}
