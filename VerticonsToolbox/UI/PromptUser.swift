//
//  PromptUser.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 1/24/18.
//  Copyright © 2018 Verticon. All rights reserved.
//

import UIKit

open class PromptUser : UIViewController {
    
    @IBOutlet public weak var prompt: UILabel!
    @IBOutlet public weak var response: UITextField!

    private let text: String
    private let callback: (String?) -> ()

    public init(_ text: String, callback: @escaping (String?) -> ()) {
        self.text = text
        self.callback = callback
        super.init(nibName: "PromptUser", bundle: Bundle(for: PromptUser.self))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        prompt.text = text
    }

    @IBAction open func done(_ sender: Any) {
        dismiss(animated: false) {
            if let count = self.response.text?.count, count > 0 { self.callback(self.response.text) }
            else { self.callback(nil) }
        }
    }
}

