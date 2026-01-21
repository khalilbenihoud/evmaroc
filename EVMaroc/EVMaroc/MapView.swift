//
//  MapView.swift
//  EVMaroc
//
//  Carte interactive avec les stations de recharge
//  Mise à jour avec Bottom Sheet persistante
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var stationService: StationService
    @EnvironmentObject var locationService: LocationService

    @State private var selectedStation: Station?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 33.5731, longitude: -7.5898), // Casablanca
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )
    
    // UI States
    @State private var isSheetPresented = true // Persistent sheet
    
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedStation) {
            // Position de l'utilisateur
            UserAnnotation()
            
            // Pins des stations
            // Note: StationListView filters logic updates stationService.filteredStations eventually if we share state?
            // Actually StationListView has its own search logic right now.
            // Ideally StationListView should update a shared search text in StationService so pins update too.
            // For now, let's assume StationListView manages the search and we see all pins or we refactor StationService to hold search text.
            ForEach(stationService.filteredStations) { station in
                Annotation(station.name, coordinate: station.coordinate) {
                    StationPin(station: station, isSelected: selectedStation?.id == station.id)
                }
                .tag(station)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
        .sheet(item: $selectedStation) { station in
            StationDetailSheet(station: station)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isSheetPresented) {
            StationListView()
                .presentationDetents([.fraction(0.15), .medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationBackground(Color(.systemBackground))
                .interactiveDismissDisabled()
        }
        .onAppear {
            locationService.requestPermission()
            
            // Hack to force sheet to stay visible if user tries to dismiss (interactiveDismissDisabled should handle it)
            isSheetPresented = true
        }
    }
}

// MARK: - Pin de station
struct StationPin: View {
    let station: Station
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(station.isVerified ? Color.green : Color.gray)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(radius: 3)

                Image(systemName: "bolt.fill")
                    .font(.system(size: isSelected ? 18 : 14, weight: .bold))
                    .foregroundColor(.white)
            }

            // Petite flèche vers le bas
            Image(systemName: "triangle.fill")
                .font(.system(size: 10))
                .foregroundColor(station.isVerified ? Color.green : Color.gray)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Sheet de détail (Quick View on Tap)
struct StationDetailSheet: View {
    let station: Station
    @EnvironmentObject var locationService: LocationService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text(station.name)
                        .font(.title2.bold())
                    if station.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    }
                    Spacer()
                }

                // Ville + distance
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.secondary)
                    Text(station.city)
                    if let location = locationService.currentLocation {
                        Text("•")
                        Text(station.formattedDistance(from: location))
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Divider()

                // Connecteurs
                Text("Connecteurs")
                    .font(.headline)

                HStack(spacing: 10) {
                    ForEach(station.connectors) { connector in
                        VStack(spacing: 4) {
                            Text(connector.type.displayName)
                                .font(.caption.bold())
                            Text(connector.powerDisplay)
                                .font(.caption2)
                            Text(connector.currentType.displayName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(10)
                        .background(connector.type.color.opacity(0.1))
                        .foregroundColor(connector.type.color)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                Divider()

                Spacer()
                
                Button {
                    // Navigate to full details or Maps
                } label: {
                    Label("Détails complets", systemImage: "info.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

#Preview {
    MapView()
        .environmentObject(StationService())
        .environmentObject(LocationService())
}
