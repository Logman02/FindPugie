import SwiftUI

struct MenuView: View {
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore") // Retrieve stored high score
    @ObservedObject private var audioManager = AudioManager.shared // Observe the audio manager

    var body: some View {
        NavigationView {
            ZStack {
                // Full-screen background
                Color(white: 0.1) // Very dark gray background
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Find Pugie")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Display high score
                    Text("High Score: \(highScore)")
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()

                    NavigationLink(
                        destination: GameView(difficulty: .easy, highScore: $highScore, currentStreak: 0)
                    ) {
                        MenuButton(title: "Start", backgroundColor: .blue)
                    }

                    // Toggle music button
                    Button(action: {
                        audioManager.toggleMusic()
                    }) {
                        Text(audioManager.isMusicOn() ? "Disable Music" : "Enable Music")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            }
        }
    }
}

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
