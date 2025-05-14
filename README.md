# BubblePopGame

An iOS game where players pop colorful bubbles to earn points within a time limit.

This project uses SwiftUI with MVVM architecture.

---

## Features

- Pop colorful bubbles to earn points based on bubble color
- Configurable game settings (time limit, maximum bubbles)
- High score tracking and leaderboard
- Randomized bubble appearance with varying point values
- Responsive gameplay for different device sizes

---

## Game Elements

### Bubbles
Different colored bubbles with varying point values and appearance probabilities:
- Red: 1 point (40% chance)
- Pink: 2 points (30% chance)
- Green: 5 points (15% chance)
- Blue: 8 points (10% chance)
- Black: 10 points (5% chance)

### Game Settings
- Configurable game duration (default: 60 seconds)
- Adjustable maximum bubbles on screen (default: 15)
- Settings persistence between app launches

### Scoring System
- Points awarded based on bubble color
- High score tracking with player names
- Leaderboard showing top 10 scores

---

## Data Models

### Bubble
Represents a single bubble in the game.
- id (UUID)
- position (CGPoint)
- color (BubbleColor)
- radius (CGFloat)
- points (calculated from color)

### BubbleColor
Enum defining bubble colors and their properties.
- red, pink, green, blue, black
- points value for each color
- appearance probability distribution
- UI color representation

### Score
Stores player score information.
- playerName
- score
- date

---

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture:

### Models
- Pure data structures (Bubble, BubbleColor, Score)

### ViewModels
- GameSettings: Manages game configuration
- ScoreManager: Handles score tracking and persistence

### Views (UI Layer)
- Game screens
- Settings interface
- Leaderboard display

---

## Technologies

- Swift
- SwiftUI
- UserDefaults for data persistence
- MVVM architecture

---

## Getting Started

1. Clone the repository
```bash
git clone https://github.com/YourUsername/BubblePopGame.git
```

2. Open `BubblePopGame.xcodeproj` in Xcode.

3. Run the app on an iOS Simulator or a real iPhone.

---

## Contributors

- Nguyet Nga Nguyen (Irene) (Developer)

---

## University Project Statement

This repository was created as part of an assignment for a course at UTS.

All contributors have reviewed and agreed to publicly share this project under the MIT License for educational and non-commercial purposes. This project remains the intellectual property of the contributing team members.

---

## License

This project is licensed under the MIT License.

---

## Future Roadmap

- [ ] Add difficulty levels
- [ ] Implement power-ups and special bubbles
- [ ] Add sound effects and background music
- [ ] Create multiplayer mode
- [ ] Add animations and visual effects
- [ ] Support iPad and landscape orientations
- [ ] Implement Game Center integration
