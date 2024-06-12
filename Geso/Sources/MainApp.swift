//
//  MainApp.swift
//  Geso
//
//  Created by Yoshimasa Niwa on 5/23/24.
//

import SwiftUI

@main
struct MainApp: App {
    @NSApplicationDelegateAdaptor
    private var service: Service

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .environment(service)
    }
}
