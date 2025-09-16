//
//  SpellBook.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 9/12/25.
//

import Foundation

public final class SpellBook {
    public static let shared = SpellBook()
    private init() {}
    
    private(set) var spells: [UUID: any AnySpell] = [:]
    
    public func register(_ spells: [any AnySpell]) {
        self.spells = [:]
        for spell in spells {
            self.spells[spell.id] = spell
        }
    }
    
    public var descriptors: [SpellDescriptor] {
        spells.values.map { $0.descriptor }
    }
    
    public func read(spellId: UUID) -> (any AnySpell)? {
        return spells[spellId]
    }
    
    func cast(spellId: UUID, type: SpellType) {
        guard let spell = read(spellId: spellId) else { return }
        switch type {
        case .play:
            spell.executePlay()
        case .pause:
            spell.executePause()
        }
        
    }
}
