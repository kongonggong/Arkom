//
//  SplashScreen.swift
//  MhooPhee
//
//  Created by P W on 1/4/23.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size: CGFloat = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            Mainpage()
            //SplashScreen()
        } else {
            GeometryReader { geometry in
                let paddingSize = min(geometry.size.width, geometry.size.height) * 0.06
                let imageSize = min(geometry.size.width, geometry.size.height) * 0.7
                let buttonWidth = min(geometry.size.width, geometry.size.height) * 0.9
                
                VStack {
                    
                    
                    VStack {
                        Image("1024x1024_Pixel_Canvas")
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .padding(paddingSize)
                        
                        Image("ArkomButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: buttonWidth, height: imageSize * 0.3)
                    }
                    .background(Image("Spbackground"))
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)){
                            self.size = 0.9
                            self.opacity = 1.0
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            self.isActive = true
                        }
                    }
                    
                    Spacer()
                }
                .padding(paddingSize)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .edgesIgnoringSafeArea(.all)

        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
