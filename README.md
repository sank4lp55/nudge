# Nudge - Real-Time Chat Application

A modern, feature-rich chat application built with Flutter demonstrating Clean Architecture, BLoC state management, and real-time messaging capabilities.

## Features

- **User Authentication** - Secure login with session management
- **Real-Time Messaging** - Instant message delivery with stream-based updates
- **Chat List** - Overview of all conversations with unread badges
- **Typing Indicators** - Live typing status updates
- **Online Status** - Real-time user presence indicators
- **Modern UI/UX** - Clean design with smooth animations
- **Message History** - Complete conversation persistence
- **Auto-Reply System** - Simulated conversation responses (demo)

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **BLoC** - State management pattern
- **GetIt** - Dependency injection
- **Clean Architecture** - Scalable code structure

## Architecture
```
lib/
├── core/           # DI, theme, utilities
├── data/           # Repositories, data sources
├── domain/         # Entities, repository interfaces
└── presentation/   # UI, widgets, BLoC
```

### Clean Architecture Layers

- **Presentation Layer** - UI components, BLoC, screens
- **Domain Layer** - Business entities and repository contracts
- **Data Layer** - Repository implementations and API services
- **Core Layer** - Dependency injection and shared resources

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0+)
- Dart SDK (3.0.0+)
- Android Studio / VS Code

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/nudge.git
cd nudge
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the application
```bash
flutter run
```

### Build

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Project Structure
```
lib/
├── core/
│   ├── di/                      # Dependency injection
│   └── theme/                   # App theme
├── data/
│   ├── datasources/
│   │   ├── local/              # Local storage
│   │   └── remote/             # Mock API service
│   └── repositories/           # Repository implementations
├── domain/
│   ├── entities/               # Business models
│   └── repositories/           # Repository interfaces
└── presentation/
    ├── bloc/                   # State management
    │   ├── auth/              # Authentication BLoC
    │   └── chat/              # Chat BLoCs
    ├── screens/               # App screens
    └── widgets/               # Reusable components
```

## State Management

The app uses **BLoC pattern** with two separate BLoCs for better state isolation:

- **AuthBloc** - Manages authentication state
- **ChatListBloc** - Manages chat list (singleton)
- **ChatBloc** - Manages individual chats (factory)

## Key Features Implementation

### Real-Time Updates
- Stream-based message delivery
- Live typing indicators
- Automatic chat list updates

### Clean Architecture
- Separation of concerns
- Testable business logic
- Platform-independent domain layer

### Modern UI/UX
- Gradient effects and animations
- Hero transitions
- Loading and error states
- Pull-to-refresh

## Screenshots

[Add your app screenshots here]

## API Integration

Currently uses a mock API service that simulates:
- User authentication
- Message fetching
- Message sending
- Real-time updates
- Typing indicators

To integrate with a real backend, update the repository implementations in `/data/repositories/`.

## Testing

The architecture supports easy testing:
```bash
flutter test
```

## Code Quality

- Clean Architecture principles
- SOLID principles
- Dependency injection
- Separation of concerns
- Reusable components

## Future Enhancements

- [ ] Message search
- [ ] Group chats
- [ ] Media sharing
- [ ] Voice messages
- [ ] Read receipts
- [ ] Push notifications
- [ ] End-to-end encryption

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your Profile](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com

## Acknowledgments

- Built as a demonstration project for chat application requirements
- Implements industry best practices and modern Flutter patterns
- Showcases Clean Architecture and advanced state management

---

**Note:** This is a demonstration project using mock data. For production use, integrate with a real backend API and implement proper security measures.