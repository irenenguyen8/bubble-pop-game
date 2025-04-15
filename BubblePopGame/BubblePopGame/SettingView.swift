//
//  SettingView.swift
//  BubblePopGame
//
//  Created by Nguyet Nga Nguyen on 15/4/2025.
//

import SwiftUI

struct SettingView: View {
    // State variable to store the player's name
    @State private var playerName = ""
    @State private var gameTime: String = ""
    @State private var maxBubbles: String = ""
    
    // State variable to check if name field is empty when players start game
    @State private var emptyNameAlert = false
    
    // State variable to manage navigation
    @State private var showSettings = false
    
    
    // Environment to dismiss the view if needed
    @Environment(\.dismiss) private var dismiss
    
    // Observed object for game settings
    @ObservedObject private var settings = GameSettings.shared
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.1).ignoresSafeArea()
            
            VStack (spacing: 20){
                Label("Game Settings", systemImage: "gear")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.pink)
                    .padding(.top, 25)
        

                Spacer(minLength: 35)
                
                //Settings form
                Form {
                    Section(header: Text("Enter your name")) {
                        TextField("Player Name", text: $playerName)
                    }
                    
                    Section(header: Text("Game Time")) {
                        HStack {
                            Text("Duration (seconds)")
                            Spacer()
                            Text("\(settings.gameTime)")
                        }
                        
                        //Slicer for game time
                        Slider(
                            value: Binding(
                                get: { Double(settings.gameTime) },
                                set: { settings.gameTime = Int($0)}
                            ),
                            in: 5...60,
                            step: 5
                        )
                    }
                    
                    Section(header: Text("Bubbles")) {
                        HStack {
                            Text("Maximum bubbles")
                            Spacer()
                            Text("\(settings.maxBubbles)")
                        }
                        
                        //Slicer for game time
                        Slider(
                            value: Binding(
                                get: { Double(settings.maxBubbles) },
                                set: { settings.maxBubbles = Int($0)}
                            ),
                            in: 0...15,
                            step: 1
                        )
                    }
                }
                .scrollContentBackground(.hidden)
                
                // Start Game Button
                Button(action: {
                    // Check if name is not empty
                    if playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        emptyNameAlert = true
                    } else {
                        showSettings = true
                    }
                }) {
                    Text("Start Game")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear{
            gameTime = "\(settings.gameTime)"
            maxBubbles = "\(settings.maxBubbles)"
        }
        // Navigation to the Start Game view
        .navigationDestination(isPresented: $showSettings) {
            StartGameView(playerName: playerName)
        }
        
        // Alert for empty name field
        .alert("Name Required", isPresented: $emptyNameAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter your name to start the game.")
        }
    }
}


#Preview {
    SettingView()
}
