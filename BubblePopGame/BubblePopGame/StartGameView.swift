//
//  StartGameView.swift
//  BubblePopGame
//
//  Created by Nguyet Nga Nguyen on 15/4/2025.
//

import SwiftUI

struct StartGameView: View {
    // Player's name
    let playerName: String
        
    // Environment to dismiss the view
    // @Environment(\.dismiss) private var dismiss
    
    // Game State variables
    @State private var score = 0
    @State private var timeRemaining: Int
    @State private var bubbles: [Bubble] = []
    @State private var gameActive = false
    @State private var timer: Timer? = nil
    @State private var lastPoppedColor: BubbleColor? = nil
    @State private var consecutiveCount = 0
    @State private var showGameOver = false
    @State private var screenSize: CGSize = .zero
    
    //Game settings
    @ObservedObject private var settings = GameSettings.shared

    // Initialise with default time remining from settings
    init(playerName: String) {
        self.playerName = playerName
        _timeRemaining = State(initialValue: GameSettings.shared.gameTime)
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color
                Color.pink.opacity(0.1).ignoresSafeArea()
                
                // Game elements
                VStack {
                    // Game info header
                    HStack {
                        // Score display
                        VStack(alignment: .leading) {
                            Text("Score")
                                .font(.headline)
                            Text("\(score)")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        // Player name display
                        VStack {
                            Text("Player")
                                .font(.headline)
                            Text(playerName)
                                .font(.title3)
                                .fontWeight(.medium)
                            
                        }
                        
                        Spacer()
                        
                        // Time display
                        VStack(alignment: .trailing) {
                            Text("Time")
                                .font(.headline)
                            Text("\(timeRemaining)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(timeRemaining <= 10 ? .red :.primary)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Game area
                    ZStack {
                        // Draw each bubble
                        ForEach(bubbles) {bubble in
                            Circle()
                                .fill(bubble.color.uiColor)
                                .frame(width: bubble.radius * 2, height: bubble.radius * 2)
                                .position(bubble.position)
                                .onTapGesture{
                                    popBubble(bubble)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(15)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    self.screenSize = geo.size
                                }
                                .onChange(of: geo.size) { oldSize, newSize in
                                    self.screenSize = newSize
                                }
                        }
                    )
                }
            }
            .task {
                startGame()
            }
            .sheet(isPresented: $showGameOver) {
                HighScoreView()
            }
        }
    }
    // Function to start the game
    private func startGame() {
        // Initialise game state
        score = 0
        timeRemaining = settings.gameTime
        bubbles = []
        lastPoppedColor = nil
        consecutiveCount = 0
        gameActive = true
        
        // Add bubbles to start
        refreshBubbles()
        
        // Start the game timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                refreshBubbles() // Refresh bubbles every second
            } else {
                endGame()
            }
        }
    }

    // Function to end the game
    private func endGame() {
        gameActive = false
        timer?.invalidate()
        timer = nil
        
        // Save the score
        ScoreManager.shared.addScore(playerName: playerName, score: score)
        
        // Show game over screen
        showGameOver = true
    }
    
    // Refresh bubbles on the screen
    private func refreshBubbles() {
        guard gameActive else { return }
        
        // Remove random number of existing bubbles (not all, to make game more playable)
        let removeCount = Int.random(in: 0...max(1, bubbles.count / 2))
        if removeCount > 0 && !bubbles.isEmpty {
            bubbles.removeFirst(min(removeCount, bubbles.count))
        }
        
        // Calculate how many new bubbles to add
        let currentCount = bubbles.count
        let maxAllowed = settings.maxBubbles
        let remainingSlots = maxAllowed - currentCount
        
        // Only add new bubbles if there is room
        if remainingSlots > 0 {
            // Add random number of new bubbles up to available slots
            let addCount = Int.random(in: 1...remainingSlots)
            
            // Create and add new bubbles
            for _ in 0..<addCount {
                if let newBubble = createRandomBubble() {
                    bubbles.append(newBubble)
                }
            }
        }
    }
    
    // Create a random bubble that doesn't overlap with existing ones
    private func createRandomBubble() -> Bubble? {
        // Don't create bubbles if screen size is unknown
        guard screenSize.width > 0, screenSize.height > 0 else { return nil }
        
        // Bubble size
        let radius = CGFloat.random(in: 25...30)
        
        // Set border margins to ensure bubbles are fully on screen
        let safeAreaX = screenSize.width - radius * 2
        let safeAreaY = screenSize.height - radius * 2
        
        // Find a non-overlapping position (max 10 attemps)
        for _ in 0..<10 {
            // Random position within screen
            let randomX = radius + CGFloat.random(in: 0...safeAreaX)
            let randomY = radius + CGFloat.random(in: 0...safeAreaY)
            let position = CGPoint(x: randomX, y: randomY)
            
            // Check if this position overlaps with any existing bubble
            if !isOverlapping(position: position, radius: radius) {
                // Create new bubble with random color
                return Bubble(
                    position: position,
                    color: BubbleColor.randomColor(),
                    radius: radius
                    )
            }
        }
        
        // If we couldn't find a non-overlapping position after max attemps
        return nil
    }
    
    // Function to check if a position would overlap with existing bubbles
    private func isOverlapping(position: CGPoint, radius: CGFloat) -> Bool {
        for bubble in bubbles {
            let distance = sqrt(
                pow(bubble.position.x - position.x, 2) +
                pow(bubble.position.y - position.y, 2)
            )
            
            // If centers are closer than the sum of radius, they overlap
            if distance < (bubble.radius + radius) {
                return true
            }
        }
        return false
    }
    
    // Function to handle bubble pop
    private func popBubble(_ bubble: Bubble) {
        // Find the bubble in our array
        guard let index = bubbles.firstIndex(where: { $0.id == bubble.id}) else { return }
        
        // Calculate points
        var points = bubble.points
        
        // Check for consecutive same color bonus
        if let lastColor = lastPoppedColor, lastColor == bubble.color {
            // 1.5x points for consecutive same color
            consecutiveCount += 1
            points = Int(Double(points) * 1.5)
        } else {
            // Reset consecutive counter for new color
            consecutiveCount = 0
            lastPoppedColor = bubble.color
        }
        
        // Update score
        score += points
        
        // Remove the bubble
        bubbles.remove(at: index)
    }
}

#Preview {
    StartGameView(playerName: "Player")
}
