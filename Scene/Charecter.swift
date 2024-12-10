//
//  File.swift
//  
//
//  Created by P W on 6/4/23.
//

import SwiftUI




struct Character: View {
   
    
    @State private var characterXPosition: CGFloat = UIScreen.main.bounds.width / 100 // centered horizontally
    @State  var characterWidth = UIScreen.main.bounds.width * 0.4
    @State private var leftLimit = -(UIScreen.main.bounds.width * 0.4) / 2
    @State private var rightLimit = UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.4 / 0.5
    
    let charector = ["Animated_arkom1", "Animated_arkom2", "Animated_arkom3","Animated_arkom4"]
    @State private var index = 0
    @State private var offsetY: CGFloat = 110.0
    
   
    
    var body: some View {
        
        animatedImageSequence(imageNames: charector, duration: 0.2, startingIndex: $index, freezeIndex: nil)
            .offset(x: characterXPosition, y: offsetY)

            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newPosition = characterXPosition + value.translation.width * 0.075 // scaling factor
                        characterXPosition = min(max(newPosition, leftLimit), rightLimit)
                    }
            )
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
    
}


struct Char_Previews: PreviewProvider {
    static var previews: some View {
        Character()
    }
}
