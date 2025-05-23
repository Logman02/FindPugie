import AVFoundation
import Foundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var soundEffectPlayer: AVAudioPlayer?
    private var audioPlayer: AVAudioPlayer?
    
    @Published private var isMusicEnabled: Bool = UserDefaults.standard.bool(forKey: "isMusicEnabled") {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "isMusicEnabled")
        }
    }
    
    private init() {
        if isMusicEnabled {
            playMusic()
        }
    }
    
    // Music Methods (unchanged)
    func playMusic() {
        guard isMusicEnabled else { return }
        
        if audioPlayer == nil {
            if let path = Bundle.main.path(forResource: "dodododododododo", ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.numberOfLoops = -1
                    audioPlayer?.play()
                } catch {
                    print("Error playing audio: \(error.localizedDescription)")
                }
            } else {
                print("Audio file 'dodododododododo.mp3' not found!")
            }
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func toggleMusic() {
        isMusicEnabled.toggle()
        isMusicEnabled ? playMusic() : stopMusic()
    }
    
    // Updated Sound Effect Method
    func playSoundEffect(named name: String) {
        // First try with extension if not provided
        let baseName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension.isEmpty ? "mp3" : (name as NSString).pathExtension
        
        guard let path = Bundle.main.path(forResource: baseName, ofType: ext) else {
            print("Sound effect file not found: \(baseName).\(ext)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            // Create a new player for each sound effect
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.7 // Slightly quieter than music
            player.play()
            soundEffectPlayer = player // Keep reference to prevent immediate deallocation
        } catch {
            print("Couldn't play sound effect: \(error.localizedDescription)")
        }
    }
    
    func isMusicOn() -> Bool {
        return isMusicEnabled
    }
}
