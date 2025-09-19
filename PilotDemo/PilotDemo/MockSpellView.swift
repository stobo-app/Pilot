//
//  MockSpellView.swift
//  PilotDemo
//
//  Created by Jonathan Bereyziat on 9/19/25.
//

import SwiftUI
import Pilot

struct MockSpellView: View {
    var body: some View {
        Text("Pilot test in 1 line!")
            .tryASpell()
    }
}

#Preview(windowStyle: .automatic) {
    MockSpellView()
}
