import SwiftUI
import CoreMotion
import Speech
import AVFoundation

struct Ghost: Identifiable {
    let id = UUID()
    let images: [String]
    let speed: CGFloat
    var xPosition: CGFloat
    var yPosition: CGFloat
    
    init(images: [String], speed: CGFloat, xPosition: CGFloat, yPosition: CGFloat) {
        self.images = images
        self.speed = speed
        self.xPosition = xPosition
        self.yPosition = yPosition
    }
}

struct Prob: Identifiable {
    let id = UUID()
    let images: [String]
    let speed: CGFloat
    var xPosition: CGFloat
    var yPosition: CGFloat
    let characterXPosition: CGFloat
    
    init(images: [String], speed: CGFloat, xPosition: CGFloat, yPosition: CGFloat, characterXPosition: CGFloat) {
        self.images = images
        self.speed = speed
        self.xPosition = xPosition
        self.yPosition = yPosition
        self.characterXPosition = characterXPosition
    }
}

struct GhostHitView: View {
    let ghostX: CGFloat
    let ghostY: CGFloat
    
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Image(systemName: "star.fill")
            .font(.largeTitle)
            .foregroundColor(.yellow)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0)) {
                    opacity = 0.0
                }
            }
            .position(x: ghostX, y: ghostY)
    }
}


struct MainGame: View {
    
    //randomgen ghost
    @State private var ghosts: [Ghost] = [
        Ghost(images: ["krahang1", "krahang2", "krahang3", "krahang4"], speed: 35, xPosition: 0, yPosition: 0),
        Ghost(images: ["krahang1", "krahang2", "krahang3", "krahang4"], speed: 35, xPosition: 0, yPosition: 0),
        Ghost(images: ["maenark1", "maenark2", "maenark3", "maenark4"], speed: 20, xPosition: 0, yPosition: 0),
        Ghost(images: ["nangram1", "nangram2", "nangram3", "nangram4"], speed: 15, xPosition: 0, yPosition: 0),
        Ghost(images: ["maenark1", "maenark2", "maenark3", "maenark4"], speed: 20, xPosition: 0, yPosition: 0),
        Ghost(images: ["nangram1", "nangram2", "nangram3", "nangram4"], speed: 15, xPosition: 0, yPosition: 0),
        Ghost(images: ["nangram1", "nangram2", "nangram3", "nangram4"], speed: 15, xPosition: 0, yPosition: 0)
    ]
    let leftLimit = -(UIScreen.main.bounds.width * 0.4) / 2
    let rightLimit = UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.4 / 0.5
    var ghostPositions: [(x: CGFloat, y: CGFloat)] {
        var positions = [(x: CGFloat, y: CGFloat)]()
        for ghost in ghosts {
            positions.append((x: ghost.xPosition, y: ghost.yPosition))
        }
        return positions
    }
    
    //charector
    @State private var characterXPosition: CGFloat = UIScreen.main.bounds.width / 100 // centered horizontally
    @State private var freezeIndex: Int?
    let charector = ["Animated_arkom1", "Animated_arkom2", "Animated_arkom3","Animated_arkom4"]
    @State private var index = 0
    @State private var offsetY: CGFloat = -(UIScreen.main.bounds.width * 0.01)
    @State private var currentXPosition: CGFloat = UIScreen.main.bounds.width / 100 // Add a new @State variable for the current x position
    
