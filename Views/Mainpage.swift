//
//  Mainpage.swift
//  MhooPhee
//
//  Created by P W on 1/4/23.
//

 import SwiftUI
 import AVFoundation
import Speech
struct Mainpage: View {
    @State private var isActive1 = false
    @State private var isActive2 = false
    var audioplayer = AudioPlayer()
    var loopaudio = LoopAudioPlayer()
    @State private var audioEngine = AVAudioEngine()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image("Arkom-Yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.2)
                
                Spacer()
                
                Button(action: {
                    audioplayer.playAudio(file: "Click", type: "wav")
                    self.isActive1 = true
                }) {
                    Image("PlayButton")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.2)
                }
                .fullScreenCover(isPresented: $isActive1) {
                    MainGame()
                }
                
                Spacer()
                
                Button(action: {
                    audioplayer.playAudio(file: "Click", type: "wav")
                    self.isActive2 = true
                }) {
                    Image("How2playButton")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.3)
                }
                .fullScreenCover(isPresented: $isActive2) {
                    How2play()
                }
                
                Spacer()
            }
            .padding(.horizontal, geometry.size.width * (verticalSizeClass == .compact ? 0.15 : 0.15)) 
            .padding(.vertical, geometry.size.height * (verticalSizeClass == .compact ? 0.05 : 0.17))
        }
        .background(
            Image("MainPagebg")
                .resizable()
                .opacity(0.3)
                .background(Color.black)
        )
        .onAppear {
            requestMicrophonePermission()
        }
    }
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                startAudioEngine()
            } else {
                print("Microphone permission denied")
            }
        }
    }
    
    func startAudioEngine() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        try? audioEngine.start()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Mainpage()
           .previewInterfaceOrientation(.landscapeLeft)
    }
}

