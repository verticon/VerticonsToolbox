//
//  HexadecimalKeypad
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 3/10/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import UIKit
import AudioToolbox

public enum HexadecimalKey : Int {
    case zero
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case A
    case B
    case C
    case D
    case E
    case F
    case del
    case done
    
    public func toString() -> String {
        switch self {
        case .del:
            return "del"
        case .done:
            return "done"
        default:
            return String(format:"%X", rawValue)
        }
    }
}

public protocol HexadecimalKeypadDelegate : class {
    func newKey(_: HexadecimalKey)
}

public class HexadecimalKeypad: UIView {
    

    @IBOutlet private var view: UIView!

    public weak var delegate: HexadecimalKeypadDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addNibView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addNibView()
    }

    @IBAction func keyTapped(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        self.delegate?.newKey(HexadecimalKey(rawValue: sender.tag)!)
    }

    private func addNibView() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: String(describing: type(of: self)), bundle: bundle).instantiate(withOwner: self, options: nil)
        
        addSubview(view) // Add the nib's view as a sub-view
        view.frame = bounds // Have the sub-view fill this view
    }

    public static func setup(forTextField: UITextField, withDelegate: HexadecimalKeypadDelegate) {
        let inputView = HexadecimalKeypad(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        forTextField.inputView = inputView
        inputView.delegate = withDelegate
    }
}
