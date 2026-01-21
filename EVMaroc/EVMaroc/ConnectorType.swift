//
//  ConnectorType.swift
//  EVMaroc
//
//  Types de prises et de courant pour les bornes de recharge
//

import SwiftUI

// MARK: - Type de prise
enum ConnectorType: String, Codable, CaseIterable, Identifiable {
    case type2 = "Type2"
    case ccs = "CCS"
    case chademo = "CHAdeMO"
    case domestic = "Domestic"

    var id: String { rawValue }

    /// Nom affiché à l'utilisateur
    var displayName: String {
        switch self {
        case .type2: return "Type 2"
        case .ccs: return "CCS Combo"
        case .chademo: return "CHAdeMO"
        case .domestic: return "Domestique"
        }
    }

    /// Couleur associée pour l'UI
    var color: Color {
        switch self {
        case .type2: return .blue
        case .ccs: return .orange
        case .chademo: return .purple
        case .domestic: return .gray
        }
    }
}

// MARK: - Type de courant (AC ou DC)
enum CurrentType: String, Codable {
    case ac = "AC"
    case dc = "DC"

    var displayName: String { rawValue }

    var color: Color {
        switch self {
        case .ac: return .green
        case .dc: return .orange
        }
    }
}
