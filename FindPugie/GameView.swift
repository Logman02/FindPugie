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
    @State private var cloudAnimationIndex: Int = 0
    @State private var cloudAnimationForward: Bool = true

    @Environment(\.presentationMode) var presentationMode

    let iconSize: CGFloat = 50
    let cloudIconSize: CGFloat = 70 // Make cloud images bigger
    let screenBounds = UIScreen.main.bounds
    let cloudFrames = ["cloud_sprite_1", "cloud_sprite_2", "cloud_sprite_3", "cloud_sprite_4"]
    
    var body: some View {
        ZStack {
            // Background color
            Color(white: 0.1)
                .edgesIgnoringSafeArea(.all)

            // Game icons
            ForEach(icons) { icon in
                if icon.iconName == "PugieIconGame" {
                    // Correct icon
                    Image(icon.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .position(icon.position)
                } else if icon.iconName == "cloud" {
                    // Animated cloud icon with random rotation
                    Image(cloudFrames[cloudAnimationIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: cloudIconSize, height: cloudIconSize)
                        .rotationEffect(icon.rotation)
                        .position(icon.position)
                } else {
                    // Incorrect icons
                    Image(systemName: icon.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(.white)
                        .position(icon.position)
                }
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
        .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { _ in
            animateCloud()
        }
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
            case .hard: return (100, 2.5)
            }
        }()

        correctIconID = Int.random(in: 0..<iconCount)
        icons = (0..<iconCount).map { id in
            let randomRotation = [0, 90, 180].randomElement() ?? 0
            return GameIcon(
                id: id,
                iconName: id == correctIconID ? "PugieIconGame" : (Bool.random() ? "cloud" : "circle"),
                position: CGPoint(
                    x: CGFloat.random(in: iconSize..<(screenBounds.width - iconSize)),
                    y: CGFloat.random(in: iconSize..<(screenBounds.height - iconSize))
                ),
                velocity: CGSize(
                    width: CGFloat.random(in: -2...2) * speedMultiplier,
                    height: CGFloat.random(in: -2...2) * speedMultiplier
                ),
                rotation: Angle(degrees: Double(randomRotation)) // Random rotation applied
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

    // Animate cloud frames
    func animateCloud() {
        guard timerActive else { return }

        if cloudAnimationForward {
            cloudAnimationIndex += 1
            if cloudAnimationIndex == cloudFrames.count - 1 {
                cloudAnimationForward = false
            }
        } else {
            cloudAnimationIndex -= 1
            if cloudAnimationIndex == 0 {
                cloudAnimationForward = true
            }
        }
    }

    // Check the tap location
    func checkTap(at location: CGPoint) {
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
    var rotation: Angle // Add rotation property for random tilt
}

#Preview {
    GameView(difficulty: .easy)
}
