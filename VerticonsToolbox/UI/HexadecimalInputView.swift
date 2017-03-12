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
    
    public weak var delegate: HexadecimalInputViewDelegate?
    
    @IBAction func keyTapped(_ sender: UIButton) {
        self.delegate?.newInput(character: sender.titleLabel!.text!)
    }

    public static func setup(forTextField: UITextField, withDelegate: HexadecimalInputViewDelegate) {
        let inputView = HexadecimalInputView.fromNib()
        forTextField.inputView = inputView
        inputView.delegate = withDelegate
    }
}
