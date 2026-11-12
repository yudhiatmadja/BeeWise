import AVFoundation

enum SoundManager {
    private static var players: [AVAudioPlayer] = []

    static func play(_ name: Sound) {
        let url = Bundle.main.url(forResource: name.rawValue, withExtension: "wav")
            ?? Bundle.main.url(forResource: name.rawValue, withExtension: "wav", subdirectory: "Sounds")
        guard let url else { return }
        do {
            // Kategori default (soloAmbient) sudah tunduk ke Silent switch,
            // jadi tidak perlu setCategory — itu yang bikin warning Hang Risk.
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = name.volume
            player.play()
            players.append(player)
            // drop finished players so the array doesn't grow forever
            players = players.filter { $0.isPlaying }
        } catch {
         
        }
    }
}

enum Sound: String {
    case check
    case fanfare
    case shimmer

    var volume: Float {
        switch self {
        case .check: return 0.6
        case .fanfare: return 0.8
        case .shimmer: return 0.7
        }
    }
}
