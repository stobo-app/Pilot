//
//  Spell.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 9/12/25.
//

import Foundation

public struct Spell {
    public let id: UUID
    public let name: String
    public let description: String
    public let textPausedState: String
    public let textPlayingState: String
    public let sfSymbolPausedState: String?
    public let sfSymbolPlayingState: String

    public let play: () -> Void
    public let pause: (() -> Void)?

    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        textPausedState: String = "Play",
        textPlayingState: String = "Is playing",
        sfSymbolPausedState: String? = nil,
        sfSymbolPlayingState: String = "play",
        play: @escaping () -> Void,
        pause: (() -> Void)? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.textPausedState = textPausedState
        self.textPlayingState = textPlayingState
        self.sfSymbolPausedState = sfSymbolPausedState
        self.sfSymbolPlayingState = sfSymbolPlayingState
        self.play = play
        self.pause = pause
    }
    
    // MARK: - Descriptor
    public var descriptor: SpellDescriptor {
        SpellDescriptor(
            id: id,
            name: name,
            description: description,
            textPausedState: textPausedState,
            textPlayingState: textPlayingState,
            sfSymbolPausedState: sfSymbolPausedState,
            sfSymbolPlayingState: sfSymbolPlayingState
        )
    }
}

