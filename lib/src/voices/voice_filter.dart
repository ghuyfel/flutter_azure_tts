import 'package:flutter_azure_tts/src/voices/voices.dart';

/// Utility class for filtering voices using a fluent, chainable API.
/// 
/// This class provides an intuitive way to filter and search through voice collections
/// using method chaining. It supports filtering by various criteria such as locale,
/// gender, capabilities, and text search, making it easy to find the perfect voice
/// for specific use cases.
/// 
/// ## Features
/// 
/// - **Fluent Interface**: Chainable methods for readable filtering logic
/// - **Multiple Criteria**: Filter by locale, gender, voice type, capabilities
/// - **Text Search**: Search voice names and descriptions
/// - **Capability Filtering**: Find voices with specific styles or roles
/// - **Immutable Operations**: Each filter operation returns a new filter instance
/// 
/// ## Usage Patterns
/// 
/// ```dart
/// // Find English neural voices with emotional styles
/// final emotionalVoices = voices.filter()
///     .byLocale('en-')
///     .neural()
///     .withStyles()
///     .results;
/// 
/// // Find a specific voice for customer service
/// final serviceVoice = voices.filter()
///     .byLocale('en-US')
///     .byGender('Female')
///     .withStyle(VoiceStyle.customerservice)
///     .first;
/// 
/// // Search for voices by name
/// final jennyVoices = voices.filter()
///     .search('jenny')
///     .results;
/// ```
/// 
/// ## Performance
/// 
/// Filtering operations are performed in-memory and are generally fast.
/// For large voice collections, consider caching filtered results if
/// the same filters are applied repeatedly.
class VoiceFilter {
  /// Creates a new voice filter with the given voice collection.
  /// 
  /// ## Parameters
  /// 
  /// - [_voices]: The collection of voices to filter. This list is not modified.
  VoiceFilter(this._voices);
  
  /// The current collection of voices being filtered.
  /// 
  /// This list represents the current state of filtering and is updated
  /// with each filter operation. The original voice list is never modified.
  final List<Voice> _voices;

