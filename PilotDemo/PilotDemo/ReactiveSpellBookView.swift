//
//  ReactiveSpellBookView.swift
//  PilotDemo
//
//  Created by Jonathan Bereyziat on 9/19/25.
//

import SwiftUI
import Pilot

struct ReactiveSpellBookView: View {
    @State private var spells = [any AnySpell]()
    private var spellCount: Int {
        spells.count + 1
    }
    var body: some View {
        VStack {
            Text("Try adding some spells on the fly:")
            Button("Add a spell") {
                spells.append(
                    Spell(
                        name: "SPELL \(spellCount)",
                        description: "Dynamically added spell",
                        play: { print("SPELL \(spellCount) got casted") }
                    )
                )
            }
        }
        .startPilot(appName: "SpellBook", spells: $spells)
    }
}
