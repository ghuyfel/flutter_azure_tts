enum VoiceStyle {
  ///Expresses an excited and high-energy tone for promoting a product or service.
  advertisement_upbeat,

  ///Expresses a warm and affectionate tone, with higher pitch and vocal energy.
  ///The speaker is in a state of attracting the attention of the listener.
  ///The personality of the speaker is often endearing in nature.
  affectionate,

  ///Expresses a warm and relaxed tone for digital assistants.
  assistant,

  ///Expresses a cool, collected, and composed attitude when speaking. Tone, pitch,
  ///and prosody are more uniform compared to other types of speech.
  calm,

  ///Expresses a casual and relaxed tone.
  chat,

  ///Expresses a positive and happy tone.
  cheerful,

  ///Expresses a friendly and helpful tone for customer support.
  customerservice,

  ///Expresses a melancholic and despondent tone with lower pitch and energy.
  depressed,

  ///Expresses a disdainful and complaining tone. Speech of this emotion displays displeasure and contempt.
  disgruntled,

  ///Narrates documentaries in a relaxed, interested, and informative style suitable
  ///for documentaries, expert commentary, and similar content.
  documentary_narration,

  ///Expresses an uncertain and hesitant tone when the speaker is feeling uncomfortable.
  embarrassed,

  ///Expresses a sense of caring and understanding.
  empathetic,

  ///Expresses a tone of admiration when you desire something that someone else has.
  envious,

  ///Expresses an upbeat and hopeful tone. It sounds like something great is happening and the speaker is happy about it.
  excited,

  ///Expresses a scared and nervous tone, with higher pitch, higher vocal energy,
  ///and faster rate. The speaker is in a state of tension and unease.
  fearful,

  ///Expresses a pleasant, inviting, and warm tone. It sounds sincere and caring.
  friendly,

  ///Expresses a mild, polite, and pleasant tone, with lower pitch and vocal energy.
  gentle,

  ///Expresses a warm and yearning tone. It sounds like something good will happen to the speaker.
  hopeful,

  ///Expresses emotions in a melodic and sentimental way.
  lyrical,

  ///Expresses a professional, objective tone for content reading.
  narration_professional,

  ///Expresses a soothing and melodious tone for content reading.
  narration_relaxed,

  ///Expresses a formal and professional tone for narrating news.
  newscast,

  ///Expresses a versatile and casual tone for general news delivery.
  newscast_casual,

  ///Expresses a formal, confident, and authoritative tone for news delivery.
  newscast_formal,

  ///Expresses an emotional and rhythmic tone while reading a poem.
  poetry_reading,

  ///Expresses a sorrowful tone.
  sad,

  ///	Expresses a strict and commanding tone. Speaker often sounds stiffer and much less relaxed with firm cadence.
  serious,

  ///Expresses a tone that sounds as if the voice is distant or in another location and making an effort to be clearly heard.
  shouting,

  ///Expresses a relaxed and interested tone for broadcasting a sports event.
  sports_commentary,

  ///Expresses an intensive and energetic tone for broadcasting exciting moments in a sports event.
  sports_commentary_excited,

  ///Expresses a soft tone that's trying to make a quiet and gentle sound.
  whispering,

  ///Expresses a scared tone, with a faster pace and a shakier voice. It sounds like the speaker is in an unsteady and frantic status.
  terrified,

  ///Expresses a cold and indifferent tone.
  unfriendly;

  String get styleName {
    switch (this) {
      case VoiceStyle.documentary_narration:
      case VoiceStyle.narration_professional:
      case VoiceStyle.narration_relaxed:
      case VoiceStyle.newscast_casual:
      case VoiceStyle.newscast_formal:
      case VoiceStyle.poetry_reading:
        return this.name.replaceAll("_", "-");
      case VoiceStyle.advertisement_upbeat:
      case VoiceStyle.affectionate:
      case VoiceStyle.assistant:
      case VoiceStyle.calm:
      case VoiceStyle.chat:
      case VoiceStyle.cheerful:
      case VoiceStyle.customerservice:
      case VoiceStyle.depressed:
      case VoiceStyle.disgruntled:
      case VoiceStyle.embarrassed:
      case VoiceStyle.empathetic:
      case VoiceStyle.envious:
      case VoiceStyle.excited:
      case VoiceStyle.fearful:
      case VoiceStyle.friendly:
      case VoiceStyle.gentle:
      case VoiceStyle.hopeful:
      case VoiceStyle.lyrical:
      case VoiceStyle.newscast:
      case VoiceStyle.sad:
      case VoiceStyle.serious:
      case VoiceStyle.shouting:
      case VoiceStyle.sports_commentary:
      case VoiceStyle.sports_commentary_excited:
      case VoiceStyle.whispering:
      case VoiceStyle.terrified:
      case VoiceStyle.unfriendly:
        return this.name;
    }
  }
}