  /// Filters voices by locale (language and region).
  /// 
  /// This method filters voices based on their locale identifier. You can
  /// provide a full locale (e.g., 'en-US') or a partial locale (e.g., 'en-')
  /// to match all variants of a language.
  /// 
  /// ## Parameters
  /// 
  /// - [locale]: The locale to filter by. Can be partial (e.g., 'en-', 'fr-').
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] containing only voices matching the locale.
  /// 
  /// ## Examples
  /// 
  /// ```dart
  /// // All English voices
  /// final englishVoices = voices.filter().byLocale('en-');
  /// 
  /// // Specific US English voices
  /// final usVoices = voices.filter().byLocale('en-US');
  /// 
  /// // All French voices
  /// final frenchVoices = voices.filter().byLocale('fr-');
  /// ```
  VoiceFilter byLocale(String locale) {
    return VoiceFilter(
      _voices.where((voice) => voice.locale.startsWith(locale)).toList(),
    );
  }

  /// Filters voices by gender.
  /// 
  /// This method filters voices based on the gender of the voice character.
  /// The comparison is case-insensitive.
  /// 
  /// ## Parameters
  /// 
  /// - [gender]: The gender to filter by ('Male', 'Female', etc.). Case-insensitive.
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] containing only voices of the specified gender.
  /// 
  /// ## Examples
  /// 
  /// ```dart
  /// // Female voices only
  /// final femaleVoices = voices.filter().byGender('Female');
  /// 
  /// // Male voices only
  /// final maleVoices = voices.filter().byGender('male'); // Case-insensitive
  /// ```
  VoiceFilter byGender(String gender) {
    return VoiceFilter(
      _voices.where((voice) => voice.gender.toLowerCase() == gender.toLowerCase()).toList(),
    );
  }

  /// Filters to include only voices that support styles.
  /// 
  /// This method filters out voices that don't have any expressive styles,
  /// leaving only voices that can speak with different emotions or tones.
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] containing only voices with style support.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Find voices that can express emotions
  /// final expressiveVoices = voices.filter()
  ///     .byLocale('en-US')
  ///     .withStyles();
  /// ```
  VoiceFilter withStyles() {
    return VoiceFilter(
      _voices.where((voice) => voice.styles.isNotEmpty).toList(),
    );
  }

  /// Filters to include only voices that support roles.
  /// 
  /// This method filters out voices that don't support role-playing,
  /// leaving only voices that can imitate different age groups or characters.
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] containing only voices with role support.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Find voices that can play different roles
  /// final rolePlayingVoices = voices.filter()
  ///     .byLocale('en-')
  ///     .withRoles();
  /// ```
  VoiceFilter withRoles() {
    return VoiceFilter(
      _voices.where((voice) => voice.roles.isNotEmpty).toList(),
    );
  }

  /// Filters voices that support a specific style.
  /// 
  /// This method finds voices that can speak with a particular emotional
  /// style or tone, such as cheerful, sad, or professional.
  /// 
  /// ## Parameters
  /// 
  /// - [style]: The specific style that voices must support.
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] containing only voices that support the specified style.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Find voices that can speak cheerfully
  /// final cheerfulVoices = voices.filter()
  ///     .byLocale('en-US')
  ///     .withStyle(VoiceStyle.cheerful);
  /// 
  /// // Find voices for customer service
  /// final serviceVoices = voices.filter()
  ///     .withStyle(VoiceStyle.customerservice);
  /// ```
  VoiceFilter withStyle(VoiceStyle style) {
    return VoiceFilter(
      _voices.where((voice) => voice.styles.contains(style)).toList(),
    );
  }

  /// Filters voices that support a specific role.
  /// 
  /// This method finds voices that can imitate a particular character
  /// or age group, such as young adult or senior.
  /// 
  /// ## Parameters
  /// 
  /// - [role]: The specific role that voices must support.
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] containing only voices that support the specified role.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Find voices that can sound like a young adult
  /// final youngVoices = voices.filter()
  ///     .byGender('Female')
  ///     .withRole(VoiceRole.YoungAdultFemale);
  /// 
  /// // Find voices for elderly characters
  /// final seniorVoices = voices.filter()
  ///     .withRole(VoiceRole.SeniorMale);
  /// ```
  VoiceFilter withRole(VoiceRole role) {
    return VoiceFilter(
      _voices.where((voice) => voice.roles.contains(role)).toList(),
    );
  }

  /// Filters to include only neural voices.
  /// 
  /// Neural voices use advanced AI technology to produce more natural-sounding
  /// speech compared to standard voices. They typically support more features
  /// like styles and roles.
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] containing only neural voices.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Find high-quality neural voices
  /// final neuralVoices = voices.filter()
  ///     .byLocale('en-US')
  ///     .neural();
  /// ```
  VoiceFilter neural() {
    return VoiceFilter(
      _voices.where((voice) => voice.voiceType.toLowerCase() == 'neural').toList(),
    );
  }

  /// Searches voices by name or description.
  /// 
  /// This method performs a case-insensitive text search across voice names,
  /// display names, and local names. It's useful for finding specific voices
  /// when you know part of their name.
  /// 
  /// ## Parameters
  /// 
  /// - [query]: The search term. Case-insensitive.
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] containing only voices matching the search query.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Find all Jenny voices
  /// final jennyVoices = voices.filter().search('jenny');
  /// 
  /// // Find voices with 'neural' in the name
  /// final neuralNamedVoices = voices.filter().search('neural');
  /// 
  /// // Case-insensitive search
  /// final ariaVoices = voices.filter().search('ARIA');
  /// ```
  VoiceFilter search(String query) {
    final lowerQuery = query.toLowerCase();
    return VoiceFilter(
      _voices.where((voice) => 
        voice.displayName.toLowerCase().contains(lowerQuery) ||
        voice.shortName.toLowerCase().contains(lowerQuery) ||
        voice.localName.toLowerCase().contains(lowerQuery)
      ).toList(),
    );
  }

  /// Gets the filtered results as an immutable list.
  /// 
  /// This property returns the current filtered voice collection as an
  /// unmodifiable list, ensuring that the results cannot be accidentally
  /// modified after filtering.
  /// 
  /// ## Returns
  /// 
  /// An immutable list of voices matching all applied filters.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final filteredVoices = voices.filter()
  ///     .byLocale('en-US')
  ///     .neural()
  ///     .withStyles()
  ///     .results;
  /// 
  /// print('Found ${filteredVoices.length} voices');
  /// for (final voice in filteredVoices) {
  ///   print('- ${voice.displayName}');
  /// }
  /// ```
  List<Voice> get results => List.unmodifiable(_voices);
  
  /// Gets the first voice from the filtered results, or null if empty.
  /// 
  /// This is a convenience method for getting a single voice when you
  /// expect the filter to return at least one result but want to handle
  /// the case where no voices match gracefully.
  /// 
  /// ## Returns
  /// 
  /// The first voice in the filtered results, or `null` if no voices match.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final preferredVoice = voices.filter()
  ///     .byLocale('en-US')
  ///     .byGender('Female')
  ///     .withStyle(VoiceStyle.cheerful)
  ///     .first;
  /// 
  /// if (preferredVoice != null) {
  ///   print('Using voice: ${preferredVoice.displayName}');
  /// } else {
  ///   print('No matching voice found');
  /// }
  /// ```
  Voice? get first => _voices.isEmpty ? null : _voices.first;
  
  /// Gets the first voice from the filtered results, throwing if empty.
  /// 
  /// This method is useful when you expect the filter to always return
  /// at least one result and want to fail fast if no voices match.
  /// 
  /// ## Returns
  /// 
  /// The first voice in the filtered results.
  /// 
  /// ## Throws
  /// 
  /// - [StateError]: If no voices match the filter criteria.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// try {
  ///   final voice = voices.filter()
  ///       .byLocale('en-US')
  ///       .neural()
  ///       .firstOrThrow;
  ///   
  ///   print('Selected voice: ${voice.displayName}');
  /// } on StateError {
  ///   print('No English neural voices available');
  /// }
  /// ```
  Voice get firstOrThrow {
    if (_voices.isEmpty) {
      throw StateError('No voices found matching the filter criteria');
    }
    return _voices.first;
  }

  /// Gets the number of voices in the filtered results.
  /// 
  /// ## Returns
  /// 
  /// The count of voices matching all applied filters.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final count = voices.filter()
  ///     .byLocale('en-')
  ///     .withStyles()
  ///     .length;
  /// 
  /// print('Found $count English voices with style support');
  /// ```
  int get length => _voices.length;
  
  /// Checks if the filtered results are empty.
  /// 
  /// ## Returns
  /// 
  /// `true` if no voices match the filter criteria, `false` otherwise.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final hasGermanVoices = !voices.filter()
  ///     .byLocale('de-')
  ///     .isEmpty;
  /// 
  /// if (hasGermanVoices) {
  ///   print('German voices are available');
  /// }
  /// ```
  bool get isEmpty => _voices.isEmpty;
  
  /// Checks if the filtered results contain any voices.
  /// 
  /// ## Returns
  /// 
  /// `true` if at least one voice matches the filter criteria, `false` otherwise.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// if (voices.filter().byLocale('ja-').isNotEmpty) {
  ///   print('Japanese voices are available');
  /// }
  /// ```
  bool get isNotEmpty => _voices.isNotEmpty;

  /// Creates a random sample of voices from the filtered results.
  /// 
  /// This method is useful for testing or when you want to provide
  /// variety in voice selection.
  /// 
  /// ## Parameters
  /// 
  /// - [count]: Maximum number of voices to return. If the filtered results
  ///   contain fewer voices, all will be returned.
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] containing a random sample of the filtered voices.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Get 3 random English voices for variety
  /// final randomVoices = voices.filter()
  ///     .byLocale('en-')
  ///     .sample(3)
  ///     .results;
  /// ```
  VoiceFilter sample(int count) {
    if (count >= _voices.length) {
      return VoiceFilter(List.from(_voices));
    }
    
    final shuffled = List<Voice>.from(_voices)..shuffle();
    return VoiceFilter(shuffled.take(count).toList());
  }

  @override
  String toString() {
    return 'VoiceFilter(${_voices.length} voices)';
  }
}

/// Extension methods for [List<Voice>] to provide easy access to filtering.
/// 
/// This extension adds the [filter] method to any list of voices, making
/// it easy to start filtering operations without explicitly creating a
/// [VoiceFilter] instance.
/// 
/// ## Example
/// 
/// ```dart
/// final voices = await FlutterAzureTts.getAvailableVoices();
/// 
/// // Extension method provides direct access to filtering
/// final englishVoices = voices.voices.filter()
///     .byLocale('en-')
///     .results;
/// ```
extension VoiceListExtensions on List<Voice> {
  /// Creates a new [VoiceFilter] for this voice list.
  /// 
  /// This is the entry point for all filtering operations on voice lists.
  /// 
  /// ## Returns
  /// 
  /// A new [VoiceFilter] instance initialized with this voice list.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final voiceList = <Voice>[...];
  /// 
  /// final filtered = voiceList.filter()
  ///     .byLocale('en-US')
  ///     .neural()
  ///     .withStyles();
  /// ```
  VoiceFilter filter() => VoiceFilter(this);
}