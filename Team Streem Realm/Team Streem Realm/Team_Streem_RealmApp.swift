//
//  Team_Streem_RealmApp.swift
//  Team Streem Realm
//
//  Created by Matthew Streem on 2/2/26.
//

import SwiftUI

@main
struct Team_Streem_RealmApp: App {
    // Device-based mode: iPad = Kids, iPhone = Dad
    private var deviceBasedMode: AppMode {
        UIDevice.current.userInterfaceIdiom == .pad ? .kids : .dad
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch deviceBasedMode {
                case .kids:
                    KidsDashboardView()
                case .dad:
                    DadDashboardView()
                }
            }
        }
    }
}

// MARK: - App Mode
enum AppMode: String {
    case kids
    case dad
}
