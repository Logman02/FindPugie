// Make music work
// Add sound effects
// Fix dynamic background colors so its never the same as before
// Move High score in menu up
// Add more UI (like Pugie in Menu)

import SwiftUI

enum Difficulty {
    case easy, medium, hard
}

struct GameView: View {
    @Binding var highScore: Int
    @State private var currentStreak: Int
    @State private var icons: [GameIcon] = []
    @State private var correctIconID: String = ""
    @State private var gameOver: Bool = false
    @State private var win: Bool = false
    @State private var timerActive: Bool = true
    @State private var cloudAnimationIndex: Int = 0
    @State private var cloudAnimationForward: Bool = true
    @State private var iconMovementTimer: Timer? = nil
    @State private var cloudAnimationTimer: Timer? = nil
    @State private var fadingClouds: [GameIcon] = []
    @State private var backgroundColor: Color = .levelRed
    @State private var previousBackgroundColor: Color = .clear
    @ObservedObject private var audioManager = AudioManager.shared
    
    @Environment(\.presentationMode) var presentationMode
    
    let iconSize: CGFloat = 50
    let cloudIconSize: CGFloat = 80
    let screenBounds = UIScreen.main.bounds
    let cloudFrames = ["cloud_sprite_1", "cloud_sprite_2", "cloud_sprite_3", "cloud_sprite_4"]
    
    // Difficulty state variable
    @State private var difficulty: Difficulty
    
    init(difficulty: Difficulty, highScore: Binding<Int>, currentStreak: Int) {
        self.difficulty = difficulty
        self._highScore = highScore
        self._currentStreak = State(initialValue: currentStreak)
    }

