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
            VStack(spacing: 20) {
                Text("Find Pugie")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                NavigationLink(destination: GameView()) {
                    Text("Start Game")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

#Preview {
    MenuView()
}
