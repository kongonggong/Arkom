import SwiftUI
import Foundation
import AVFoundation

class AudioPlayer {
    var audioPlayer: AVAudioPlayer!
    let audioVolume: Float = 0.5
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }

    init() {}

    func playAudio(file: String, type: String) {
        if let path = Bundle.main.path(forResource: file, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer.volume = audioVolume
                audioPlayer.prepareToPlay()
                fadeIn()
            } catch {
                print("Error: Could not find and play the audio file.")
            }
        }
    }
    
    
    func pauseAudio() {
        if isPlaying {
            audioPlayer.pause()
        }
    }
    
    func resumeAudio() {
        if !isPlaying {
            audioPlayer.play()
        }
    }

    func fadeIn() {
        audioPlayer.volume = audioVolume
        audioPlayer.play()
    }

}
class LoopAudioPlayer
{
    var audioPlayer: AVAudioPlayer!
    let audioVolume: Float = 0.5
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }

    init() {}


    
    func playLoopedAudio(file: String, type: String) {
        if let path = Bundle.main.path(forResource: file, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer.volume = audioVolume
                audioPlayer.prepareToPlay()
                audioPlayer.numberOfLoops = -1
                fadeIn()
            } catch {
                print("Error: Could not find and play the audio file.")
            }
        }
    }
    
    func pauseAudio() {
        if isPlaying {
            audioPlayer.pause()
        }
    }
    
    func resumeAudio() {
        if !isPlaying {
            audioPlayer.play()
        }
    }

    func fadeIn() {
        audioPlayer.volume = audioVolume
        audioPlayer.play()
    }
    func stopAudio() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
    }
}


struct PlayWav: View {
    var audioplayer = AudioPlayer()
    var body: some View
    {
        ZStack
        {
            Image("Speaker")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.15, height:UIScreen.main.bounds.width * 0.15)
                .offset(x: UIScreen.main.bounds.width * 0.0, y:  (UIScreen.main.bounds.height * -0.05))
                .zIndex(1)
                .onTapGesture {
                    //audioplayer.playAudio(file: "Click", type: "wav")
                    //audioplayer.playLoopedAudio(file: "Goblins_Dance_(Battle)", type: "wav")
                }
            Image("Pause")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.15, height:UIScreen.main.bounds.width * 0.15)
                .offset(x: UIScreen.main.bounds.width * 0.3, y:  (UIScreen.main.bounds.height * -0.05))
                .zIndex(1)
                .onTapGesture {
                    audioplayer.pauseAudio()
                    
                }
            Image("Resume")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.15, height:UIScreen.main.bounds.width * 0.15)
                .offset(x: UIScreen.main.bounds.width * 0.3, y:  (UIScreen.main.bounds.height * 0.08))
                .zIndex(1)
                .onTapGesture {
                    audioplayer.resumeAudio()
                    
                }
        }
        
        }
    }
    

struct playwavPreviews: PreviewProvider {
    static var previews: some View {
        PlayWav()
    }
}
