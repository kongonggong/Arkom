//
//  File.swift
//
//
//  Created by P W on 6/4/23.
//
/*
import SwiftUI

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

struct randomgen: View {
    @State private var ghosts: [Ghost] = [
        Ghost(images: ["Animated_arkom1", "Animated_arkom2", "Animated_arkom3", "Animated_arkom4"], speed: 15, xPosition: 0, yPosition: 0),
        Ghost(images: ["Arkom", "Animated_arkom2", "Animated_arkom3", "Animated_arkom4"], speed: 10, xPosition: 0, yPosition: 0),
        Ghost(images: ["ArkomButton", "Animated_arkom2", "Animated_arkom3", "Animated_arkom4"], speed: 20, xPosition: 0, yPosition: 0),
        Ghost(images: ["Animated_arkom1", "Animated_arkom2", "Animated_arkom3", "Animated_arkom4"], speed: 15, xPosition: 0, yPosition: 0)
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
    
    var body: some View {
        ZStack {
            ForEach(ghosts.indices) { index in
                GhostImageView(images: ghosts[index].images, speed: ghosts[index].speed, xPosition: $ghosts[index].xPosition, yPosition: $ghosts[index].yPosition, leftLimit: leftLimit, rightLimit: rightLimit)
            }
        }
        .onAppear {
            for index in ghosts.indices {
                ghosts[index].xPosition = CGFloat.random(in: leftLimit..<rightLimit)
                ghosts[index].yPosition = CGFloat.random(in: -1000...0)
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
    
    var body: some View {
        Image(images[index])
            .resizable()
            .scaledToFit()
            .scaleEffect(0.2)
            .offset(x: xPosition, y: yPosition)
            .onAppear {
                var timer: Timer?
                timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                    index = (index + 1) % images.count
                    yPosition += speed
                    if yPosition > UIScreen.main.bounds.height - 300 {
                        yPosition = -500
                        xPosition = CGFloat.random(in: leftLimit..<rightLimit)
                        index = 0
                    }
                    print("Ghost \(index + 1) - x: \(xPosition), y: \(yPosition)")//
                }
                RunLoop.main.add(timer!, forMode: .common)
            }
    }

}

struct GhostView_Previews: PreviewProvider {
    static var previews: some View {
        randomgen()
        
    }
}
*/
