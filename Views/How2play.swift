//
//  File.swift
//
//
//  Created by P W on 8/4/23.
//

import SwiftUI
import Speech
import AVFoundation


struct How2play: View {
    @State private var pageIndex = 0
    @State private var toMainScreen = false
    @State private var screenWidth: CGFloat = 0.0
    @State private var screenHeight: CGFloat = 0.0
    
    var page = ["Howtoplay1","Howtoplay2","Howtoplay3","Howtoplay4"]
    let audioPlayer = AudioPlayer()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                    Image(page[pageIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
            
                Spacer()
                
                HStack {
                    Image("close")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                        .onTapGesture {
                            audioPlayer.playAudio(file: "Click", type: "wav")
                            self.toMainScreen = true
                        }
                        .fullScreenCover(isPresented: $toMainScreen) {
                            Mainpage()
                        }
                    
                    Spacer()
                    Image("Next")//back
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                        .rotationEffect(.degrees(180))
                        .onTapGesture {
                            pageIndex = (pageIndex - 1) % page.count
                            if(pageIndex == -1)
                            {
                                pageIndex = 4
                            }
                            audioPlayer.playAudio(file: "Click", type: "wav")
                        }
                    Image("Next")//back
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                        .onTapGesture {
                            pageIndex = (pageIndex + 1) % page.count
                            audioPlayer.playAudio(file: "Click", type: "wav")
                        }
                  

                }
                .padding()
            }
            .background(
                Image("MainPagebg")
                    .resizable()
                    .opacity(0.3)
                    .background(Color.black)
            )
            .frame(width: screenWidth, height: screenHeight)
            .onAppear {
                screenWidth = geometry.size.width
                screenHeight = geometry.size.height
            }
            .onChange(of: UIScreen.main.bounds.size) { _ in
                screenWidth = geometry.size.width
                screenHeight = geometry.size.height
            }
        }
    }
}

struct How2play_Previews: PreviewProvider {
    static var previews: some View {
        How2play()

    }
}

