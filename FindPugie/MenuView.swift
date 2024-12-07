//
//  MenuView.swift
//  FindPugie
//
//  Created by Logan March on 12/6/24.
//

import SwiftUI

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
                        MenuButton(title: "Easy")
                    }
                    NavigationLink(destination: GameView(difficulty: .medium)) {
                        MenuButton(title: "Medium")
                    }
                    NavigationLink(destination: GameView(difficulty: .hard)) {
                        MenuButton(title: "Hard")
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

    var body: some View {
        Text(title)
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

#Preview {
    MenuView()
}
