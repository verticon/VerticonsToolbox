//
//  AlertController.swift
//  Toolbox
//
//  Created by Robert Vaessen on 9/26/16.
//  Copyright © 2016 Robert Vaessen. All rights reserved.
//

import UIKit

public extension UIAlertController {
    
    func display(animated: Bool = false, completion: (() -> Void)? = nil) {
        if let topController = UIApplication.topViewController() {
            displayFrom(controller: topController, animated: animated, completion: completion)
        }
    }
    
    func displayFrom(controller: UIViewController, animated: Bool = false, completion: (() -> Void)? = nil) {
        if let navVC = controller as? UINavigationController, let visibleVC = navVC.visibleViewController {
            displayFrom(controller: visibleVC, animated: animated, completion: completion)
        }
        else if let tabVC = controller as? UITabBarController, let selectedVC = tabVC.selectedViewController {
            displayFrom(controller: selectedVC, animated: animated, completion: completion)
        }
        else {
            controller.present(self, animated: animated, completion: completion)
        }
    }
}
