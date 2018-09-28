//
//  ICloud
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 10/26/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

public class ICloud : NSObject {

    public enum Status {
        case success(URL, String?) // URL is iCloud location of imported/exported file. If an import then String is the contents.
        case error(String, Error?) // String is a description of the error.
        case cancelled
    }

    public typealias Callback = (Status) -> Void

    private var callback: Callback!
    private var tempFileUrl: URL!

    public func importFile(ofType: String, documentPickerPresenter: UIViewController, callback: @escaping Callback) {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.\(ofType)"], in: .import)
        present(picker: picker, presenter: documentPickerPresenter, callback: callback)
    }
    
    public func exportFile(contents: String, name: String, documentPickerPresenter: UIViewController, callback: @escaping Callback) {
        
        tempFileUrl = URL(fileURLWithPath: name, relativeTo: FileManager.default.temporaryDirectory)
        do { try contents.write(to: tempFileUrl, atomically: true, encoding: .utf8) }
        catch { callback(.error("Cannot write temp file \(String(describing: tempFileUrl))", error)) }

        let picker = UIDocumentPickerViewController(url: tempFileUrl, in: .exportToService)
        present(picker: picker, presenter: documentPickerPresenter, callback: callback)
    }

    private func present(picker: UIDocumentPickerViewController, presenter: UIViewController, callback: @escaping Callback) {
        self.callback = callback
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        presenter.present(picker, animated: true, completion: nil)
    }
}

extension ICloud : UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        switch controller.documentPickerMode {
        case .import:
            do {
                let contents = try String(contentsOf: urls[0])
                callback(.success(urls[0], contents))
            }
            catch {
                callback(.error("Cannot read \(urls[0])", error))
            }
            
        case .exportToService:
            callback(.success(urls[0], nil))

            do { try FileManager.default.removeItem(at: tempFileUrl) }
            catch { print("Cannot remove temp file \(String(describing: tempFileUrl)): \(error)") }

        default:
            callback(.error("Unexpected document picker mode; raw value = \(controller.documentPickerMode.rawValue)", nil))
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        callback(.cancelled)
    }
}
