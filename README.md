# ParentingAssistant

A comprehensive iOS app designed to help parents manage their daily responsibilities and create meaningful moments with their children.
![appstore](https://github.com/user-attachments/assets/2c320783-533c-40fa-83c0-3ff49602efb5)


## Features

### Core Features

- **🍽️ Meal Planning**

  - Generate AI-powered meal plans
  - Store and manage recipes
  - Track dietary preferences and restrictions
  - Automatic grocery list generation

- **📚 Bedtime Stories**

  - AI-generated personalized stories
  - Multiple themes (Adventure, Fantasy, Space, etc.)
  - Age-appropriate content
  - Text-to-speech reading
  - Save favorite stories

- **✅ Kids' Routines (Beta)**

  - Create and manage daily routines
  - Track completion
  - Reward system
  - Customizable schedules

- **🏠 Household Chores (Beta)**
  - Family task management
  - Chore assignments
  - Progress tracking
  - Reward system

### Additional Features (Beta)

- **👨‍👩‍👧‍👦 Kids' Activities**: Fun & educational activity suggestions
- **🛒 Running Errands**: Smart shopping & scheduling
- **❤️ Emotional Support**: Help children manage emotions
- **📊 Health & Growth**: Track development milestones
- **📅 Family Scheduler**: Organize family events & tasks
- **⚖️ Work-Life Balance**: Focus & self-care tools
- **😴 Sleep Support**: Track & improve sleep patterns
- **✈️ Travel Prep**: Plan trips & family outings

## Technical Features

- SwiftUI-based modern UI
- Firebase integration for data storage
- OpenAI integration for story generation
- Real-time updates
- Cross-device sync
- Local data persistence
- Voice synthesis for story reading

## Requirements

- iOS 15.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later
- Firebase account
- OpenAI API key

## Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/ParentingAssistant.git
```

2. Install dependencies:

```bash
cd ParentingAssistant
# Add your dependency management commands here
```

3. Configure API Keys:

   - Create a `Config.xcconfig` file
   - Add your API keys:
     ```
     OPENAI_API_KEY=your_api_key_here
     FIREBASE_API_KEY=your_firebase_key_here
     ```

4. Open `ParentingAssistant.xcodeproj` in Xcode

5. Build and run the project

## Architecture

- MVVM Architecture
- Service-oriented design
- Clean separation of concerns
- Reactive programming with Combine

### Key Components

- **Views**: SwiftUI views for UI
- **Services**: Business logic and API integration
- **Models**: Data models and state management
- **Utilities**: Helper functions and extensions

## Services

- **AuthenticationService**: User authentication and management
- **MealPlanningService**: Meal plan generation and management
- **StoryService**: Story generation and management
- **OpenAIService**: AI integration for content generation
- **FirestoreService**: Data persistence and sync

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenAI for AI capabilities
- Firebase for backend services
- The SwiftUI community for inspiration and support

## Contact

Your Name - [@yourtwitter](https://twitter.com/yourtwitter)
Project Link: [https://github.com/yourusername/ParentingAssistant](https://github.com/yourusername/ParentingAssistant)

---

Made with ❤️ for parents everywhere
