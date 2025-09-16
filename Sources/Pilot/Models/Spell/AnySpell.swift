//
//  AnySpell.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 9/12/25.
//

import Foundation

/// Generic spell protocol with type-safe payload
public protocol AnySpell: Identifiable {
    associatedtype PayloadType: Codable
    
    var id: UUID { get }
    var descriptor: SpellDescriptor { get }
    var name: String { get }
    var description: String { get }
    var textPausedState: String { get }
    var textPlayingState: String { get }
    var sfSymbolPausedState: String? { get }
    var sfSymbolPlayingState: String { get }
    var payload: PayloadType? { get }
    
    func executePlay()
    func executePause()
}
