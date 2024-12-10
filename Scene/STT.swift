//
//  File.swift
//
//
//  Created by P W on 8/4/23.
//


 //
 //  File.swift
 //
 //
 //  Created by P W on 8/4/23.
 //

 import SwiftUI
 import Speech
 import AVFoundation
 
class SpeechRecognizer: NSObject, ObservableObject {
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    var currentWordIndex: Int {
           return words.firstIndex(of: currentWord) ?? 0
       }
    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var isCorrect = false
    @Published var isWait = true
    
    let words = [ "Pillow", "Water","Money","Book","Telephone"]// prob , hint
    var currentWord = ""
    
    override init() {
        super.init()
        requestSpeechAuthorization()
        getNextWord()
    }
    
    func getNextWord() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentWord = self.words.randomElement() ?? ""
            self.isWait = false
        }
    }

    
    func checkAnswer() {
        isCorrect = recognizedText.lowercased() == currentWord.lowercased()
        if isCorrect {
            getNextWord()
            self.isWait = true
        }
    }
  
    func startRecording() {
        self.recognizedText = ""
        self.isCorrect = false
        
        // End any ongoing recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = recognitionRequest
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recognitionFormat = inputNode.outputFormat(forBus: 0)
        
        // Remove any existing tap on the input node
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recognitionFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            fatalError("Audio engine failed to start: \(error.localizedDescription)")
        }
        
        guard let speechRecognizer = speechRecognizer else {
            fatalError("Speech recognizer not available for locale")
        }
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let words = result.bestTranscription.segments
                    .map({$0.substring})
                    .joined(separator: " ")
                    .split(separator: " ")
                self.recognizedText = String(words.last ?? "")
                self.checkAnswer()
            } else if let error = error {
                print("Recognition task error: \(error.localizedDescription)")
            }
        }
        
        isRecording = true
    }
    
    func clearCache() {
        if let recognitionTask = recognitionTask {
            speechRecognizer?.defaultTaskHint = .dictation
            recognitionTask.cancel()
            self.recognitionTask = nil
            self.recognitionRequest = nil
        }
    }
        

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        clearCache()
        isRecording = false
        checkAnswer()
    }

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("User denied access to speech recognition")
                case .restricted:
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    print("Speech recognition not yet authorized")
                @unknown default:
                    fatalError()
                }
            }
        }
    }
}
/*

 struct STT: View {
     @StateObject private var speechRecognizer = SpeechRecognizer()
         @State private var showAlert = false
         
         var body: some View {
             VStack {
                 //Text("Current word index: \(speechRecognizer.currentWordIndex)")
                 Text(speechRecognizer.currentWord)
                     .font(.title)
                     .padding()
                 
                 Button(action: {
                     if speechRecognizer.isRecording {
                         speechRecognizer.stopRecording()
                     } else {
                         speechRecognizer.startRecording()
                     }
                 }, label: {
                     Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "record.circle.fill")
                         .resizable()
                         .frame(width: 64, height: 64)
                         .foregroundColor(speechRecognizer.isRecording ? .red : .green)
                 })
                 
                 Text("You said: \(speechRecognizer.recognizedText)")
                     .padding()
                 
                 if showAlert {
                     if speechRecognizer.isCorrect {
                         Text("Correct!")
                             .foregroundColor(.green)
                     } else {
                         Text("Incorrect! The correct answer was \(speechRecognizer.currentWord)")
                             .foregroundColor(.red)
                     }
                 }
             }
         }
 }


 struct STT_Previews: PreviewProvider {
     static var previews: some View {
         STT()
     }
 }

*/


