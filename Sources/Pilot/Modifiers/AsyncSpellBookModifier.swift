//
//  AsyncSpellBookModifier.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 9/19/25.
//

import SwiftUI

struct AsyncSpellBookModifier: ViewModifier {
    @Environment(\.pilotTarget) private var pilotTarget
    let appName: String
    @State private var spells: [any AnySpell] = []
    let getSpells: () async -> [any AnySpell]

    private var spellArrayId: String {
        spells.reduce("", { $0 + $1.id.uuidString })
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                Task {
                    spells = await getSpells()
                    pilotTarget.register(spells: spells)
                    pilotTarget.startHosting(appName)
                }
            }
            .onChange(of: spellArrayId) {
                pilotTarget.register(spells: spells)
            }
            .onDisappear {
                pilotTarget.stopHosting()
            }
    }
}

extension View {
    public func startPilot(appName: String, getSpells: @escaping () async -> [any AnySpell]) -> some View {
        self.modifier(AsyncSpellBookModifier(appName: appName, getSpells: getSpells))
    }
}
