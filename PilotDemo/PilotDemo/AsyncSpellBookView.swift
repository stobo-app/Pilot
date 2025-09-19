//
//  AsyncSpellBookView.swift
//  PilotDemo
//
//  Created by Jonathan Bereyziat on 9/19/25.
//

import SwiftUI
import Pilot

struct AsyncSpellBookView: View {
    @State private var hasLoadedSpells = false
    @State private var loadingProgress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            if !hasLoadedSpells {
                Text("Loading spells asynchronously...")
                ProgressView(value: loadingProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 300)
                Text("\(Int(loadingProgress * 100))%")
                    .font(.caption)
            } else {
                Text("Spells loaded! App advertised on the network")
                    .font(.headline)
            }
        }
        .startPilot(appName: "AsyncSpellBook") {
            return await loadSpellsAsync()
        }
    }
    
    private func loadSpellsAsync() async -> [any AnySpell] {
        // Simulate progressive loading over 5 seconds
        let totalDuration: Double = 5.0 // 5 seconds
        let updateInterval: Double = 0.1 // Update every 100ms
        let steps = Int(totalDuration / updateInterval)
        
        for i in 0...steps {
            let progress = Double(i) / Double(steps)

            loadingProgress = progress
            
            if i < steps {
                try? await Task.sleep(nanoseconds: UInt64(updateInterval * 1_000_000_000))
            }
        }

        hasLoadedSpells = true

        return [
            Spell(
                name: "Fireball",
                description: "A powerful fire spell",
                play: { print("🔥 Fireball casted!") }
            ),
            Spell(
                name: "Lightning Bolt",
                description: "An electric spell",
                play: { print("⚡ Lightning Bolt casted!") }
            ),
            Spell(
                name: "Heal",
                description: "A healing spell",
                play: { print("💚 Heal casted!") }
            )
        ]
    }
}
