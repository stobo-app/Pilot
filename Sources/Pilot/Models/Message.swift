//
//  Message.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 8/20/25.
//

import Foundation

public enum Message: Codable, Equatable, CustomStringConvertible {
    case disconnect
    case requestSpellBook
    case spellBook([SpellDescriptor])
    case spell(SpellDescriptor, SpellType)

    public var description: String {
        return switch self {
        case .disconnect:
            "Disconnect"
        case .requestSpellBook:
            "Requesting the list of available spells"
        case .spellBook(let spells):
            "Shared the spell book with \(spells.count) spells"
        case .spell(let spell, let type):
            "Send \(type.rawValue.capitalized) \(spell.name)"
        }
    }
}
