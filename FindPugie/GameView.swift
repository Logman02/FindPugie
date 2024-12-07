//
//  GameView.swift
//  FindPugie
//
//  Created by Logan March on 12/6/24.
//

import SwiftUI

struct GameView: View {
    @State private var icons: [GameIcon] = []
    @State private var correctIconID: Int = Int.random(in: 0..<10)
    @State private var gameOver: Bool = false

    let iconSize: CGFloat = 50
    let screenBounds = UIScreen.main.bounds

    var body: some View {
        ZStack {
            ForEach(icons) { icon in
                Image(systemName: icon.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .position(icon.position)
                    .onTapGesture {
                        if icon.id == correctIconID {
                            gameOver = true
                        }
                    }
            }

            if gameOver {
                Text("You Win!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .onAppear(perform: setupGame)
    }

    func setupGame() {
        // Generate random icons and assign random positions and movement directions
        icons = (0..<10).map { id in
            GameIcon(
                id: id,
                iconName: id == correctIconID ? "star.fill" : "circle",
                position: CGPoint(
                    x: CGFloat.random(in: iconSize..<(screenBounds.width - iconSize)),
                    y: CGFloat.random(in: iconSize..<(screenBounds.height - iconSize))
                ),
                velocity: CGSize(
                    width: CGFloat.random(in: -2...2),
                    height: CGFloat.random(in: -2...2)
                )
            )
        }

        // Animate the icons
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            for i in 0..<icons.count {
                icons[i].position.x += icons[i].velocity.width
                icons[i].position.y += icons[i].velocity.height

                // Reverse direction if an icon hits a screen boundary
                if icons[i].position.x < iconSize || icons[i].position.x > screenBounds.width - iconSize {
                    icons[i].velocity.width *= -1
                }
                if icons[i].position.y < iconSize || icons[i].position.y > screenBounds.height - iconSize {
                    icons[i].velocity.height *= -1
                }
            }
        }
    }
}

struct GameIcon: Identifiable {
    let id: Int
    let iconName: String
    var position: CGPoint
    var velocity: CGSize
}

#Preview {
    GameView()
}
