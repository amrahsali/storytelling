<img width="1440" alt="Screenshot 2025-05-03 at 12 35 52" src="https://github.com/user-attachments/assets/9c8c36e1-ce8b-4b38-9b71-83c6272b0cf1" />

# Story Teller App


A Flutter application that uses Google's Gemini AI to generate creative stories in Pidgin English based on uploaded images. This project demonstrates integration with AI APIs, file handling, and deployment to the web.

🌟 Features

- Select images from your device
- Generate unique stories based on image content
- Entertaining Pidgin English narrative style
- Cross-platform compatibility (web, Android, iOS)
- Responsive UI design

 📱 Live Demo

Try out the app: [https://amrahsali-storyteller-2025.web.app](https://amrahsali-storyteller-2025.web.app)

## 🛠️ Technologies

- **Flutter** - UI framework
- **Gemini AI** - Image analysis and story generation
- **Firebase** - Web hosting
- **file_picker** - Image selection
- **flutter_gemini** - Gemini API integration
- **http** - API communication
- **lottie** - Loading animations

## 📋 Prerequisites

- Flutter SDK (3.19+)
- Dart SDK (3.3+)
- Google Gemini API key
- Firebase account (for deployment)
- Node.js & npm (for Firebase CLI)

## 🚀 Getting Started

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/[your-username]/storyteller.git
   cd storyteller
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create a `.env` file in the project root (or update the `ai_service.dart` file directly):
   ```
   GEMINI_API_KEY=your_api_key_here
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Deployment

1. Build for web:
   ```bash
   flutter build web --release
   ```

2. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

3. Initialize Firebase:
   ```bash
   firebase login
   firebase init
   ```
   - Select Hosting
   - Choose public directory: build/web
   - Configure as single-page app: Yes

4. Deploy:
   ```bash
   firebase deploy --only hosting
   ```

### Updating the deployed app

1. Make your changes
2. Rebuild:
   ```bash
   flutter build web --release
   ```
3. Redeploy:
   ```bash
   firebase deploy --only hosting
   ```

## 📁 Project Structure

```
lib/
├── main.dart           # App entry point
├── screens/            # App screens
│   └── story_home_page.dart
├── services/           # API services
│   └── ai_service.dart
└── widgets/            # Reusable UI components
    └── loading_animation.dart
```

## 🧩 Core Components

### AiService

Manages communication with the Gemini API for story generation:

```dart
class AiService {
  final gemini = Gemini.instance;
  
  // Initialize with API key
  AiService._internal() {
    Gemini.init(apiKey: 'YOUR_API_KEY');
  }
  
  // Generate story from image
  Future<String> generateStoryFromImage(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    
    final result = await gemini.textAndImage(
      text: "Write a short funny story in Pidgin English about this image.",
      images: [base64Image],
    );
    
    return result?.output?.toString() ?? "Story generation failed";
  }
}
```

### Image Picking

```dart
Future<void> pickImage() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  
  if (result != null && result.files.isNotEmpty) {
    setState(() {
      _imageBytes = result.files.first.bytes;
    });

    await generateStory();
  }
}
```

## ✨ Customization

### Changing the Story Style

Edit the prompt in `ai_service.dart`:

```dart
// For different languages or styles:
text: "Write a short sci-fi story about this image.",
// or
text: "Create a poem based on this image.",
```

### UI Customization

Modify the theme in `main.dart`:

```dart
theme: ThemeData(
  primarySwatch: Colors.purple, // Change color scheme
  fontFamily: 'Roboto',         // Change font
  useMaterial3: true,           // Use Material 3
),
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request


## 🙏 Acknowledgements

- [Google Gemini AI Platform](https://ai.google.dev/)
- [Flutter Framework](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)

## 📬 Contact

Amrah uthman sali -saliamrah300@gmail.com

Project Link: [https://github.com/[your-username]/storyteller](https://github.com/[your-username]/storyteller)
