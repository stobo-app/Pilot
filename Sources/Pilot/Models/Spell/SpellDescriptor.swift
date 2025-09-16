//
//  SpellDescriptor.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 9/12/25.
//

import Foundation

public struct SpellDescriptor: Codable, Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let description: String
    public let textPausedState: String
    public let textPlayingState: String
    public let sfSymbolPausedState: String?
    public let sfSymbolPlayingState: String
}
