//
//  QueryResponse.swift
//  WayBackButton Extension
//
//  Created by John Wells on 3/29/24.
//

import Foundation

struct QueryResponse: Codable {
    let archivedSnapshots: Snapshots?
    
    struct Snapshots: Codable {
        let closest: Snapshot?
        
        struct Snapshot: Codable {
            let status: String?
            let available: Bool?
            let url: URL?
            let timestamp: String?
        }
    }
}