    //background
    @State private var backgroundOffsetY: CGFloat = 0.0
    @State private var backgroundImages = ["GameScene1","GameScene1","GameScene1"]
    @State private var currentBackgroundIndex = 0
    //scenecontrol
    @State private var gameStarted = false
    @State private var showResult =  false
    @State private var youdied = false
    @State private var alreadydead = false
    @State var isLoading: Bool = false
    @State private var isCorrect = false
    @State private var isPaused = false
    @State private var Tomainscreen = false
    @State private var showhint = false
    @State private var imageOpacity = 1.0
    @State private var showeffect = false
    //collision treshold
    let collisionThreshold: CGFloat = 32
    let shotcollisionThreshold: CGFloat = 50
    @State private var HitghostX = 0.0
    @State private var HitghostY = 0.0
    //timer
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var remainingTime: TimeInterval = 150// The total time for the timer
    @State var pausedTime: TimeInterval? = nil // The time remaining when the timer is paused
    @State var starttimer : Timer?
    //gyroscope
    let motionManager = CMMotionManager()
    //Speech
    var speechRecognizer = SpeechRecognizer()
    let synthesizer = AVSpeechSynthesizer()

 
   // prob
    @State private var probs: [Prob] = []
    let prob = [["Pillow1", "Pillow2", "Pillow3", "Pillow4"],
                ["Bottle1", "Bottle2", "Bottle3", "Bottle4","Bottle5","Bottle6","Bottle7","Bottle8"],
                ["Money1", "Money2", "Money3", "Money4","Money5","Money6"],
                ["Book1", "Book2", "Book3", "Book4"],
                ["Iphone1", "Iphone5","Iphone2","Iphone6" ,"Iphone3", "Iphone7","Iphone4","Iphone8"]]
    @State private var probXPosition: CGFloat = 0 // Declare probXPosition as a @State variable
    @State private var probYPosition: CGFloat = 0 // Declare probXPosition as a @State variable
    @State var opacityValue = 1.0
    @State private var isImageEnabled = true
    //hint
    let hint = ["Hint1", "Hint2", "Hint3","Hint4","Hint5"]
    let word = [ "Pillow", "Water","Money","Book","Telephone"]
    
