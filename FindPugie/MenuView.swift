import SwiftUI
import AVFoundation

struct MenuView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore") // Retrieve stored high score

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
                }
                .padding()
            }
        }
        .onAppear(perform: playMenuMusic)
        .onDisappear(perform: stopMusic)
    }

    // Play background music for the menu
    func playMenuMusic() {
        playAudio(named: "Irish Jig")
    }

    // Stop background music
    func stopMusic() {
        audioPlayer?.stop()
    }

    // Generic function to play a specific audio file
    func playAudio(named fileName: String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.play()
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
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
