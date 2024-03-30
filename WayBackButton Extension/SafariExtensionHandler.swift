//
//  SafariExtensionHandler.swift
//  WayBackButton Extension
//
//  Created by John Wells on 3/29/24.
//

import SafariServices
import os.log

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        let profile: UUID?
        if #available(iOS 17.0, macOS 14.0, *) {
            profile = request?.userInfo?[SFExtensionProfileKey] as? UUID
        } else {
            profile = request?.userInfo?["profile"] as? UUID
        }

        os_log(.default, "The extension received a request for profile: %@", profile?.uuidString ?? "none")
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler { properties in
            os_log(.default, "The extension received a message (%@) from a script injected into (%@) with userInfo (%@)", messageName, String(describing: properties?.url), userInfo ?? [:])
        }
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        window.getActiveTab { [weak self] activeTab in
            activeTab?.getActivePage(completionHandler: { page in
                page?.getPropertiesWithCompletionHandler({ properties in
                    guard let url = properties?.url else { return }
                    
                    self?.fetchLatestSnapshotURL(for: url, tab: activeTab)
                })
            })
        }
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        validationHandler(true, "")
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    func fetchLatestSnapshotURL(for url: URL, tab: SFSafariTab?) {
        let encodedURLString = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var queryURLComponents = URLComponents(string: "https://archive.org/wayback/available")
        queryURLComponents?.queryItems = [URLQueryItem(name: "url", value: encodedURLString)]
        
        guard let queryURL = queryURLComponents?.url else {
            os_log("URL components failed")
            return
        }
        let queryTask = URLSession.shared.dataTask(with: URLRequest(url: queryURL)) { data, response, error in
            guard let data else {
                os_log("No data")
                
                if let error {
                    if #available(macOSApplicationExtension 11.0, *) {
                        os_log("Error: \(error.localizedDescription)")
                    } else {
                        // Fallback on earlier versions
                    }
                }
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let queryResponse = try decoder.decode(QueryResponse.self, from: data)
                guard let currentSnapshot = queryResponse.archivedSnapshots?.closest,
                      let snapshotURL = currentSnapshot.url else { return }
                
                tab?.navigate(to: snapshotURL)
                
                tab?.getContainingWindow(completionHandler: { window in
                    window?.getToolbarItem(completionHandler: { toolbarItem in
                        toolbarItem?.showPopover()
                    })
                })
                
            } catch {
                if #available(macOSApplicationExtension 11.0, *) {
                    os_log("Decode error: \(error)")
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        queryTask.resume()
    }

}
