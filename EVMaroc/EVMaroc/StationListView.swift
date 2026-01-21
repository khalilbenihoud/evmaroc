//
//  StationListView.swift
//  EVMaroc
//
//  Created by Khalil Benihoud on 1/21/26.
//

import SwiftUI

struct StationListView: View {
    @EnvironmentObject var stationService: StationService
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Search Header
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Rechercher une borne...", text: $stationService.searchText)
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(24)
                    
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 20))
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .foregroundColor(stationService.activeFilterCount > 0 ? .green : .primary)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(stationService.activeFilterCount > 0 ? Color.green : Color.clear, lineWidth: 1)
                            )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // List
                List(stationService.filteredStations) { station in
                    NavigationLink(destination: StationDetailView(station: station)) {
                        StationRow(station: station)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await stationService.refresh()
                }
            }
            .navigationTitle("Bornes")
            .navigationBarHidden(true) // Hide default nav bar to use our custom header
            .sheet(isPresented: $showFilters) {
                FilterSheet()
                    .presentationDetents([.medium])
            }
        }
    }
}

struct StationRow: View {
    let station: Station
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Nom + badge vérifié
            HStack {
                Text(station.name)
                    .font(.headline)
                if station.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            // Ville + opérateur
            Text("\(station.city) • \(station.operator)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Connecteurs
            HStack(spacing: 8) {
                ForEach(station.connectorTypes, id: \.self) { type in
                    Text(type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(type.color.opacity(0.2))
                        .foregroundColor(type.color)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Text("\(station.maxPowerKw) kW")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StationListView()
        .environmentObject(StationService())
}
