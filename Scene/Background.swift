//
//  Backgroung.swift
//
//
//  Created by P W on 4/4/23.
//

import SwiftUI

struct Background: View {
    @State private var backgroundOffsetY: CGFloat = 0.0
    @State private var backgroundImages = ["Gamesene1", "Gamesene2"]
    @State private var currentBackgroundIndex = 0
    
    var body: some View {
        ZStack {
            concatenatedBackgroundImages(imageNames: backgroundImages, currentBackgroundIndex: currentBackgroundIndex, offsetY: backgroundOffsetY)
        }
        .ignoresSafeArea(.all)
        .onAppear {
            let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                withAnimation {
                    if backgroundOffsetY == -UIScreen.main.bounds.size.height {
                        currentBackgroundIndex = (currentBackgroundIndex + 1) % backgroundImages.count
                        backgroundOffsetY = 0
                    } else {
                        backgroundOffsetY += 5
                    }
                }
            }
            RunLoop.main.add(timer, forMode: .common)
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
                let y = CGFloat(i - totalImages/2) * UIScreen.main.bounds.size.height + offsetY
                let shouldAnimate = (i >= totalImages/2)
                
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    .offset(y: y)
                    .animation(shouldAnimate ? Animation.easeInOut(duration: 1.0 * Double(imageNames.count)) : nil, value: offsetY)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                    .zIndex(Double(i))
                
                // Add an extra image for the transition
                if i == totalImages - 1 {
                    Image(uiImage: images[currentBackgroundIndex])
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        .offset(y: y + UIScreen.main.bounds.size.height)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                        .zIndex(Double(i))
                }
            }
        }
        .animation(.easeInOut(duration: 1.0), value: offsetY)
        .edgesIgnoringSafeArea(.all)
    }
}


struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        Background()
            
    }
}

