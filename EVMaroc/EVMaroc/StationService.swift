//
//  StationService.swift
//  EVMaroc
//
//  Gère le chargement et le filtrage des stations
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

class StationService: ObservableObject {
    // Données publiées (l'UI se met à jour automatiquement)
    @Published var stations: [Station] = []
    @Published var isLoading = false

    // Filtres actifs
    @Published var selectedConnectorTypes: Set<ConnectorType> = []
    @Published var minimumPowerKw: Int? = nil
    
    // Recherche
    @Published var searchText: String = ""

    init() {
        loadMockData()
    }

    // MARK: - Chargement des données

    func loadMockData() {
        isLoading = true
        // Simule un délai réseau
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.stations = Station.mockStations
            self?.isLoading = false
        }
    }
    
    func refresh() async {
        await MainActor.run { isLoading = true }
        try? await Task.sleep(nanoseconds: 300_000_000)
        await MainActor.run {
            stations = Station.mockStations
            isLoading = false
        }
    }

    // MARK: - Filtrage

    /// Stations filtrées selon tous les critères (Types, Puissance, Recherche)
    var filteredStations: [Station] {
        stations.filter { station in
            // 1. Filtre par type de connecteur
            if !selectedConnectorTypes.isEmpty {
                let stationTypes = Set(station.connectors.map(\.type))
                if selectedConnectorTypes.isDisjoint(with: stationTypes) {
                    return false
                }
            }

            // 2. Filtre par puissance minimum
            if let minPower = minimumPowerKw {
                if station.maxPowerKw < minPower {
                    return false
                }
            }
            
            // 3. Filtre par recherche
            if !searchText.isEmpty {
                let q = searchText.lowercased()
                let matches = station.name.lowercased().contains(q) ||
                              station.city.lowercased().contains(q) ||
                              station.address.lowercased().contains(q) ||
                              station.operator.lowercased().contains(q)
                if !matches {
                    return false
                }
            }

            return true
        }
    }

    /// Nombre de filtres actifs (pour le badge)
    var activeFilterCount: Int {
        var count = 0
        if !selectedConnectorTypes.isEmpty { count += 1 }
        if minimumPowerKw != nil { count += 1 }
        return count
    }

    /// Réinitialise tous les filtres
    func resetFilters() {
        selectedConnectorTypes = []
        minimumPowerKw = nil
        // On ne reset pas forcément la recherche ici, sauf si demandé explicitement
    }

    // MARK: - Tri par distance

    func stationsSortedByDistance(from location: CLLocation) -> [Station] {
        filteredStations.sorted {
            $0.distance(from: location) < $1.distance(from: location)
        }
    }
}
