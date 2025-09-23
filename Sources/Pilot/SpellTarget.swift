//
//  SpellTarget.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 8/29/25.
//

import SwiftUI

@MainActor
@Observable
public class SpellTarget {
    public static let shared = SpellTarget()
    private let connectionManager = ConnectionManager()
    public let deviceId: String = ConnectionManager.deviceId
    public var isConnected: Bool = false
    private init() {}


    public func startHosting(_ appName: String) {
        logger.debug("Pilot: Starting hosting for \(appName)")
        connectionManager.onMessageReceived = { [weak self] message in
            self?.handleMessage(message)
        }
        connectionManager.onConnectionReady = { [weak self] in
            self?.isConnected = true
        }
        connectionManager.onConnectionFailed = { [weak self] error in
            self?.isConnected = false
        }
        connectionManager.onConnectionLost = { [weak self] in
            self?.isConnected = false
        }
        connectionManager.onConnectionError = { [weak self] error in
            self?.isConnected = false
        }

        connectionManager.startHosting(appName: appName)
    }

    public func stopHosting() {
        logger.debug("Pilot: stopping hosting")
        connectionManager.stopAll()
    }

    public func disconnect() {
        connectionManager.send(
            .disconnect,
            onSuccess: { 
                self.connectionManager.disconnect() 
                self.isConnected = false
            },
            onFail: { 
                self.connectionManager.disconnect() 
                self.isConnected = false
            }
        )
    }

    public func register(spells: [any AnySpell]) {
        SpellBook.shared.register(spells)
        shareSpellBook()
    }

    public func invoke(spellId: UUID, type: SpellType) {
        guard let spell = SpellBook.shared.read(spellId: spellId) else {
            logger.warning("SpellTarget: Trying to cast a spell that is not registered. Verify your spellId or register your spells first")
            return
        }
        connectionManager.send(.spell(spell.descriptor, type))
    }

    private func shareSpellBook() {
        self.connectionManager.send(.spellBook(SpellBook.shared.descriptors))
    }

    private func handleMessage(_ message: Message) {
        Task {
            switch message {
            case .disconnect:
                connectionManager.disconnect()
                isConnected = false
            case .requestSpellBook:
                shareSpellBook()
            case .spellBook(_):
                logger.warning(
                    "Receiver app cannot read a SpellBook"
                )
            case .spell(let spell, let type):
                logger.info(
                    "Received spell: \(spell.name)"
                )
                SpellBook.shared.cast(spellId: spell.id, type: type)
            }
        }
    }
}

private struct SpellTargetKey: EnvironmentKey {
    static let defaultValue = SpellTarget.shared
}

public extension EnvironmentValues {
    public var pilotTarget: SpellTarget {
        get { self[SpellTargetKey.self] }
        set { self[SpellTargetKey.self] = newValue }
    }
}

public extension View {
    /// Ensures the SpellTarget in the environment is properly observed for state changes
    public func observePilotTarget() -> some View {
        self.environment(\.pilotTarget, SpellTarget.shared)
    }
}