    var body: some View {
        ZStack {
//            // Background color
//            Color(white: 0.1)
//                .edgesIgnoringSafeArea(.all)
            
            // Updated background color
            backgroundColor
                .edgesIgnoringSafeArea(.all)

            // Game icons
            ForEach(icons) { icon in
                if icon.iconName == "PugieIconGame" {
                    // Correct icon (Pugie)
                    Image(icon.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .position(icon.position)
                } else if icon.iconName.starts(with: "cloud_sprite") {
                    // Animated cloud icon
                    Image(cloudFrames[cloudAnimationIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: cloudIconSize * icon.scale, height: cloudIconSize * icon.scale)
                        .rotationEffect(icon.rotation)
                        .opacity(icon.opacity)
                        .position(icon.position)
                } else if icon.iconName == "GreenStoneIconGame" || icon.iconName == "BlueStoneIconGame" || icon.iconName == "RedStoneIconGame" {
                    // Stone icons
                    Image(icon.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .position(icon.position)
                } else {
                    // Incorrect circle icons (fallback)
                    Image(systemName: icon.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(.white)
                        .position(icon.position)
                }
            }
            
            // Also update the fading clouds rendering:
            ForEach(fadingClouds) { cloud in
                Image(cloudFrames[cloudAnimationIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(width: cloudIconSize * cloud.scale, height: cloudIconSize * cloud.scale)
                    .rotationEffect(cloud.rotation)
                    .opacity(cloud.opacity)
                    .position(cloud.position)
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
                        // Show "Continue" button only if the user wins
                        if win {
                            Button(action: continueGame) {
                                Text("Continue")
                                    .font(.title2)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }

                        // "Menu" button is always visible
                        Button(action: returnToMenu) {
                            Text("Menu")
                                .font(.title2)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Text("Current Streak: \(currentStreak)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()

                    Text("High Score: \(highScore)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .onAppear(perform: setupGame)
        .onAppear(perform: startTimers)
    }

    func continueGame() {
        // Change background color (ensuring it's different from previous)
        let availableColors = [Color.levelRed, Color.levelBlue, Color.levelGreen].filter { $0 != previousBackgroundColor }
        previousBackgroundColor = backgroundColor
        backgroundColor = availableColors.randomElement() ?? .levelRed
        
        // Reset the game state
        gameOver = false // Set game over to false, allowing the new game to continue
        timerActive = true // Reactivate the timer to allow movement/animations

        // Set up a new game
        setupGame()

        // Invalidate existing timers
        iconMovementTimer?.invalidate()
        cloudAnimationTimer?.invalidate()

        // Restart the timers
        startTimers()

        // If 10, set to Hard
        if currentStreak >= 10 {
            // Example logic to increase difficulty after 5 wins, change this as needed
            if difficulty == .medium {
                difficulty = .hard
            }
        }
        
        // If 5, set to medium
        if currentStreak >= 5 {
            // Example logic to increase difficulty after 5 wins, change this as needed
            if difficulty == .easy {
                difficulty = .medium
            }
        }
    }

    func returnToMenu() {
        presentationMode.wrappedValue.dismiss()
    }

    func setupGame() {
        // Set initial background color if starting new game
        if previousBackgroundColor == .clear {
            backgroundColor = .levelRed
            previousBackgroundColor = .levelBlue // Force next color to be different
        }
        
        // iconCount is total number of icons (including Pugie, circles, and clouds)
        let (iconCount, speedMultiplier, cloudCount): (Int, CGFloat, Int) = {
            switch difficulty {
            case .easy: return (20, 1.0, 5)
            case .medium: return (40, 1.5, 10)
            case .hard: return (75, 2.5, 15)
            }
        }()

        // Generate icons with proper cloud count
        icons = (0..<iconCount).map { id in
            // First icon is always Pugie
            if id == 0 {
                return GameIcon(
                    id: UUID().uuidString,
                    iconName: "PugieIconGame",
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
            // Next cloudCount icons are clouds
            else if id <= cloudCount {
                return GameIcon(
                    id: UUID().uuidString,
                    iconName: "cloud_sprite",
                    position: CGPoint(
                        x: CGFloat.random(in: iconSize..<(screenBounds.width - iconSize)),
                        y: CGFloat.random(in: iconSize..<(screenBounds.height - iconSize))
                    ),
                    velocity: CGSize(
                        width: CGFloat.random(in: -2...2) * speedMultiplier,
                        height: CGFloat.random(in: -2...2) * speedMultiplier
                    ),
                    scale: CGFloat.random(in: 0.7...1.5),       // Random scale between 70% and 150%
                    rotation: Angle(degrees: Double.random(in: 0...360)) // Random rotation
                )
            }
            // Remaining icons are either circles or stone icons
            else {
                // Randomly choose between circle, green stone, and blue stone
                let randomChoice = Int.random(in: 0...3)
                let iconName: String
                switch randomChoice {
                case 0: iconName = "circle"
                case 1: iconName = "GreenStoneIconGame"
                case 2: iconName = "BlueStoneIconGame"
                case 3: iconName = "RedStoneIconGame"
                default: iconName = "circle"
                }
                
                return GameIcon(
                    id: UUID().uuidString,
                    iconName: iconName,
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
        }

        // Assign the correct icon ID after creating the icons
        if let correctIcon = icons.first(where: { $0.iconName == "PugieIconGame" }) {
            correctIconID = correctIcon.id
        }
    }

    func startTimers() {
        // Icon movement timer
        iconMovementTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            moveIcons()
        }
        
        // Cloud animation timer
        cloudAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            animateCloud()
        }
    }

    func moveIcons() {
        guard timerActive else { return }

        // Move regular icons
        for i in 0..<icons.count {
            // Update positions based on velocity
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
        
        // Move fading clouds too
        for i in 0..<fadingClouds.count {
            fadingClouds[i].position.x += fadingClouds[i].velocity.width
            fadingClouds[i].position.y += fadingClouds[i].velocity.height
        }
    }

    func animateCloud() {
        guard timerActive else { return }

        // Cloud animation logic with slower interval
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

    func checkTap(at location: CGPoint) {
        // Step 1: Check if the tap is on a cloud
        if let cloudIndex = icons.firstIndex(where: { $0.iconName == "cloud_sprite" && isIconTapped(icon: $0, at: location) && !$0.isFading }) {
            var tappedCloud = icons[cloudIndex]
            tappedCloud.isFading = true
            icons.remove(at: cloudIndex)
            fadingClouds.append(tappedCloud)
            
            // Start fade animation
            withAnimation(.linear(duration: 0.3)) {
                if let index = fadingClouds.firstIndex(where: { $0.id == tappedCloud.id }) {
                    fadingClouds[index].opacity = 0
                }
            }
            
            // Remove after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fadingClouds.removeAll { $0.id == tappedCloud.id }
            }
            return
        }
        
        // Step 2: Check if the tap is on the correct icon (Pugie)
        if let correctIcon = icons.first(where: { $0.id == correctIconID && isIconTapped(icon: $0, at: location) }) {
            win = true
            currentStreak += 1
            highScore = max(highScore, currentStreak)
            endGame()
            return
        }
        
        // Step 3: Check if the tap is on an incorrect icon (circle or stones)
        if let incorrectIcon = icons.first(where: {
            $0.iconName != "PugieIconGame" &&
            !($0.iconName == "cloud_sprite") &&
            isIconTapped(icon: $0, at: location)
        }) {
            win = false
            currentStreak = 0
            endGame()
            return
        }
    }

    // Helper function to check if the tap is within the bounds of an icon
    func isIconTapped(icon: GameIcon, at location: CGPoint) -> Bool {
        let size: CGFloat
        if icon.iconName == "cloud_sprite" {
            // Use scaled size for clouds
            size = (cloudIconSize * icon.scale) / 2
        } else {
            // Use standard size for other icons
            size = iconSize / 2
        }
        
        let iconFrame = CGRect(
            x: icon.position.x - size,
            y: icon.position.y - size,
            width: size * 2,
            height: size * 2
        )
        return iconFrame.contains(location)
    }

    func endGame() {
        gameOver = true
        timerActive = false
    }
}

struct GameIcon: Identifiable {
    var id: String
    var iconName: String
    var position: CGPoint
    var velocity: CGSize
    var opacity: Double = 1.0 // Add this line
    var isFading: Bool = false // Add this line
    var scale: CGFloat = 1.0      // Add for dynamic scaling
    var rotation: Angle = .zero   // Add for rotation
}

extension Color {
    static let levelRed = Color(hex: "1c0101")
    static let levelBlue = Color(hex: "01091c")
    static let levelGreen = Color(hex: "021401")
    
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
