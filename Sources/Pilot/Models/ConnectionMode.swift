//
//  ConnectionMode.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 8/20/25.
//

import SwiftUI

public enum ConnectionMode {
    case hosting
    case discovering
    case connected
    case none
    
    var title: LocalizedStringKey {
        return switch self {
        case .hosting:
            "Hosting"
        case .discovering:
            "Discovering"
        case .none:
            "Not connected"
        case .connected:
            "Connected"
        }
    }
}
