# Flutter ChatGPT Client

A production-ready Flutter application demonstrating modern mobile development practices with real-time AI chat capabilities.

![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter) ![Riverpod](https://img.shields.io/badge/Riverpod-2.x-50C878?logo=dart) ![LangChain](https://img.shields.io/badge/LangChain-Dart-2e7d32) ![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)

---

## 🎯 Overview

A modern ChatGPT client built with Flutter, showcasing professional software architecture and best practices. The app features real-time streaming responses, clean code organization, and a polished user experience with dark mode support.

---

## ✨ Key Features

- **Real-time Streaming Responses**  
  Live AI responses using LangChain's streaming API with incremental UI updates as tokens arrive

- **Modern State Management**  
  Riverpod for compile-time safe, testable state management with ChangeNotifier pattern

- **Clean Architecture**  
  Layered architecture with clear separation: Presentation → Business Logic → Data layers

- **Rich User Experience**  
  - Dark/Light theme with persistence
  - Markdown rendering for AI responses
  - Chat history persistence
  - Message editing and deletion
  - Chat export functionality
  - Copy-to-clipboard support

- **Image Generation**  
  Support for AI image generation with `/image` command

- **Error Handling**  
  Centralized error handling with user-friendly messages

- **Cross-Platform**  
  Runs on iOS, Android, Web, and Desktop

---

## 🏗️ Architecture

The app follows a **layered architecture** pattern:

```
lib/
├── core/              # Shared utilities, services, constants
├── model/             # Data models and business logic (ChangeNotifier)
├── repository/        # Data layer - API communication (LangChain)
├── services/          # Business services (storage, etc.)
├── screens/           # UI screens
└── widgets/           # Reusable UI components
```

### Design Patterns Used

- **Repository Pattern**: Abstracts API calls from business logic
- **Service Pattern**: Reusable business services
- **Observer Pattern**: ChangeNotifier for state updates
- **Provider Pattern**: Riverpod for dependency injection

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI Framework** | Flutter 3.19+ |
| **State Management** | Riverpod 2.x |
| **LLM Integration** | LangChain, LangChain OpenAI |
| **Storage** | shared_preferences, flutter_secure_storage |
| **UI Components** | Material Design 3, flutter_markdown |
| **Networking** | http package |
| **Code Quality** | Very Good Analysis, Flutter Lints |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.19 or higher
- Dart SDK 2.18.2 or higher
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flutter-chatgpt-client.git
   cd flutter-chatgpt-client
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   endpoint=https://api.openai.com/v1
   model=gpt-4o-mini-2024-07-18
   imageModel=gpt-image-1
   aiToken=your-openai-api-key
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📱 Screenshots

![Chat Screen](./flutter-chatgpt.png)

---

## 🎓 Learning Outcomes

This project demonstrates:

- ✅ **State Management**: Advanced Riverpod patterns with ChangeNotifier
- ✅ **Architecture**: Clean architecture with separation of concerns
- ✅ **Async Programming**: Stream handling and real-time updates
- ✅ **Error Handling**: Centralized error management
- ✅ **UI/UX**: Material Design 3, theming, responsive layouts
- ✅ **Data Persistence**: Local storage with shared_preferences
- ✅ **API Integration**: RESTful API communication with streaming
- ✅ **Code Quality**: Linting, analysis, and best practices

---

## 📝 Code Quality

- Follows Flutter and Dart style guidelines
- Uses Very Good Analysis for linting
- Implements SOLID principles
- Comprehensive error handling
- Well-documented code with dartdoc comments

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License.

---

## 👤 Author

Built as a portfolio project to demonstrate Flutter development skills and best practices.

---

## 🙏 Acknowledgments

- OpenAI for the API
- LangChain for the Dart SDK
- Flutter team for the amazing framework
- Riverpod for excellent state management

