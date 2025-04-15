//
//  GameModel.swift
//  BubblePopGame
//
//  Created by Nguyet Nga Nguyen on 15/4/2025.
//

import SwiftUI

// Model for game settings with default values
class GameSettings: ObservableObject {
    // Public properties will triger UI updates when changed
    @Published var gameTime: Int = 60 // default game time is 60 seconds
    @Published var maxBubbles: Int = 15 // default maximum number of bubbles
    
    // Singleton instance for global access
    static let shared = GameSettings()
    
    private init() {
        // Load saved settings if availables
        loadSettings()
    }
    
    // Save settings to UserDefaults
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(gameTime, forKey: "gameTime")
        defaults.set(maxBubbles, forKey: "maxBubbles")
    }
    
    // Load settings from UserDefaults
    func loadSettings(){
        let defaults = UserDefaults.standard
        // Load saved values of not available
        gameTime = defaults.integer(forKey: "gameTime")
        maxBubbles = defaults.integer(forKey: "maxBubbles")
        
        // If values are 0 (not set), use default values
        if gameTime <= 0 {
            gameTime = 60
        }
        
        if maxBubbles <= 0 {
            maxBubbles = 15
        }
    }
}


// Bubble model to define bubble properties
struct Bubble: Identifiable {
    let id = UUID() // Unique identifier for each bubble
    var position: CGPoint // Position  on screen
    var color: BubbleColor // Color of the bubble
    var radius: CGFloat // Size of the bubble
    
    // Calculate points based on color
    var points: Int {
        return color.points
    }
}

// Enum to define bubble colors with their properties
enum BubbleColor: CaseIterable {
    case red, pink, green, blue, black
    
    // Points awarded for each color
    var points: Int {
        switch self {
        case .red: return 1
        case .pink: return 2
        case .green: return 5
        case .blue: return 8
        case .black: return 10
        }
    }
    
    // Probability of appearance for each color
    static func randomColor() -> BubbleColor {
        // Random number between 0 and 100
        let random = Int.random(in: 0...100)
        
        // Choose color based on probability distribution from requirements
        switch random {
        case 0..<40: return .red // 40% chance
        case 40..<70: return .pink // 30% chance
        case 70..<85: return .green // 15% chance
        case 85..<95: return .blue // 10% chance
        default: return .black // 5% chance
        }
    }
    
    // SwiftUI Color for each bubble color
    var uiColor: Color {
        switch self {
        case .red: return .red
        case .pink: return .pink
        case .green: return .green
        case .blue: return .blue
        case .black: return .black
        }
    }
}

// Model to manage score data
struct Score: Identifiable, Codable, Comparable {
    var id = UUID()
    let playerName: String
    let score: Int
    let date: Date
    
    // Implement Comparable protocol to sort scores
    static func < (lhs: Score, rhs: Score) -> Bool {
        return lhs.score > rhs.score // Higher scores come first
    }
}

// Class to manage score data
class ScoreManager {
    static let shared = ScoreManager()
    
    private let scoresKey = "highScores"
    private var scores: [Score] = []
    
    private init() {
        loadScores()
    }
    
    // Add a new score
    func addScore(playerName: String, score: Int) {
        let newScore = Score(playerName: playerName, score: score, date: Date())
        scores.append(newScore)
        // scores.sorted() // sort in descending order
        
        // Keep only top 10 scores
        if scores.count > 10 {
            scores = Array(scores.prefix(10))
        }
        
        saveScores()
        
    }
    
    // Load scores from UserDefaults
    func loadScores() {
        if let data = UserDefaults.standard.data(forKey: scoresKey),
           let decodedScores = try? JSONDecoder().decode([Score].self, from: data) { scores = decodedScores.sorted()
        }
    }
    
    // Save score to UserDefaults
    private func saveScores() {
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: scoresKey)
        }
    }
    
    
    // Get all scores
    func getAllScores() -> [Score] {
        return scores.sorted()
    }
    
    // Get highest score
    func getHighestScore() -> Score? {
        return scores.first
    }
}
