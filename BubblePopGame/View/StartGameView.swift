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
    @State private var highestScore: Int = 0
    @State private var poppedBubbles: [Bubble] = [] // Track popped bubbles for animation
    @State private var scoreIndicators: [ScoreIndicator] = [] // Track score indicators

    
    // Countdown variables
    @State private var showCountdown = true
    @State private var countdownValue = 3
    @State private var countdownScale = 1.0
    
    // Animation variables
    @State private var animationTimer: Timer? = nil
    
    //Game settings
    @ObservedObject private var settings = GameSettings.shared

    // Initialise with default time remaining from settings
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
                        
                        // High score display
                        VStack {
                            Text("Highest Score")
                                .font(.headline)
                            Text("\(highestScore)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
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
                                .scaleEffect(bubble.scale)
                                .opacity(bubble.opacity)
                                .onAppear {
                                    // Entrance animation
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        // Find and update the scale of this bubble
                                        if let index = bubbles.firstIndex(where: { $0.id == bubble.id }) {
                                            bubbles[index].scale = 1.0
                                        }
                                    }
                                }
                                .onTapGesture{
                                    popBubble(bubble)
                                }
                        }
                        // Popped bubbles (for exit animations)
                        ForEach(poppedBubbles) { bubble in
                            Circle()
                                .fill(bubble.color.uiColor)
                                .frame(width: bubble.radius * 2, height: bubble.radius * 2)
                                .position(bubble.position)
                                .scaleEffect(bubble.scale)
                                .opacity(bubble.opacity)
                        }
                        
                        // Score indicators
                        ForEach(scoreIndicators) { indicator in
                            Text("+\(indicator.points)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 1, y: 1)
                                .position(
                                    x: indicator.position.x,
                                    y: indicator.position.y - indicator.offset
                                )
                                .opacity(indicator.opacity)
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
                    .clipped() // Clip bubbles that go beyond the game area
                }
                
                // Countdown overlay
                if showCountdown {
                    ZStack {
                        // Background color
                        Color.black.opacity(0.6).ignoresSafeArea()
                        
                        // Countdown number or "START"
                        if countdownValue > 0 {
                            Text("\(countdownValue)")
                                .font(.system(size: 120, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(countdownScale)
                                .animation(.easeInOut(duration: 0.5), value: countdownScale)
                        } else {
                            Text("START!")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(countdownScale)
                                .animation(.easeInOut(duration: 0.3), value: countdownScale)
                        }
                    }
                }
            }
            .task {
                loadHighestScore()
                startCountdown()
            }
            .navigationDestination(isPresented: $showGameOver) {
                HighScoreView()
            }
        }
    }
    
    // Function to load highest score
    private func loadHighestScore() {
        if let topScore = ScoreManager.shared.getHighestScore() {
            highestScore = topScore.score
        } else {
            highestScore = 0
        }
    }
    
    // Function to handle the countdown sequence
    private func startCountdown() {
        showCountdown = true
        countdownValue = 3
        
        // Create a timer for the countdown animation
        let countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // Flash animation effect
            withAnimation {
                countdownScale = 1.5
            }
            
            // Reset scale after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                countdownScale = 1.0
            }
            
            if countdownValue > 0 {
                countdownValue -= 1
            } else {
                // End countdown and start game
                timer.invalidate()
                
                // Small delay before removing overlay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    showCountdown = false
                    startGame()
                }
            }
        }
        
        // Start the timer immediately
        countdownTimer.fire()
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
        
        // Start animation timer for moving bubbles
        startAnimationTimer()
    }
    
    // Function to start animation timer to move bubbles
    private func startAnimationTimer() {
        // Use a faster timer for smooth animations
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateBubblePositions()
        }
    }
    
    // Function to calculate bubble movement speed based on time remaining
    private func getBubbleSpeed() -> CGFloat {
        // Base speed
        let baseSpeed: CGFloat = 1.0
        
        // Calculate speed multiplier based on time remaining
        // Speed increases as time decreases
        let maxTime = CGFloat(settings.gameTime)
        let remaining = CGFloat(timeRemaining)
        
        // Exponential speed increase formula:
        // - At full time (beginning): speed = baseSpeed
        // - At half time: speed ≈ 2 * baseSpeed
        // - At quarter time: speed ≈ 4 * baseSpeed
        // - Near end: speed up to 8 * baseSpeed
        
        let speedMultiplier = pow(2, (maxTime - remaining) / (maxTime / 3))
        
        // Limit the maximum speed
        return min(baseSpeed * speedMultiplier, baseSpeed * 8)
    }
    
    // Update bubble positions for animation
    private func updateBubblePositions() {
        guard gameActive, !bubbles.isEmpty else { return }
        
        let speed = getBubbleSpeed()
        
        // Create a new array with updated positions
        var updatedBubbles: [Bubble] = []
        
        for bubble in bubbles {
            // Create a copy of the bubble to modify
            var updatedBubble = bubble
            
            // Move the bubble upward
            updatedBubble.position.y -= speed
            
            // Check if bubble is touching any border of the safe area
            let touchingLeftBorder = updatedBubble.position.x - updatedBubble.radius <= 0
            let touchingRightBorder = updatedBubble.position.x + updatedBubble.radius >= screenSize.width
            let touchingTopBorder = updatedBubble.position.y - updatedBubble.radius <= 0
            let touchingBottomBorder = updatedBubble.position.y + updatedBubble.radius >= screenSize.height
            
            let isTouchingBorder = touchingLeftBorder || touchingRightBorder || touchingTopBorder || touchingBottomBorder
            
            // Only keep bubbles that are not touching any border
            if !isTouchingBorder {
                updatedBubbles.append(updatedBubble)
            }
        }
        
        // Update the bubbles array
        bubbles = updatedBubbles
        
        // Update score indicators - move them upward and fade them out
        var updatedIndicators: [ScoreIndicator] = []
        
        for indicator in scoreIndicators {
            var updatedIndicator = indicator
            updatedIndicator.offset += 1.5  // Move upward
            updatedIndicator.opacity -= 0.02  // Fade out
            
            // Keep only visible indicators
            if updatedIndicator.opacity > 0 {
                updatedIndicators.append(updatedIndicator)
            }
        }
        
        // Update the score indicators array
        scoreIndicators = updatedIndicators
    }
    
    // Function to end the game
    private func endGame() {
        gameActive = false
        timer?.invalidate()
        timer = nil
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Save the score
        ScoreManager.shared.addScore(playerName: playerName, score: score)
        
        // Show high score screen
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
                    radius: radius,
                    scale: 0.0
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
        
        // Create a score indicator
        let indicator = ScoreIndicator(
            position: CGPoint(x: bubble.position.x, y: bubble.position.y - bubble.radius - 10),
            points: points
        )
        scoreIndicators.append(indicator)
        
        // Create a copy of the bubble for the popping animation
        var poppedBubble = bubble
        poppedBubble.isPopping = true
        poppedBubbles.append(poppedBubble)
        
        // Remove the original bubble immediately
        bubbles.remove(at: index)
        
        // Animate the popped bubble shrinking
        withAnimation(.easeOut(duration: 0.2)) {
            if let poppedIndex = poppedBubbles.firstIndex(where: { $0.id == bubble.id }) {
                poppedBubbles[poppedIndex].scale = 1.3  // First expand slightly
            }
        }
        
        // Then shrink and fade
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.15)) {
                if let poppedIndex = poppedBubbles.firstIndex(where: { $0.id == bubble.id }) {
                    poppedBubbles[poppedIndex].scale = 0.0
                    poppedBubbles[poppedIndex].opacity = 0.0
                }
            }
            
            // Remove the popped bubble from our array after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                poppedBubbles.removeAll(where: { $0.id == bubble.id })
            }
        }
    }
}

#Preview {
    StartGameView(playerName: "Player")
}
