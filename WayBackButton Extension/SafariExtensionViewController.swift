//
//  SafariExtensionViewController.swift
//  WayBackButton Extension
//
//  Created by John Wells on 3/29/24.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
