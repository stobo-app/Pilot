//
//  ReactiveSpellBookModifier.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 9/17/25.
//

import SwiftUI

struct ReactiveSpellBookModifier: ViewModifier {
    @Environment(\.pilotTarget) private var pilotTarget
    let appName: String
    @Binding var spells: [any AnySpell]
    
    private var spellArrayId: String {
        spells.reduce("", { $0 + $1.id.uuidString })
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                pilotTarget.register(spells: spells)
                pilotTarget.startHosting(appName)
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
    public func startPilot(appName: String, spells: Binding<[any AnySpell]>) -> some View {
        self.modifier(ReactiveSpellBookModifier(appName: appName, spells: spells))
    }
}
