//
//  LogFileViewController.swift
//
//  Created by Robert Vaessen on 1/7/16.
//  Copyright © 2016 Robert Vaessen. All rights reserved.
//

import UIKit

public class LogFileViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    override public func viewWillAppear(_ animated: Bool) {
        _ = FileLogger.instance?.addListener(logFileListener)
    }

    @IBAction func email(_sender: UIButton) {
        _ = Email.sender.send(to: nil, subject: "Log File", message: self.textView.text, presenter: self)
    }

    private let iCloud = ICloud()
    @IBAction func iCloud(_sender: UIButton) {
        let prompt = PromptUser("Enter a log file name") {
            if let name = $0 {
                self.iCloud.exportFile(contents: self.textView.text, name: name, documentPickerPresenter: self) { status in
                    switch status {
                    case .success(let url): break
                        
                    case .error(let description, let error):
                        alertUser(title: "Cannot Save To iCloud", body: "\(description): \(String(describing: error))")
                        
                    case .cancelled: break
                    }
                }
            }
        }
        present(prompt, animated: true)
    }

    fileprivate func logFileListener(_ newEntry: String) {
        GlobalMainQueue.async {
            self.textView.text.append(newEntry)

            //self.textView.text.appendContentsOf("View \(self.textView.bounds.size.height), Content \(self.textView.contentSize.height), Offset \(self.textView.contentOffset.y)\n")
            //let offset = CGPointMake(0, self.textView.contentSize.height - self.textView.bounds.size.height);
            //self.textView.setContentOffset(offset, animated: true)
        }
    }
}
