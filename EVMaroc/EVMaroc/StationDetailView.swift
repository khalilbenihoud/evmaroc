//
//  StationDetailView.swift
//  EVMaroc
//
//  Created by Khalil Benihoud on 1/21/26.
//

import SwiftUI
import MapKit

struct StationDetailView: View {
    let station: Station
    @EnvironmentObject var locationService: LocationService

    @State private var showReportOptions = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image Placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
                    .cornerRadius(12)
                
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(station.name)
                            .font(.title2.bold())
                        if station.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text("\(station.address), \(station.city)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let location = locationService.currentLocation {
                        Text(station.formattedDistance(from: location))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Connecteurs
                Text("Connecteurs")
                    .font(.headline)

                VStack(spacing: 12) {
                    ForEach(station.connectors) { connector in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(connector.type.displayName)
                                    .font(.headline)
                                Text(connector.currentType.displayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(connector.powerDisplay)
                                .font(.headline)
                                .foregroundColor(connector.type.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(connector.type.color.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }

                Divider()

                // Infos supplémentaires
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(icon: "network", title: "Opérateur", value: station.operator)
                    if let access = station.accessInfo {
                        InfoRow(icon: "clock", title: "Accès", value: access)
                    }
                    if let price = station.priceInfo {
                        InfoRow(icon: "creditcard", title: "Tarif", value: price)
                    }
                }

                Spacer(minLength: 30)

                // Actions
                Button {
                    openInMaps()
                } label: {
                    Label("Y aller", systemImage: "paperplane.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    showReportOptions = true
                } label: {
                    Label("Signaler un problème", systemImage: "exclamationmark.triangle")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .confirmationDialog("Signaler", isPresented: $showReportOptions, titleVisibility: .visible) {
                    Button("Information incorrecte") {
                        // Submit logic placeholder
                    }
                    Button("Borne hors service") {
                        // Submit logic placeholder
                    }
                    Button("Autre problème") {
                        // Submit logic placeholder
                    }
                    Button("Annuler", role: .cancel) { }
                } message: {
                    Text("Quel est le problème avec cette station ?")
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: station.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = station.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.secondary)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        StationDetailView(station: Station.mock)
            .environmentObject(LocationService())
    }
}
