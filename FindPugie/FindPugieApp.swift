//
//  FindPugieApp.swift
//  FindPugie
//
//  Created by Logan March on 12/6/24.
//

import SwiftUI

@main
struct FindPugieApp: App {
    init() {
            AudioManager.shared.playMusic()
        }
    var body: some Scene {
        WindowGroup {
            MenuView()
        }
    }
}

