import AVFoundation
import Foundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    // @Published property to automatically notify the UI when it changes
    @Published private var isMusicEnabled: Bool = UserDefaults.standard.bool(forKey: "isMusicEnabled") {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "isMusicEnabled")
        }
    }
    
    private init() {
        // Start playing music if it's enabled when the app starts
        if isMusicEnabled {
            playMusic()
        }
    }
    
    // Play the audio file "dodododododododo"
    func playMusic() {
        guard isMusicEnabled else { return }
        
        if audioPlayer == nil {
            if let path = Bundle.main.path(forResource: "dodododododododo", ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                    audioPlayer?.play()
                } catch {
                    print("Error playing audio: \(error.localizedDescription)")
                }
            } else {
                print("Audio file 'dodododododododo.mp3' not found!")
            }
        }
    }
    
    // Stop music
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    // Toggle music on/off
    func toggleMusic() {
        isMusicEnabled.toggle()
        
        if isMusicEnabled {
            playMusic()
        } else {
            stopMusic()
        }
    }
    
    // Check if music is enabled
    func isMusicOn() -> Bool {
        return isMusicEnabled
    }
}
