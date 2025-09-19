//
//  MockSpellModifier.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 9/17/25.
//

import SwiftUI

struct MockSpellModifier: ViewModifier {
    @Environment(\.pilotTarget) private var pilotTarget
    @State private var isAlertPresented = false
    private let revelioId = UUID()

    func body(content: Content) -> some View {
        content
            .alert(isPresented: $isAlertPresented) {
                Alert(
                    title: Text("🪄 Revelio!"),
                    message: Text("Wonderful! You successfully casted your first Spell. You're ready for some more serious magic. Refer to the 'Custom Spell' section of the documentation to implement your own Spell."),
                    dismissButton: .default(Text("Close")) {
                        /// Notify Stobo iPhone that the alert got closed manually from your controlled app to keep the status in sync
                        pilotTarget.invoke(spellId: revelioId, type: .pause)
                    }
                )
            }
            .onAppear {
                let revelio = Spell(
                    id: revelioId,
                    name: "Revelio",
                    description: "Control your Vision Pro",
                    textPausedState: "Cast",
                    textPlayingState: "Cancel spell",
                    sfSymbolPausedState: "wand.and.sparkles",
                    sfSymbolPlayingState: "wand.and.rays",
                    play: { isAlertPresented = true },
                    pause: { isAlertPresented = false }
                )
                pilotTarget.register(spells: [revelio])
                pilotTarget.startHosting("SpellBook")
            }
            .onDisappear {
                pilotTarget.stopHosting()
            }
    }
}

extension View {
    public func tryASpell() -> some View {
        self.modifier(MockSpellModifier())
    }
}
