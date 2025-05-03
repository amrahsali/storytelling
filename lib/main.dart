import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package

void main() {
  // Initialize Gemini before the app starts
  Gemini.init(apiKey: 'AIzaSyBYM69ch1r2pRGztAUXp1nKCpC7ZG3wX6E');
  runApp(const StoryTellerApp());
}

class StoryTellerApp extends StatelessWidget {
  const StoryTellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Teller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StoryHomePage(),
    );
  }
}

class StoryHomePage extends StatefulWidget {
  const StoryHomePage({super.key});

  @override
  State<StoryHomePage> createState() => _StoryHomePageState();
}

class _StoryHomePageState extends State<StoryHomePage> {
  // Use the already initialized instance
  final gemini = Gemini.instance;
  Uint8List? _imageBytes;
  String? _story;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _imageBytes = result.files.first.bytes;
          _errorMessage = null;
        });

        await generateStory();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to pick image: $e";
      });
    }
  }

  Future<void> generateStory() async {
    if (_imageBytes == null) return;

    setState(() {
      _isLoading = true;
      _story = null;
      _errorMessage = null;
    });

    try {
      // Use Gemini to generate content based on the image
      final response = await gemini.textAndImage(
        text: "Write a funny short story in Pidgin English about what you see in this image. Keep it appropriate for all ages.",
        images: [_imageBytes!],
      );

      // Extract the story text from the response
      if (response != null) {
        final content = response.content;
        if (content != null && content.parts != null && content.parts!.isNotEmpty) {
          // Check if the part is a TextPart and extract the text
          for (var part in content.parts!) {
            if (part is TextPart) {
              setState(() {
                _story = part.text;
              });
              break;
            }
          }

          // If no story was set, the response didn't contain text
          if (_story == null) {
            setState(() {
              _errorMessage = "No text was generated in the response";
            });
          }
        } else {
          setState(() {
            _errorMessage = "Empty response from Gemini";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to get a response from Gemini";
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to generate story: $e";
        _isLoading = false;
      });
      print("Gemini API error: $e"); // Add debug print for more detailed error info
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 4,
        title: const Text(
          'Story Teller',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true, // Optional: centers the title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'This section displays the story generated based on the image you uploaded. '
                      'It uses intelligent analysis to create a unique and engaging narrative just for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use responsive layout based on available width
                  if (constraints.maxWidth < 900) {
                    // Stack panels vertically on smaller screens
                    return Column(
                      children: [
                        _buildUploadSection(),
                        const SizedBox(height: 24),
                        _buildStorySection()
                      ],
                    );
                  } else {
                    // Show panels side by side on wider screens
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildUploadSection()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildStorySection()),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Upload section extracted as a separate widget
  Widget _buildUploadSection() {
    return Container(
      height: 600,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload an Image',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_imageBytes == null) ...[
              // Show Lottie animation when no image is selected
              Center(
                child: Column(
                  children: [
                    Lottie.network(
                      'https://assets5.lottiefiles.com/packages/lf20_urbk83vw.json',
                      height: 250,
                      repeat: true,
                      animate: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Select Image'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload an image to generate a story',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show selected image
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _imageBytes!,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Select New Image'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Story output section extracted as a separate widget
  Widget _buildStorySection() {
    return Container(
      height: 600,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generated Story',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We go give you one sweet story from the picture you upload.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 10),
              const Text('Generating story...'),
            ],
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_story != null && !_isLoading) ...[
              const SizedBox(height: 10),
              Text(
                _story!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : generateStory,
                icon: const Icon(Icons.refresh),
                label: const Text('Generate New Story'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}