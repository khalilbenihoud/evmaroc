//
//  Connector.swift
//  EVMaroc
//
//  Représente un connecteur (prise) sur une station de recharge
//

import Foundation

struct Connector: Codable, Identifiable, Hashable {
    let id: UUID
    let stationId: UUID
    let type: ConnectorType       // Type 2, CCS, etc.
    let powerKw: Int              // Puissance en kW
    let currentType: CurrentType  // AC ou DC
    let quantity: Int             // Nombre de prises de ce type

    // Pour décoder depuis JSON (Supabase)
    enum CodingKeys: String, CodingKey {
        case id
        case stationId = "station_id"
        case type
        case powerKw = "power_kw"
        case currentType = "current_type"
        case quantity
    }

    /// Affichage de la puissance : "22 kW"
    var powerDisplay: String {
        "\(powerKw) kW"
    }
}

// MARK: - Données de test
extension Connector {
    static let mockType2 = Connector(
        id: UUID(),
        stationId: UUID(),
        type: .type2,
        powerKw: 22,
        currentType: .ac,
        quantity: 2
    )

    static let mockCCS = Connector(
        id: UUID(),
        stationId: UUID(),
        type: .ccs,
        powerKw: 50,
        currentType: .dc,
        quantity: 1
    )

    static let mockCHAdeMO = Connector(
        id: UUID(),
        stationId: UUID(),
        type: .chademo,
        powerKw: 50,
        currentType: .dc,
        quantity: 1
    )
}
