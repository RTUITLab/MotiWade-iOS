//
//  MotiWadeApp.swift
//  MotiWade
//
//  Created by Mikhail Ivanov on 06.11.2020.
//

import SwiftUI

@main
struct MotiWadeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var deleagate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBar(hidden: true)
        }
    }
}
