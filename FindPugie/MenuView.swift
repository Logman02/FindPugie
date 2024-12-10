//
//  MenuView.swift
//  FindPugie
//
//  Created by Logan March on 12/6/24.
//

import SwiftUI
import AVFoundation

struct MenuView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Full-screen background
                Color(white: 0.1) // Very dark gray background
                    .edgesIgnoringSafeArea(.all)

                // Menu Content
                VStack(spacing: 20) {
                    Text("Find Pugie")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Difficulty buttons
                    NavigationLink(destination: GameView(difficulty: .easy)) {
                        MenuButton(title: "Easy", backgroundColor: .green)
                    }
                    NavigationLink(destination: GameView(difficulty: .medium)) {
                        MenuButton(title: "Medium", backgroundColor: .yellow)
                    }
                    NavigationLink(destination: GameView(difficulty: .hard)) {
                        MenuButton(title: "Hard", backgroundColor: .red)
                    }
                }
                .padding()
            }
        }
    }
}

// A reusable button style for the menu options
struct MenuButton: View {
    let title: String
    let backgroundColor: Color

    var body: some View {
        Text(title)
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

#Preview {
    MenuView()
}
