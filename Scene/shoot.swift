//
//  File.swift
//  
//
//  Created by P W on 10/4/23.
//
/*

import SwiftUI


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


struct shoot: View {
    
    @State private var characterXPosition: CGFloat = UIScreen.main.bounds.width / 100 // centered horizontally
    @State  var characterWidth = UIScreen.main.bounds.width * 0.4
    @State private var leftLimit = -(UIScreen.main.bounds.width * 0.4) / 2
    @State private var rightLimit = UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.4 / 0.5
   
    let charector = ["Animated_arkom1", "Animated_arkom2", "Animated_arkom3","Animated_arkom4"]
    @State private var index = 0
    @State private var offsetY: CGFloat = 110.0
    
    
    
    
    @State private var probs: [Prob] = []
    let prob = [["How2playButton", "How2playButton", "How2playButton","How2playButton"],
                ["How2playButton", "How2playButton", "How2playButton","How2playButton"],
                ["How2playButton", "How2playButton", "How2playButton","How2playButton"],
                ["How2playButton", "How2playButton", "How2playButton","How2playButton"]]
    @State private var probXPosition: CGFloat = 0 // Declare probXPosition as a @State variable
    @State private var probYPosition: CGFloat = 0 // Declare probXPosition as a @State variable
    @State private var currentXPosition: CGFloat = UIScreen.main.bounds.width / 100 // Add a new @State variable for the current x position
    @State private var respawnanimation = false
    @State private var timer: Timer? // Add a timer property to the view
    
    var body: some View {
        VStack {
            ZStack {
                if let lastProb = probs.last {

                    ProbImageView(images: lastProb.images, speed: lastProb.speed, xPosition: $probs[probs.count - 1].xPosition, yPosition: $probs[probs.count - 1].yPosition, leftLimit: leftLimit, rightLimit: rightLimit, characterXPosition: characterXPosition)
                        .id(lastProb.id)
                    //Text(lastProb.id.uuidString)
                    
                }
                
                Button("Add Prob") {
                  
                    if !probs.isEmpty {
                            probs.removeLast()
                        }
                       
                        let newProb = Prob(images: prob[0], speed: 20, xPosition: currentXPosition, yPosition: UIScreen.main.bounds.width * 0.7, characterXPosition: characterXPosition)
                    //onceanimatedImageSequence(imageNames: charector, duration: 0.2, startingIndex: $index, freezeIndex: nil)
                        probs.append(newProb)
                    timer?.invalidate()
                    
                    }.padding()
               
                
            }
            ZStack
            {
                
                animatedImageSequence(imageNames: charector, duration: 0.2, startingIndex: $index, freezeIndex: nil)
                    .offset(x: characterXPosition, y: offsetY)
            }
            
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newPosition = characterXPosition + value.translation.width * 0.075 // scaling factor
                    characterXPosition = min(max(newPosition, leftLimit), rightLimit)
                    currentXPosition = newPosition // Update the current x position
                }
        )
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
        @State private var isVisible = true // add this

        init(images: [String], speed: CGFloat, xPosition: Binding<CGFloat>, yPosition: Binding<CGFloat>, leftLimit: CGFloat, rightLimit: CGFloat, characterXPosition: CGFloat) {
            self.images = images
            self.speed = speed
            self._xPosition = xPosition
            self._yPosition = yPosition
            self.leftLimit = leftLimit
            self.rightLimit = rightLimit
            self.characterXPosition = characterXPosition
        }

        var body: some View {
            if isVisible { // wrap in if statement
                Image(images[index])
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.2)
                    .offset(x: xPosition, y: yPosition)
                    .onAppear {
                        var timer: Timer?
                        timer?.invalidate()
                        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
                            index = (index + 1) % images.count
                            yPosition -= speed
                            if -yPosition > UIScreen.main.bounds.height*0.2 {
                                isVisible = false // set isVisible to false
                                timer?.invalidate()
                                //print(xPosition)
                                index = 0
                            }
                            //print(UIScreen.main.bounds.height - 270 )
                            //print("Probs \(index + 1) - x: \(xPosition), y: \(yPosition)")//
                            print("-y: \(-yPosition)")
                        }
                        RunLoop.main.add(timer!, forMode: .common)
                    }
            }
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
            }
            .onDisappear {
                startingIndex.wrappedValue = 0
            }
            .onAppear {
                let _ = UIImage(named: imageNames[0])
            }
    }
    
    func onceanimatedImageSequence(imageNames: [String], duration: Double, startingIndex: Binding<Int>, freezeIndex: Int?) -> some View {
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
            }
            .onDisappear {
                startingIndex.wrappedValue = 0
            }
            .onAppear {
                let _ = UIImage(named: imageNames[0])
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    startingIndex.wrappedValue = 0
                }
            }
    }

   

    

    
}





struct Shoot_Previews: PreviewProvider {
    static var previews: some View {
        shoot()
    }
}
*/
