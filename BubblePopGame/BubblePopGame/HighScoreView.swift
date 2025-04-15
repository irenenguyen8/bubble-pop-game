//
//  HighScoreView.swift
//  BubblePopGame
//
//  Created by Nguyet Nga Nguyen on 15/4/2025.
//

import SwiftUI

struct HighScoreView: View {
    // State variable to go back to Main menu
    @State private var mainMenu = false
    
    // State to refresh scores if needed
    @State private var scores = ScoreManager.shared.getAllScores()
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.1).ignoresSafeArea()
            
            VStack {
                Label("High Scores", systemImage: "chart.bar.xaxis")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.pink)
                    .padding(.top, 25)
                
                // If there is no scores yet
                if scores.isEmpty {
                    VStack {
                        Text("No high scores yet!")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                        
                        Text("Play a game to set a high score!")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                    .padding()
                } else {
                    // Display score list
                    List {
                        ForEach(0..<scores.count, id: \.self) { index in
                            HStack{
                                // Rank with medal for top 3
                                if index < 3 {
                                    Image(systemName: ["1.circle.fill", "2.circle.fill", "3.circle.fill"][index])
                                        .foregroundColor([.yellow, .gray, .brown][index])
                                        .font(.title2)
                                        .frame(width: 40)
                                } else {
                                    Text("\(index + 1).")
                                        .font(.title3)
                                        .frame(width: 40)
                                }
                                
                                // Player name
                                Text(scores[index].playerName)
                                    .font(.title3)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                // Score value
                                Text("\(scores[index].score)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                    .padding()
                }
                
                Spacer()
                
                Button(action: {
                    mainMenu = true
                }) {
                    Text("Main Menu")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .task {
            // Refresh scores when view appears
            scores = ScoreManager.shared.getAllScores()
        }
        .navigationDestination(isPresented: $mainMenu) {
            ContentView()
        }
        .navigationBarHidden(true)

    }
}
    
#Preview {
    HighScoreView()
}
