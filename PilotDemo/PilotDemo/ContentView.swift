//
//  ContentView.swift
//  PilotDemo
//
//  Created by Jonathan Bereyziat on 9/16/25.
//

import SwiftUI
import Pilot

struct ContentView: View {
    @Environment(\.pilotTarget) private var pilotTarget
    @State private var isAlertPresented = false
    /// This will be used to identify your spells if you need to keep the status in sync between Stobo iPhone and your visionOS app
    private let revelioId = UUID()

    var body: some View {
        VStack {
            Text("Hello, Pilot!")
            Button("Discover a secret") {
                isAlertPresented = true
                /// Notify Stobo iPhone that the alert got opened manually from your controlled app to keep the status in sync
                pilotTarget.invoke(spellId: revelioId, type: .play)
            }
        }
        .padding()
        .alert(isPresented: $isAlertPresented) {
            Alert(
                title: Text("🪄 Revelio!"),
                message: Text("Wonderful! You successfully casted your first Spell. You're ready for some more serious magic. Customise the play and pause callbacks to implement your own Spell."),
                dismissButton: .default(Text("Close")) {
                    /// Notify Stobo iPhone that the alert got closed manually from your controlled app to keep the status in sync
                    pilotTarget.invoke(spellId: revelioId, type: .pause)
                }
            )
        }
        .onAppear {
            /// Create your actions with your own functions, with or without payload
            let spells: [any AnySpell] = [
                Spell(
                    /// (Optional) Identify your spell to be able to invoke it from your app and keep the PIlot app in sync
                    id: revelioId,
                    /// Describe your own spell
                    name: "Revelio",
                    description: "Control your Vision Pro",
                    /// Customize the controls from the Stobo App
                    textPausedState: "Cast",
                    textPlayingState: "Cancel spell",
                    sfSymbolPausedState: "wand.and.sparkles",
                    sfSymbolPlayingState: "wand.and.rays",
                    /// Define your own togglable action, play a video, open an immersive space, navigate to a new page etc...
                    play: { isAlertPresented = true },
                    pause: { isAlertPresented = false }
                )
            ]
            /// Register the your spells to make them available on the network
            pilotTarget.register(spells: spells)
            /// Start advertising your application on the network
            pilotTarget.startHosting("SpellBook")
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
