//
//  LogFileViewController.swift
//
//  Created by Robert Vaessen on 1/7/16.
//  Copyright © 2016 Robert Vaessen. All rights reserved.
//

import UIKit

public class LogFileViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func viewWillAppear(_ animated: Bool) {
        _ = FileLogger.instance?.addListener(logFileListener)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
