//
//  AvailableApp.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 8/20/25.
//

import Foundation
import Network

public struct AvailableApp: Identifiable, Equatable, Hashable {
    public let id = UUID()
    public let appName: String
    public let deviceId: String
    public let endpoint: NWEndpoint
    
    public init(appName: String, deviceId: String, endpoint: NWEndpoint) {
        self.appName = appName
        self.deviceId = deviceId
        self.endpoint = endpoint
    }
    
    public var displayName: String {
        return "\(appName) on Device \(deviceId)"
    }
}
