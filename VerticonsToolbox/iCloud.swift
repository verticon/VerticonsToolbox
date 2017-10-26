//
//  iCloud.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 10/26/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

class iCloud : NSObject {

    enum Status {
        case exportSuceeded(URL) // URL is iCloud location of exported file.
        case importSuceeded(URL, String) // URL is iCloud location of imported file. String is its contents.
        case error(String, Error?)
        case cancelled
    }

    typealias Callback = (Status) -> Void

    private var documentPickerStatus: Status!

    func importFile(ofType: String, documentPickerPresenter: UIViewController, callback: @escaping Callback) {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.\(ofType)"], in: .import)
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = .formSheet;

        documentPickerPresenter.present(documentPicker, animated: true) {
            callback(self.documentPickerStatus)
        }
    }
    
    func exportFile(contents: String, name: String, documentPickerPresenter: UIViewController, callback: @escaping Callback) {
        
        let tempFileUrl = URL(fileURLWithPath: name, relativeTo: FileManager.default.temporaryDirectory)
        do {
            try contents.write(to: tempFileUrl, atomically: true, encoding: .utf8)
            
            let documentPicker = UIDocumentPickerViewController(url: tempFileUrl, in: .exportToService)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            
            documentPickerPresenter.present(documentPicker, animated: true) {
                callback(self.documentPickerStatus)

                do {
                    try FileManager.default.removeItem(at: tempFileUrl)
                }
                catch {
                    print("Cannot remove temp file \(tempFileUrl): \(error)")
                }
            }
        }
        catch {
            callback(.error("Cannot write temp file \(tempFileUrl)", error))
        }
    }
}

extension iCloud : UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        switch controller.documentPickerMode {
        case .import:
            do {
                let contents = try String(contentsOf: urls[0])
                documentPickerStatus = .importSuceeded(urls[0], contents)
            }
            catch {
                documentPickerStatus = .error("Cannot read \(urls[0])", error)
            }
            
        case .exportToService:
            documentPickerStatus = .exportSuceeded(urls[0])

        default:
            documentPickerStatus = .error("Unexpected document picker mode; raw value = \(controller.documentPickerMode.rawValue)", nil)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        documentPickerStatus = .cancelled
    }
}
