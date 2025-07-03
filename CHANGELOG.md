## 1.0.0 - Major Architecture Overhaul and Streaming Support

### 🚀 **NEW FEATURES**

#### **Real-time Audio Streaming**
- **Streaming TTS**: Real-time audio streaming for lower latency and better user experience
- **Progress Tracking**: Detailed progress information during streaming (bytes received, throughput, completion percentage)
- **Smart Buffering**: Multiple buffering strategies (low latency, balanced, high quality)
- **Chunk Management**: Configurable chunk sizes for different use cases
- **Stream Optimization**: Pre-configured settings for real-time, high-quality, and balanced scenarios

#### **Advanced Voice Filtering API**
- **Fluent Interface**: Chainable filtering methods for intuitive voice selection
- **Multiple Criteria**: Filter by locale, gender, voice type, styles, and roles
- **Text Search**: Search voices by name with case-insensitive matching
- **Capability Filtering**: Find voices with specific styles or role support
- **Extension Methods**: Direct filtering on voice lists with `.filter()`

#### **Builder Pattern for Parameters**
- **TtsParamsBuilder**: Fluent API for constructing TTS parameters with validation
- **TtsStreamingParamsBuilder**: Specialized builder for streaming parameters
- **Input Validation**: Comprehensive validation with helpful error messages
- **Type Safety**: Compile-time checking of parameter combinations
- **Factory Methods**: Pre-configured builders for common scenarios

#### **Comprehensive Error Handling**
- **Specific Exception Types**: Dedicated exceptions for different error scenarios
  - `InitializationException`: Configuration and setup errors
  - `AuthenticationException`: Authentication and authorization failures
  - `NetworkException`: Network connectivity issues
  - `ValidationException`: Input validation errors
  - `RateLimitException`: API rate limiting with retry information
  - `ServiceUnavailableException`: Azure service availability issues
- **Error Context**: Detailed error messages with cause information
- **Structured Handling**: Type-safe error handling with sealed classes

#### **Advanced Configuration Management**
- **Immutable Configuration**: Thread-safe configuration objects
- **Retry Policies**: Configurable retry logic with exponential backoff and jitter
- **Timeout Control**: Customizable request timeouts
- **Validation**: Comprehensive configuration validation during initialization

#### **Caching System**
- **Audio Caching**: Automatic caching of generated audio with TTL support
- **Voice Caching**: Cached voice lists to reduce API calls
- **Memory Management**: Efficient cache cleanup and size management
- **Custom TTL**: Different cache durations for different content types

#### **Enhanced Documentation**
- **Comprehensive Comments**: Detailed documentation for all classes and methods
- **Usage Examples**: Code examples throughout the documentation
- **API Guidelines**: Clear guidance on best practices and usage patterns
- **Performance Tips**: Optimization recommendations for different scenarios

#### **Type Safety Improvements**
- **Sealed Classes**: Exhaustive pattern matching for error handling
- **Immutable Objects**: Prevent accidental state modification
- **Generic Types**: Type-safe caching and result handling
- **Validation**: Runtime validation with compile-time type checking

### 🚀 **PERFORMANCE IMPROVEMENTS**

#### **Caching**
- **Automatic Audio Caching**: Reduces redundant API calls for repeated content
- **Voice List Caching**: Cached voice metadata for faster access
- **TTL Management**: Automatic cache expiration and cleanup

#### **Connection Management**
- **HTTP Client Optimization**: Better connection pooling and reuse
- **Retry Logic**: Smart retry strategies with exponential backoff
- **Timeout Handling**: Configurable timeouts for different scenarios

#### **Memory Efficiency**
- **Streaming Buffers**: Efficient memory usage for large audio streams
- **Chunk Processing**: Process audio in manageable chunks
- **Cache Management**: Automatic cleanup of expired cache entries

### 🔒 **SECURITY ENHANCEMENTS**

#### **Input Validation**
- **Parameter Validation**: Comprehensive validation of all input parameters
- **Text Length Limits**: Enforce Azure TTS text length restrictions
- **Rate Validation**: Validate speech rate ranges
- **Voice Compatibility**: Check voice support for styles and roles

#### **Authentication**
- **Token Management**: Secure token storage and automatic refresh
- **Error Handling**: Proper handling of authentication failures
- **Configuration Validation**: Validate subscription keys and regions

### 🔄 **BREAKING CHANGES**

#### **Configuration**
- `Config` class replaced with `AzureTtsConfig` and `ConfigManager`
- Enhanced initialization with validation and custom policies

#### **Error Handling**
- Generic `AzureException` replaced with specific exception types
- More detailed error information and context

#### **Internal Structure**
- Reorganized internal modules (no impact on public API)
- Updated import paths for internal development

### 🐛 **BUG FIXES**

- **Authentication**: Fixed token refresh edge cases
- **Error Handling**: Improved error message clarity
- **Memory Leaks**: Fixed potential memory leaks in streaming scenarios
- **Thread Safety**: Resolved race conditions in configuration management

## 0.2.3

* Reverted package's class name

## 0.2.2

* updated dart version
* updated dependencies versions
* added style and role support
* new example file (example.dart) to run/test in terminal (i.e. dart example.dart -h)
* bug fixes and improvements

## 0.1.6

* getAvailableVoices now only returns VoicesSuccess and throws an exception otherwise
* getTts now only returns AudioSuccess and throws an exception otherwise
* VoicesFailedBadRequest now includes more details in the reason field.
* AudioFailedBadRequest now includes more details in the reason field.

## 0.1.5
 
 
## 0.1.4

* Updated Readme file to show prosody rate in example.

## 0.1.3

* Added prosody rate to TtsParams.

## 0.1.2

* Upgraded json_serializable to 5.0.2.
* Upgraded build_runner to 2.1.4.

## 0.1.1

* Fix for bug where could not initialisation throws exception.

## 0.1.0 

* Removed async on initialisation. 
* Added withLogs field when initialising.
* Fixed auth token expiring issue.
* Updated dart docs.

## 0.0.6

* Added toString method to all Azure related exceptions

## 0.0.5

* Added toString method to AzureException

## 0.0.4

* Upgraded build_runner to 2.1.1

## 0.0.3

* Downgraded to json_serializable 4.1.4

## 0.0.2

* Removed flutter dependencies

## 0.0.1

* Get Available voices
* Convert text to speech