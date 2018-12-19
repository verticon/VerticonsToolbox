//
//  Email.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 10/9/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation
import MessageUI

public class Email : NSObject {

    // When the application executed Email().send(...) the app crashed, apparently because the email instance had
    // been deallocated before the didFinishWith delegate method was invoked. So, instead of making the app store
    // the reference to the Email instance, I went with a singleton.
    public static let sender = Email()
    
    private override init() { super.init() }

    public func send(to: [String]?, subject: String, message: String, attachments: [String : Data] = [:], presenter: UIViewController) -> Bool {
        
        guard  MFMailComposeViewController.canSendMail() else {
            alertUser(title: "Could Not Send Email", body: "Please check your e-mail configuration and try again.")
            return false
        }
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        if let recipients = to { mailComposerVC.setToRecipients(recipients) }
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(message, isHTML: false)
        for attachment in attachments { mailComposerVC.addAttachmentData(attachment.value, mimeType: "text/plain", fileName: attachment.key)}
        
        presenter.present(mailComposerVC, animated: true, completion: nil)
        
        return true
    }
}

extension Email : MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
