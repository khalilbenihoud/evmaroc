//
//  FilterSheet.swift
//  EVMaroc
//
//  Created by Khalil Benihoud on 1/21/26.
//

import SwiftUI

struct FilterSheet: View {
    @EnvironmentObject var stationService: StationService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Type de prise") {
                    ForEach(ConnectorType.allCases, id: \.self) { type in
                        Button {
                            toggleconnectorType(type)
                        } label: {
                            HStack {
                                Text(type.displayName)
                                    .foregroundColor(.primary)
                                Spacer()
                                if stationService.selectedConnectorTypes.contains(type) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                
                Section("Puissance minimum") {
                    Picker("Puissance", selection: $stationService.minimumPowerKw) {
                        Text("Toutes").tag(Int?.none)
                        Text("22 kW+").tag(Int?.some(22))
                        Text("50 kW+").tag(Int?.some(50))
                        Text("100 kW+").tag(Int?.some(100))
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("Appliquer (\(stationService.filteredStations.count) stations)") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.green)
                }
            }
            .navigationTitle("Filtres")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Réinitialiser") {
                        stationService.resetFilters()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleconnectorType(_ type: ConnectorType) {
        if stationService.selectedConnectorTypes.contains(type) {
            stationService.selectedConnectorTypes.remove(type)
        } else {
            stationService.selectedConnectorTypes.insert(type)
        }
    }
}

#Preview {
    FilterSheet()
        .environmentObject(StationService())
}
