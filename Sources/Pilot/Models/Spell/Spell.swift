//
//  Spell.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 9/12/25.
//

import Foundation

public struct EmptyPayload: Codable {}

public struct Spell<Payload: Codable>: AnySpell {
    public typealias PayloadType = Payload
    
    public let id: UUID
    public let name: String
    public let description: String
    public let textPausedState: String
    public let textPlayingState: String
    public let sfSymbolPausedState: String?
    public let sfSymbolPlayingState: String
    public var payload: Payload?

    private let play: (Payload) -> Void
    private let pause: ((Payload) -> Void)?
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        textPausedState: String = "Play",
        textPlayingState: String = "Is playing",
        sfSymbolPausedState: String? = nil,
        sfSymbolPlayingState: String = "play",
        play: @escaping (Payload) -> Void,
        pause: ((Payload) -> Void)? = nil,
        payload: Payload? = nil
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
        self.payload = payload
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
    
    // MARK: - Execution
    public func executePlay() {
        if let payload {
            play(payload)
        } else if let emptyPayload = EmptyPayload() as? Payload {
            play(emptyPayload)
        } else {
            logger.error("Spell: Something went terribly wrong. No payload was provided but the payload cannot be casted to EmptyPayload. Check eventual namespace overlap or contact the package maintainer at contact@stobo.app")
        }
    }
    
    public func executePause() {
        guard let pause else { return }
        if let payload {
            pause(payload)
        } else if let emptyPayload = EmptyPayload() as? Payload {
            pause(emptyPayload)
        } else {
            logger.error("Spell: Something went terribly wrong. No payload was provided but the payload cannot be casted to EmptyPayload. Check eventual namespace overlap or contact the package maintainer at contact@stobo.app")
        }
    }
}

// MARK: - Void-style convenience initializer
public extension Spell where Payload == EmptyPayload {
    init(
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
        self.init(
            id: id,
            name: name,
            description: description,
            textPausedState: textPausedState,
            textPlayingState: textPlayingState,
            sfSymbolPausedState: sfSymbolPausedState,
            sfSymbolPlayingState: sfSymbolPlayingState,
            play: { (_: EmptyPayload) in play() },
            pause: pause.map { p in { (_: EmptyPayload) in p() } },
            payload: nil
        )
    }
}

