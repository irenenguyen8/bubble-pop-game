//
//  ContentView.swift
//  BubblePopGame
//
//  Created by Nguyet Nga Nguyen on 15/4/2025.
//

import SwiftUI

struct ContentView: View {
    // State variables to control navigation
    @State private var showSettings = false
    @State private var showHighScores = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // Backgroud color
                Color.pink.opacity(0.1).ignoresSafeArea()
                VStack (spacing: 40){
                    
                    // Game Title
                    Label("Bubble Pop", systemImage: "gamecontroller.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.pink)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // Button to start a new game
                    Button {
                        showSettings = true
                    } label: {
                        Text("New Game")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    
                    // Button to show high scores
                    Button {
                        showHighScores = true
                    } label: {
                        Text("High Scores")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 200, height: 60)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                }
                .padding()
            }
            
            // Navigation Links to other views
            .navigationDestination(isPresented: $showSettings) {
                SettingView()
            }
            .navigationDestination(isPresented: $showHighScores) {
                HighScoreView()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
