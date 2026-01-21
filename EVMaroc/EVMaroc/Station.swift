//
//  Station.swift
//  EVMaroc
//
//  Représente une station de recharge complète
//

import Foundation
import CoreLocation

struct Station: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let city: String
    let latitude: Double
    let longitude: Double
    let `operator`: String        // Kilowatt, TotalEnergies, etc.
    let isVerified: Bool          // Vérifié par un utilisateur ?
    let accessInfo: String?       // "24h/24", "8h-22h", etc.
    let priceInfo: String?        // "0.5 DH/min"
    let updatedAt: Date?
    var connectors: [Connector]

    enum CodingKeys: String, CodingKey {
        case id, name, address, city, latitude, longitude, `operator`, connectors
        case isVerified = "is_verified"
        case accessInfo = "access_info"
        case priceInfo = "price_info"
        case updatedAt = "updated_at"
    }

    // MARK: - Propriétés calculées

    /// Coordonnées pour MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Puissance max disponible
    var maxPowerKw: Int {
        connectors.map(\.powerKw).max() ?? 0
    }

    /// Liste des types de prises disponibles
    var connectorTypes: [ConnectorType] {
        Array(Set(connectors.map(\.type)))
    }

    /// Distance depuis une position
    func distance(from location: CLLocation) -> CLLocationDistance {
        let stationLocation = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: stationLocation)
    }

    /// Distance formatée : "1.2 km" ou "800 m"
    func formattedDistance(from location: CLLocation) -> String {
        let dist = distance(from: location)
        if dist < 1000 {
            return String(format: "%.0f m", dist)
        } else {
            return String(format: "%.1f km", dist / 1000)
        }
    }
}

// MARK: - Données de test
extension Station {
    static let mock = Station(
        id: UUID(),
        name: "Station Anfaplace Mall",
        address: "Boulevard de la Corniche",
        city: "Casablanca",
        latitude: 33.5912,
        longitude: -7.6356,
        operator: "Kilowatt",
        isVerified: true,
        accessInfo: "24h/24",
        priceInfo: "AC: 0.5 DH/min • DC: 2.5 DH/min",
        updatedAt: Date(),
        connectors: [.mockType2, .mockCCS]
    )

    static let mockStations: [Station] = [
        Station(
            id: UUID(),
            name: "Station Anfaplace Mall",
            address: "Boulevard de la Corniche",
            city: "Casablanca",
            latitude: 33.5950,
            longitude: -7.6700,
            operator: "Kilowatt",
            isVerified: true,
            accessInfo: "24h/24",
            priceInfo: "AC: 0.5 DH/min • DC: 2.5 DH/min",
            updatedAt: Date(),
            connectors: [.mockType2, .mockCCS]
        ),
        Station(
            id: UUID(),
            name: "TotalEnergies Ain Diab",
            address: "Route d'Azemmour",
            city: "Casablanca",
            latitude: 33.5850,
            longitude: -7.6900,
            operator: "TotalEnergies",
            isVerified: true,
            accessInfo: "6h - 22h",
            priceInfo: "DC: 2.5 DH/min",
            updatedAt: Date().addingTimeInterval(-86400 * 3),
            connectors: [.mockCCS, .mockCHAdeMO]
        ),
        Station(
            id: UUID(),
            name: "Morocco Mall Parking",
            address: "Boulevard de l'Océan",
            city: "Casablanca",
            latitude: 33.5730,
            longitude: -7.6650,
            operator: "FastVolt",
            isVerified: false,
            accessInfo: "Horaires du centre commercial",
            priceInfo: "Gratuit",
            updatedAt: Date().addingTimeInterval(-86400 * 7),
            connectors: [.mockType2]
        ),
        Station(
            id: UUID(),
            name: "Station Rabat Agdal",
            address: "Avenue de France",
            city: "Rabat",
            latitude: 33.9911,
            longitude: -6.8498,
            operator: "IRESEN",
            isVerified: true,
            accessInfo: "24h/24",
            priceInfo: "AC: 0.5 DH/min",
            updatedAt: Date(),
            connectors: [.mockType2]
        ),
        Station(
            id: UUID(),
            name: "Marrakech Plaza",
            address: "Avenue Mohammed VI",
            city: "Marrakech",
            latitude: 31.6408,
            longitude: -8.0028,
            operator: "Kilowatt",
            isVerified: true,
            accessInfo: "8h - 22h",
            priceInfo: "AC: 0.5 DH/min • DC: 2.5 DH/min",
            updatedAt: Date(),
            connectors: [.mockType2, .mockCCS]
        )
    ]
}
