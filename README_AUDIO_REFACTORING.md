# Audio Folder Refactoring - Structure Documentation

## 🗂️ **New Folder Structure**

The audio folder has been completely refactored into a logical, maintainable structure:

```
lib/src/audio/
├── core/                    # Core audio functionality
│   ├── audio_responses.dart         # Response types and error handling
│   ├── audio_output_format.dart     # Audio format constants and utilities
│   ├── audio_request_param.dart     # Base request parameters
│   ├── audio_type_header.dart       # HTTP headers for audio requests
│   └── audio_response_mapper.dart   # HTTP response mapping
├── streaming/               # Streaming-specific classes
│   ├── audio_stream.dart           # Stream types and progress tracking
│   └── streaming_audio_buffer.dart # Buffer management for streaming
├── client/                  # HTTP clients
│   ├── audio_client.dart           # Standard TTS HTTP client
│   └── audio_stream_client.dart    # Streaming TTS HTTP client
├── handlers/                # Request handlers
│   ├── audio_handler.dart          # Standard TTS request handler
│   └── audio_stream_handler.dart   # Streaming TTS request handler
├── caching/                 # Caching functionality
│   └── audio_cache.dart           # Audio data caching
└── audio.dart              # Main exports file
```

## 📋 **Folder Responsibilities**

### **Core (`/core`)**
Contains fundamental audio functionality that's shared across the library:
- **Response Types**: Success/error response objects
- **Audio Formats**: Constants and utilities for all supported formats
- **Request Parameters**: Base classes for TTS requests
- **HTTP Headers**: Audio-specific HTTP header management
- **Response Mapping**: Converting HTTP responses to typed objects

### **Streaming (`/streaming`)**
Dedicated to real-time audio streaming functionality:
- **Stream Types**: AudioChunk, AudioStreamResponse, StreamProgress
- **Buffer Management**: Smart buffering for smooth playback
- **Progress Tracking**: Real-time streaming progress information

### **Client (`/client`)**
HTTP client implementations for different TTS modes:
- **Standard Client**: Traditional complete-file TTS requests
- **Streaming Client**: Real-time chunked audio streaming
- **Header Management**: Automatic authentication and format headers

### **Handlers (`/handlers`)**
High-level request orchestration and business logic:
- **Standard Handler**: Complete audio file generation
- **Streaming Handler**: Real-time audio streaming with progress
- **Validation**: Parameter validation and error handling
- **SSML Generation**: Converting parameters to Azure SSML format

### **Caching (`/caching`)**
Audio data caching for performance optimization:
- **Memory Management**: Efficient audio data storage
- **TTL Support**: Time-based cache expiration
- **Cache Strategies**: Different caching approaches for various use cases

## 🔄 **Import Updates**

### **Main Export File**
```dart
// lib/src/audio/audio.dart
export 'core/audio_responses.dart';
export 'core/audio_output_format.dart';
export 'streaming/audio_stream.dart';
export 'caching/audio_cache.dart';
```

### **Updated Imports Throughout Codebase**
All imports have been updated to reflect the new structure:

```dart
// Old imports
import 'package:flutter_azure_tts/src/audio/audio_responses.dart';
import 'package:flutter_azure_tts/src/audio/audio_stream.dart';

// New imports
import 'package:flutter_azure_tts/src/audio/core/audio_responses.dart';
import 'package:flutter_azure_tts/src/audio/streaming/audio_stream.dart';
```

## 🎯 **Benefits of New Structure**

### **1. Logical Separation**
- **Core functionality** separated from **specialized features**
- **Standard TTS** clearly separated from **streaming TTS**
- **HTTP clients** separated from **business logic handlers**

### **2. Improved Maintainability**
- Easier to locate specific functionality
- Clear boundaries between different concerns
- Reduced file sizes with focused responsibilities

### **3. Better Scalability**
- Easy to add new audio formats in `/core`
- Simple to extend streaming features in `/streaming`
- Clear place for new caching strategies in `/caching`

### **4. Enhanced Testability**
- Each folder can be tested independently
- Mock implementations easier to create
- Clear interfaces between components

### **5. Developer Experience**
- Intuitive folder names match functionality
- Easier onboarding for new developers
- Clear separation of concerns

## 📁 **File Size Optimization**

All files now maintain reasonable sizes:
- **Core files**: 150-300 lines (focused on single responsibility)
- **Handler files**: 200-400 lines (business logic with validation)
- **Client files**: 100-250 lines (HTTP communication only)
- **Streaming files**: 200-350 lines (streaming-specific logic)

## 🔧 **Migration Guide**

### **For Library Users**
No changes required - all public APIs remain the same:
```dart
// This still works exactly the same
import 'package:flutter_azure_tts/flutter_azure_tts.dart';

final audio = await FlutterAzureTts.getTts(params);
final stream = await FlutterAzureTts.getTtsStream(streamingParams);
```

### **For Library Contributors**
Update imports when working on internal code:
```dart
// Update internal imports to new structure
import 'package:flutter_azure_tts/src/audio/core/audio_responses.dart';
import 'package:flutter_azure_tts/src/audio/handlers/audio_handler.dart';
import 'package:flutter_azure_tts/src/audio/streaming/audio_stream.dart';
```

## 🚀 **Future Extensibility**

The new structure makes it easy to add:

### **New Audio Formats**
Add to `/core/audio_output_format.dart` with proper categorization

### **Advanced Streaming Features**
Extend `/streaming` folder with new streaming capabilities

### **Caching Strategies**
Add new cache implementations in `/caching` folder

### **Protocol Support**
Add new HTTP clients in `/client` for different protocols

### **Request Types**
Extend `/handlers` for new types of TTS requests

This refactoring provides a solid foundation for future growth while maintaining clean, maintainable code structure! 🎉