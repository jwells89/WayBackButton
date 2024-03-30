//
//  SafariExtensionViewController.swift
//  WayBackButton Extension
//
//  Created by John Wells on 3/29/24.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    @IBOutlet weak var errorLabel: NSTextField!
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:330, height:77)
        return shared
    }()

}
