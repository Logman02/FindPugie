//
//  GameView.swift
//  FindPugie
//
//  Created by Logan March on 12/6/24.
//
import SwiftUI

enum Difficulty {
    case easy, medium, hard
}

struct GameView: View {
    let difficulty: Difficulty
    @State private var icons: [GameIcon] = []
    @State private var correctIconID: Int = Int.random(in: 0..<10)
    @State private var gameOver: Bool = false
    @State private var win: Bool = false
    @State private var timerActive: Bool = true

    @Environment(\.presentationMode) var presentationMode

    let iconSize: CGFloat = 50
    let screenBounds = UIScreen.main.bounds

    var body: some View {
        ZStack {
            // Background color
            Color(white: 0.1)
                .edgesIgnoringSafeArea(.all)

            // Game icons
            ForEach(icons) { icon in
                Image(systemName: icon.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(.white)
                    .position(icon.position)
            }

            // Transparent tap detector
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
                .onTapGesture { location in
                    if !gameOver {
                        checkTap(at: location)
                    }
                }

            // Game Over screen
            if gameOver {
                VStack {
                    Text(win ? "You Win!" : "You Lose!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(win ? .yellow : .red)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)

                    HStack(spacing: 20) {
                        Button(action: retryGame) {
                            Text("Retry")
                                .font(.title2)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: returnToMenu) {
                            Text("Menu")
                                .font(.title2)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .onAppear(perform: setupGame)
    }

    // Retry the current game
    func retryGame() {
        gameOver = false
        timerActive = true
        setupGame()
    }

    // Return to the main menu
    func returnToMenu() {
        presentationMode.wrappedValue.dismiss()
    }

    // Setup the game based on difficulty
    func setupGame() {
        let (iconCount, speedMultiplier): (Int, CGFloat) = {
            switch difficulty {
            case .easy: return (20, 1.0)
            case .medium: return (50, 1.5)
            case .hard: return (70, 2.0)
            }
        }()

        correctIconID = Int.random(in: 0..<iconCount)
        icons = (0..<iconCount).map { id in
            GameIcon(
                id: id,
                iconName: id == correctIconID ? "star.fill" : "circle",
                position: CGPoint(
                    x: CGFloat.random(in: iconSize..<(screenBounds.width - iconSize)),
                    y: CGFloat.random(in: iconSize..<(screenBounds.height - iconSize))
                ),
                velocity: CGSize(
                    width: CGFloat.random(in: -2...2) * speedMultiplier,
                    height: CGFloat.random(in: -2...2) * speedMultiplier
                )
            )
        }

        // Animate the icons
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            guard timerActive else {
                timer.invalidate()
                return
            }

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

    // Check the tap location
    func checkTap(at location: CGPoint) {
        // First, check if the tap intersects with the correct icon
        if let correctIcon = icons.first(where: { $0.id == correctIconID }) {
            let correctIconFrame = CGRect(
                x: correctIcon.position.x - iconSize / 2,
                y: correctIcon.position.y - iconSize / 2,
                width: iconSize,
                height: iconSize
            )

            if correctIconFrame.contains(location) {
                win = true
                endGame()
                return
            }
        }

        // If not, check for any other incorrect icons (causing a loss)
        for icon in icons {
            let iconFrame = CGRect(
                x: icon.position.x - iconSize / 2,
                y: icon.position.y - iconSize / 2,
                width: iconSize,
                height: iconSize
            )

            if iconFrame.contains(location) {
                win = false
                endGame()
                return
            }
        }
    }

    // End the game and stop the icons
    func endGame() {
        gameOver = true
        timerActive = false
    }
}

struct GameIcon: Identifiable {
    let id: Int
    let iconName: String
    var position: CGPoint
    var velocity: CGSize
}

#Preview {
    GameView(difficulty: .easy)
}