    //audio
    @State private var loopaudiostart = false
    var audioplayer = AudioPlayer()
    var loopaudio = LoopAudioPlayer()

    
    var body: some View {
        
        VStack {
            Spacer()
            if gameStarted && !showResult && !youdied {
                HStack{

                    ZStack{
                        if let lastProb = probs.last {

                            ProbImageView(images: lastProb.images, speed: lastProb.speed, xPosition: $probs[probs.count - 1].xPosition, yPosition: $probs[probs.count - 1].yPosition, leftLimit: leftLimit, rightLimit: rightLimit, characterXPosition: characterXPosition)
                                .id(lastProb.id)
                            //Text(lastProb.id.uuidString)
                        }
                        
                        ZStack {
                            
                            if speechRecognizer.isCorrect {
                                Image("Correct")
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.size.width*0.15, height: UIScreen.main.bounds.size.height*0.1)
                                    
                                    .onReceive(speechRecognizer.$isCorrect) { isCorrect in
                                        if isCorrect {
                                            if !probs.isEmpty {
                                                    probs.removeLast()
                                                }
                                            let newProb = Prob(images: prob[speechRecognizer.currentWordIndex], speed: 20, xPosition: currentXPosition, yPosition: UIScreen.main.bounds.width * 0.5, characterXPosition: characterXPosition)
                                    
                                            probs.append(newProb)
                                        }
                                   }
                            }
                            
              
                            
                            if showeffect{
                                HitXghost(ghostHitX: HitghostX, ghostHitY: HitghostY)
                            }

                            ForEach(ghosts.indices) { index in
                                GhostImageView(images: ghosts[index].images, speed: ghosts[index].speed, xPosition: $ghosts[index].xPosition, yPosition: $ghosts[index].yPosition, leftLimit: leftLimit, rightLimit: rightLimit,isPaused: $isPaused)
                            }
                        }.zIndex(-1)
                        
                        VStack {
                            if !isPaused
                            {
                                Image("Pause")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width * 0.15, height:UIScreen.main.bounds.width * 0.15)
                                    .offset(x: UIScreen.main.bounds.width * 0.4, y:  (UIScreen.main.bounds.height * -0.05))
                                    .zIndex(1)
                                    .onTapGesture {
                                        loopaudio.pauseAudio()
                                        audioplayer.playAudio(file: "Click", type: "wav")
                                        pauseTime()
                                        isPaused = true
                                    }
                            }
                            
                         
                            
                            Button(action: {
                                if speechRecognizer.isRecording {
                                    speechRecognizer.stopRecording()
                                } else {
                                    speechRecognizer.startRecording()
                                }
                            }, label: {
                                if !isPaused
                                {
                                    Image(speechRecognizer.isRecording ? "micoff" : "micon")
                                   .resizable()
                                   .frame(width: UIScreen.main.bounds.width * 0.15, height:UIScreen.main.bounds.width * 0.15)
                                  
                                }
                               
                                    
                            })
                            .offset(x: UIScreen.main.bounds.width * 0.4, y:  (UIScreen.main.bounds.height * 0.522))
                     
                         
                            
                        }.zIndex(-1)
                 
                 
                        
                       
                            Group
                            {
                                ZStack
                                {
                                    if !speechRecognizer.isWait
                                    {
                                        Text(speechRecognizer.currentWord)
                                            .font(.system(size: UIScreen.main.bounds.width * 0.05))
                                            .bold()
                                            .offset(x: -UIScreen.main.bounds.width * 0.01, y:  (-UIScreen.main.bounds.height * 0.2)).zIndex(2)
                                            .foregroundColor(.orange)
                                    }
                                   
                                    Image("MainButton")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.35)
                                        .offset(x: UIScreen.main.bounds.width * -0.01 , y: UIScreen.main.bounds.height * -0.202)
                                        .zIndex(1)
                                        .onTapGesture {
                                            audioplayer.playAudio(file: "Click", type: "wav")
                                            loopaudio.pauseAudio()
                                            pauseTime()
                                            showhint = true
                                            isPaused = true
                                        }
                                }
                            }
                            
                        
                        if showhint{
                            ZStack
                            {
                                Pausescreen(isPaused: true)
                                    .zIndex(0)
                            }
                            ZStack
                            {
                                GeometryReader { geometry in
                                    Image("SpeakerButton")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.18, height: geometry.size.height
                                               * 0.18)
                                        .offset(x: geometry.size.width * 0.57, y: geometry.size.height * -0.01)
                                        .zIndex(1)
                                        .onTapGesture {
                                            speak( word[speechRecognizer.currentWordIndex])
                                        }
                                    
                                    Image(hint[speechRecognizer.currentWordIndex])
                                        .resizable()
                                        .offset(x: geometry.size.width * -0.00, y: geometry.size.height * 0.3)
                                        .frame(width: geometry.size.width * 1.0, height: geometry.size.height
                                               * 1.4)
                                    
                                    
                                    Image("close")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.18, height: geometry.size.height * 0.18)
                                        .offset(x: geometry.size.width * 0.78, y: geometry.size.height *  -0.01)
                                        .zIndex(1)
                                        .onTapGesture {
                                            audioplayer.playAudio(file: "Click", type: "wav")
                                            loopaudio.resumeAudio()
                                            isPaused = false
                                            showhint = false
                                            resumeTime()
                                        }
                                }
                            }
                        }
                        
                        
                        if isPaused && !showhint
                        {
                               ZStack
                               {
                                   Pausescreen(isPaused: true)
                                       .zIndex(0)
                               }
                               ZStack
                               {
                                   Image("Resume")
                                       .resizable()
                                       .scaledToFit()
                                       .frame(width: UIScreen.main.bounds.width * 0.18, height: UIScreen.main.bounds.height * 0.18)
                                       .offset(x: UIScreen.main.bounds.width * -0.16, y: UIScreen.main.bounds.height * 0.2)
                                       .zIndex(1)
                                       .onTapGesture {
                                           loopaudio.resumeAudio()
                                           audioplayer.playAudio(file: "Click", type: "wav")
                                           isPaused = false
                                           resumeTime()
                                       }
                                   Image("Home")
                                       .resizable()
                                       .scaledToFit()
                                       .frame(width: UIScreen.main.bounds.width * 0.18, height: UIScreen.main.bounds.height * 0.18)
                                       .offset(x: UIScreen.main.bounds.width * 0.15, y: UIScreen.main.bounds.height * 0.2)
                                       .zIndex(1)
                                       .onTapGesture {
                                           audioplayer.playAudio(file: "Click", type: "wav")
                                           self.Tomainscreen = true
                                           loopaudio.stopAudio()
                                       }.fullScreenCover(isPresented: $Tomainscreen) {
                                           Mainpage()
                                       }

                                   
                               }
                                    
                           }
                        
                        
                        
                        
                           
                        
                    }
                    
                    
                    .onAppear {
                       
                            loopaudio.playLoopedAudio(file: "Goblins_Dance_(Battle)", type: "wav")
              
                        // Start a timer that runs the collision detection code repeatedly
                        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in

                            // Check for collision between character and each ghost
                            for index in ghosts.indices {
                                let ghostX = ghosts[index].xPosition
                                let ghostY = ghosts[index].yPosition
                                
                                
                                let distance = abs(ghostX-characterXPosition)
                                //let distance = sqrt(pow((ghostX - characterXPosition), 2) + pow((ghostY - offsetY), 2))
                                if !probs.isEmpty {
                                        let probX = probs[probs.count - 1].xPosition
                                        let probY = probs[probs.count - 1].yPosition
                                       // let shotdistance = abs(ghostX-probX)
                                        let shotdistance = sqrt(pow((ghostX - probX), 2) + pow((ghostY - probY), 2))
                                        //print(" Y:\(probY)")
                                       // print("Ghost Y\(ghostY)")
                                    if (shotdistance < shotcollisionThreshold) {
                                                   // Collision detected, respawn ghost to a new position
                                                      HitghostX = ghostX
                                                      HitghostY = ghostY
                                        audioplayer.playAudio(file: "Explotion", type: "mp3")
                                        
                                                        showeffect = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                        showeffect = false
                                                    }
                                        
                                                    ghosts[index].xPosition = CGFloat.random(in: leftLimit..<rightLimit)
                                                    ghosts[index].yPosition = -500
                                                    probs[probs.count - 1].xPosition = -5000
                                                    probs[probs.count - 1].yPosition = -5000
                                                   return
                                               }
                                    
                                    
                                    }
                                
                                //print("distant\(distance)")
                                //print("Charecter X\(characterXPosition) Charecter Y\(offsetY)")
                                //print("Ghost \(index + 1) \(distance)")
                                //print("Ghost\(index+1) X:\(ghostX) Y:\(ghostY)")
                                //print(-(UIScreen.main.bounds.width * 0.01))  // -3.9
                                //print(geometry.size.width * 0.5)
                                //print(rightLimit)
                                if distance < collisionThreshold && ((UIScreen.main.bounds.height * 0.44) <= ghostY && (UIScreen.main.bounds.height * 0.5) >= ghostY)  {
                                               // Collision detected, stop character animation and display "You Died"
                                               freezeIndex = 0
                                            if !showResult
                                            {
                                                stoptime()
                                                youdied = true
                                                loopaudio.stopAudio()
                                                gameStarted = false
                                                 showResult = false
                                            }
                                               return
                                           }
                                
                            }
                        }
                    }
                    .onAppear {
                        
                        
                        for index in ghosts.indices{
                                ghosts[index].xPosition = CGFloat.random(in: leftLimit..<rightLimit)
                                ghosts[index].yPosition = CGFloat.random(in: -1000...0)
                            }
                        
                        
                    }
    
                
            }
                
               
                
             

                ZStack
                {
                    animatedImageSequence(imageNames: charector, duration: 0.2, startingIndex: $index, freezeIndex: freezeIndex)
                        .offset(x: characterXPosition, y: offsetY)
                }.zIndex(-1)
                  

                
            }
            else if showResult && !youdied && !gameStarted {
                GeometryReader { geometry in
                    ZStack {
                        Pausescreen(isPaused: true)
                        ZStack {
                            Image("Home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: min(geometry.size.width, geometry.size.height) * 0.18, height: min(geometry.size.width, geometry.size.height) * 0.18)
                                .offset(x: geometry.size.width * 0.66 - min(geometry.size.width, geometry.size.height) * 0.09, y: geometry.size.height * 0.6 - min(geometry.size.width, geometry.size.height) * 0.09)
                                .zIndex(1)
                                .onTapGesture {
                                    audioplayer.playAudio(file: "Click", type: "wav")
                                    self.Tomainscreen = true
                                }.fullScreenCover(isPresented: $Tomainscreen) {
                                    Mainpage()
                                }

                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                        .padding(.horizontal, geometry.safeAreaInsets.leading)
                        
                        if !isLoading {
                            Image("Yousurvied")
                                .resizable()
                                .scaledToFit()
                                .offset(x: 0, y: geometry.size.height * 0.09)
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.8)
                                .padding(.vertical, geometry.size.height * 0.3)
                                .padding(.horizontal, geometry.size.width * 0.17)
                                .offset(y: -geometry.size.height * 0.18)
                                .zIndex(1)
                        }
                        
                        VStack {
                            Image("RestartButton")//restart
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.18, height: geometry.size.height * 0.18)
                                .offset(x: -geometry.size.width * 0.14, y:  geometry.size.height * 0.10)
                                .padding(.vertical, geometry.size.width * 0.1)
                                .zIndex(-1)
                                .onTapGesture {
                                    audioplayer.playAudio(file: "Click", type: "wav")
                                    isLoading = true
                                    restartGame()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        showResult = false
                                        youdied = false
                                        gameStarted = true
                                        isLoading = false
                                        isPaused = false
                                    }
                                }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .edgesIgnoringSafeArea(.all)
            }
            else if !gameStarted && !showResult && youdied {
                GeometryReader { geometry in
                    ZStack {
                        Pausescreen(isPaused: true)
                        ZStack {
                            Image("Home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: min(geometry.size.width, geometry.size.height) * 0.18, height: min(geometry.size.width, geometry.size.height) * 0.18)
                                .offset(x: geometry.size.width * 0.66 - min(geometry.size.width, geometry.size.height) * 0.09, y: geometry.size.height * 0.6 - min(geometry.size.width, geometry.size.height) * 0.09)
                                .zIndex(1)
                                .onTapGesture {
                                    audioplayer.playAudio(file: "Click", type: "wav")
                                    self.Tomainscreen = true
                                }.fullScreenCover(isPresented: $Tomainscreen) {
                                    Mainpage()
                                }

                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                        .padding(.horizontal, geometry.safeAreaInsets.leading)
                        
                        if !isLoading {
                            Image("youdied")
                                .resizable()
                                .scaledToFit()
                                .offset(x: 0, y: geometry.size.height * 0.09)
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.8)
                                .padding(.vertical, geometry.size.height * 0.3)
                                .padding(.horizontal, geometry.size.width * 0.17)
                                .offset(y: -geometry.size.height * 0.18)
                                .zIndex(1)
                        }
                        if isLoading {
                            Image("Loading")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 1.2)
                                .padding(.vertical, geometry.size.height * -0.1)
                                .padding(.horizontal, geometry.size.width * 0.1)
                                .zIndex(1)
                                .background(
                                    Rectangle()
                                        .fill(Color(.black))
                                        .frame(width: 5000, height: 5000)
                                )
                        }
                        VStack {
                            Image("RestartButton")//restart
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.18, height: geometry.size.height * 0.18)
                                .offset(x: -geometry.size.width * 0.14, y:  geometry.size.height * 0.10)
                                .padding(.vertical, geometry.size.width * 0.1)
                                .zIndex(-1)
                                .onTapGesture {
                                    audioplayer.playAudio(file: "Click", type: "wav")
                                    isLoading = true
                                    restartGame()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        showResult = false
                                        youdied = false
                                        gameStarted = true
                                        isLoading = false
                                        isPaused = false
                                    }
                                }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .edgesIgnoringSafeArea(.all)
            }

                    
            else {
                VStack{
                    GeometryReader { geometry in
                        Pausescreen(isPaused: true)
                        
                        Image("TAPTOSTART")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.8)
                            .padding(.horizontal,  geometry.size.width * 0.15)
                            .padding(.vertical,  geometry.size.width * 0.0)
                            .onTapGesture {
                                audioplayer.playAudio(file: "Taptostart", type: "wav")
                                loopaudiostart = true
                                gameStarted = true
                                youdied = false
                                youdied = false
                                showResult = false
                                starttime()
                                
                            }
                        
                        ZStack
                        {
                            Image("Instruct1")
                                .resizable()
                            
                                .offset(x: UIScreen.main.bounds.width * 0.05, y: UIScreen.main.bounds.height * 0.55)
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.035)
                            
                            .zIndex(1)
                            Image("Instruct2")
                                .resizable()
                            
                                .offset(x: UIScreen.main.bounds.width * 0.05, y: UIScreen.main.bounds.height * 0.65)
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.07)
                            
                            .zIndex(1)
                            Image("Instruct3")
                                .resizable()
                            
                                .offset(x: UIScreen.main.bounds.width * 0.05, y: UIScreen.main.bounds.height * 0.75)
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.07)
                            
                            .zIndex(1)
                        }
                        
                        
                    }
                }
            }
        }
        .background(concatenatedBackgroundImages(imageNames: backgroundImages, currentBackgroundIndex: currentBackgroundIndex, offsetY: backgroundOffsetY))
        .gesture(
            
            DragGesture()
                .onChanged { value in
                    if !isPaused
                    {
                        let newPosition = characterXPosition + value.translation.width * 0.065 // scaling factor
                        characterXPosition = min(max(newPosition, leftLimit), rightLimit)
                        currentXPosition = newPosition // Update the current x position
                    }
                   
                }
        )
        .onAppear {
          
            startGyroscope()
            _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                
                withAnimation {
                    if isPaused
                    {
                        backgroundOffsetY += 0
                    }
                    else
                    {
                        if gameStarted{
                            if backgroundOffsetY == -UIScreen.main.bounds.size.height {
                                currentBackgroundIndex = (currentBackgroundIndex + 1) % backgroundImages.count
                                backgroundOffsetY = 0
                            } else {
                                backgroundOffsetY += 5
                            }
                        }
                    }
         
                }
            }
        }
    }
    
    struct HitXghost : View
    {
        let  ghostHitX : CGFloat
        let  ghostHitY : CGFloat
        @State var opacity = 1.00
        var body: some View {
            HStack
            {
                Image("Explotion")
                    .resizable()
                    .opacity(opacity)
                    .frame(width: UIScreen.main.bounds.size.width*0.15, height: UIScreen.main.bounds.size.height*0.1)
                    .onAppear {
                        
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        opacity = 0.0
                                    }
                                }
                    .offset(x: ghostHitX, y: ghostHitY)
                }
          
            }
               
    }
    struct Pausescreen : View
    {
        
        let  isPaused : Bool
        var body: some View {
            
                if isPaused
                {
                    GeometryReader { geometry in
                        Rectangle()
                            .opacity(0.8)
                            .foregroundColor(.black)
                            .frame(width: geometry.size.width, height: geometry.size.height*50)
                            .ignoresSafeArea()
                            .offset(x:0,y:-geometry.size.width)
                            .zIndex(1)
                        
                    }
                   
                
            }
        }
              
    }
    
    
 
    
    struct ProbImageView: View {
        let images: [String]
        let speed: CGFloat
        @Binding var xPosition: CGFloat
        @Binding var yPosition: CGFloat
        let leftLimit: CGFloat
        let rightLimit: CGFloat
        @State private var index = 0
        let characterXPosition: CGFloat
        @State private var isVisible = true

        init(images: [String], speed: CGFloat, xPosition: Binding<CGFloat>, yPosition: Binding<CGFloat>, leftLimit: CGFloat, rightLimit: CGFloat, characterXPosition: CGFloat) {
            self.images = images
            self.speed = 40
            self._xPosition = xPosition
            self._yPosition = yPosition
            self.leftLimit = leftLimit
            self.rightLimit = rightLimit
            self.characterXPosition = characterXPosition
        }
       
        var body: some View {
            if isVisible {
                Image(images[index])
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.1)
                    .offset(x: xPosition, y: yPosition)
                    .onAppear {
                        var timer: Timer?
                        timer?.invalidate()
                        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                            index = (index + 1) % images.count
                            yPosition -= speed
                            if -yPosition > UIScreen.main.bounds.height*0.3 {
                                isVisible = false // set isVisible to false
                                timer?.invalidate()
                                //print(xPosition)
                                xPosition = -5000
                                yPosition = -5000
                                index = 0
                            }
                            //print(UIScreen.main.bounds.height - 270 )
                            //print("Probs \(index + 1) - x: \(xPosition), y: \(yPosition)")//
                            //print("-y: \(-yPosition)")
                        }
                        RunLoop.main.add(timer!, forMode: .common)
                    }
            }
        }
    }


    
    struct GhostImageView: View {
        let images: [String]
        let speed: CGFloat
        @Binding var xPosition: CGFloat
        @Binding var yPosition: CGFloat
        let leftLimit: CGFloat
        let rightLimit: CGFloat
        @State private var index = 0
        
        @Binding var isPaused: Bool
        
        var body: some View {
            Image(images[index])
                .resizable()
                .scaledToFit()
                .scaleEffect(0.2)
                .offset(x: xPosition, y: yPosition)
                .onAppear {
                    var timer: Timer?
                    timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
                        index = (index + 1) % images.count
                        if isPaused
                        {
                            yPosition += 0
                        }
                        else
                        {
                            yPosition += speed
                            
                        }
                      
                        if yPosition > UIScreen.main.bounds.height*0.8 {
                            yPosition = -500
                            xPosition = CGFloat.random(in: leftLimit..<rightLimit)
                            //print(xPosition)
                            index = 0
                        }
                        //print("Ghost \(index + 1) - x: \(xPosition), y: \(yPosition)")//
                    }
                    RunLoop.main.add(timer!, forMode: .common)
                }
        }
        
    }
    
    
    
    private func startGyroscope() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (data, error) in
                guard let data = data else {
                    print("Device motion error: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                
                let rotation = data.rotationRate.z
                let speed = CGFloat(rotation) * 25 // scaling factor
                
                DispatchQueue.main.async {
                    if !isPaused
                    {
                    let newPosition = characterXPosition - speed // negative because speed is in opposite direction to position
                    characterXPosition = min(max(newPosition, leftLimit), rightLimit)
                   
                        currentXPosition = newPosition // Update the current x position
                    }
                  
                }
            }
        } else {
            print("Device motion not available")
        }
    }

   

    
    func animatedImageSequence(imageNames: [String], duration: Double, startingIndex: Binding<Int>, freezeIndex: Int?) -> some View {
        return Image(imageNames[startingIndex.wrappedValue])
            .resizable()
            .scaledToFit()
            .scaleEffect(0.2)
            .onAppear {
                let timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { _ in
                    if let freezeIndex = freezeIndex {
                        if startingIndex.wrappedValue == freezeIndex {
                            return
                        }
                    }
                    startingIndex.wrappedValue = (startingIndex.wrappedValue + 1) % imageNames.count
                }
                RunLoop.main.add(timer, forMode: .common)
                if alreadydead {
                    alreadydead = false
                    timer.invalidate()
                    startingIndex.wrappedValue = 0
                }
            }
            .onDisappear {
                startingIndex.wrappedValue = 0
            }
            .onAppear {
                let _ = UIImage(named: imageNames[0])
            }
    }
    
    func speak(_ string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    func restartGame() {
        ghosts = [
            Ghost(images: ["krahang1", "krahang2", "krahang3", "krahang4"], speed: 0, xPosition: 0, yPosition: 0),
            Ghost(images: ["krahang1", "krahang2", "krahang3", "krahang4"], speed: 0, xPosition: 0, yPosition: 0),
            Ghost(images: ["maenark1", "maenark2", "maenark3", "maenark4"], speed: 0, xPosition: 0, yPosition: 0),
            Ghost(images: ["nangram1", "nangram2", "nangram3", "nangram4"], speed: 0, xPosition: 0, yPosition: 0),
            Ghost(images: ["maenark1", "maenark2", "maenark3", "maenark4"], speed: 0, xPosition: 0, yPosition: 0),
            Ghost(images: ["nangram1", "nangram2", "nangram3", "nangram4"], speed: 0, xPosition: 0, yPosition: 0),
            Ghost(images: ["nangram1", "nangram2", "nangram3", "nangram4"], speed: 0, xPosition: 0, yPosition: 0)
        ]
        characterXPosition = UIScreen.main.bounds.width / 100 // centered horizontally
        freezeIndex = nil
        index = 0
        backgroundOffsetY = 0.0
        currentBackgroundIndex = 0
        alreadydead = true
        remainingTime = 150
        starttime()
    }
    
    
    
    func starttime() {
           starttimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
               self.remainingTime -= 1
               print("Time left: \(self.remainingTime)")
               
               if self.remainingTime <= 0 {
                   starttimer?.invalidate() // Stop the timer after firing
                   stoptime()
                   self.audioplayer.playAudio(file: "win", type: "mp3")
                   self.loopaudio.stopAudio()
                   self.showResult = true
                   self.gameStarted = false
                   self.youdied = false
                  
               }
           }
       }
    
    func stoptime() {
           starttimer?.invalidate()
           starttimer = nil
        
       }
       
    
    func pauseTime() {
            
           self.pausedTime = self.remainingTime
           self.starttimer?.invalidate()
           self.starttimer = nil
        
       }
       
       func resumeTime() {
           if let pausedTime = self.pausedTime {
               self.remainingTime = pausedTime
               self.pausedTime = nil
               self.starttime()
           }
       }
       
   
    
    func concatenatedBackgroundImages(imageNames: [String], currentBackgroundIndex: Int, offsetY: CGFloat) -> some View {
        let totalImages = imageNames.count * 20 + 1 // Concatenate 20 copies of each image
        var images = [UIImage]()
        for imageName in imageNames {
            if let image = UIImage(named: imageName) {
                images.append(image)
            }
        }
        return ZStack {
            ForEach(0..<totalImages) { i in
                let index = (currentBackgroundIndex + i/20) % imageNames.count
                let imageName = imageNames[index]
                let y = CGFloat(i - totalImages/2) * (UIScreen.main.bounds.size.height - 10) + offsetY
                
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    .offset(y: y)
                    .animation(Animation.easeInOut(duration: 1.0 * Double(imageNames.count)), value: offsetY)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                    .zIndex(Double(i))
                
                // Add an extra image for the transition
                if i == totalImages - 1 {
                    Image(uiImage: images[currentBackgroundIndex])
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        .offset(y: y + UIScreen.main.bounds.size.height - 10)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                        .zIndex(Double(i))
                }
            }
        }
    }

    
}

struct Maingame_Previews: PreviewProvider {
    static var previews: some View {
      MainGame()
    }
}

