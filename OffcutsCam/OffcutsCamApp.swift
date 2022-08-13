//
//  OffcutsCamApp.swift
//  OffcutsCam
//
//  Created by Halle Winkler on 10.08.22.
//

import SwiftUI

@main
struct OffcutsCamApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(systemExtensionRequestManager: SystemExtensionRequestManager(logText: ""))
                .frame(minWidth: 300, minHeight: 180)
        }
    }
}
