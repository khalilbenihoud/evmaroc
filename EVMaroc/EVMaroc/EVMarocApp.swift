//
//  EVMarocApp.swift
//  EVMaroc
//
//  Created by Khalil Benihoud on 1/21/26.
//

import SwiftUI

@main
struct EVMarocApp: App {
    // Services partagés dans toute l'app
    @StateObject private var stationService = StationService()
    @StateObject private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            MapView()
                .environmentObject(stationService)
                .environmentObject(locationService)
        }
    }
}
