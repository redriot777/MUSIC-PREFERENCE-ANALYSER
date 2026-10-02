# ==========================================
# MusicMind - Mood Intelligence Engine
# ==========================================

suppressPackageStartupMessages({
  library(dplyr)
})

# Classify or filter songs by Mood
filter_songs_by_mood <- function(df, target_mood = "All") {
  if (target_mood == "All" || is.null(target_mood) || target_mood == "") {
    return(df)
  }
  df %>% filter(mood == target_mood)
}

# Calculate Mood Average Profiles
get_mood_profiles <- function(df) {
  df %>%
    group_by(mood) %>%
    summarise(
      song_count = n(),
      avg_energy = round(mean(energy, na.rm = TRUE), 1),
      avg_danceability = round(mean(danceability, na.rm = TRUE), 1),
      avg_romance = round(mean(romantic_score, na.rm = TRUE), 1),
      avg_sadness = round(mean(sadness_score, na.rm = TRUE), 1),
      avg_happiness = round(mean(happiness_score, na.rm = TRUE), 1),
      avg_popularity = round(mean(popularity, na.rm = TRUE), 1),
      .groups = "drop"
    )
}

# Analytical explanations for each mood category
get_mood_description <- function(mood_name) {
  descriptions <- list(
    "Energetic" = "High BPM, heavy brass & percussive beats, dominant synth hooks. Tailored for workout, motivational drives, and high-adrenaline moments.",
    "Happy" = "Uplifting major keys, bright acoustic harmonies, rhythmically bouncy arrangement designed to elevate dopamine levels.",
    "Romantic" = "Lush string orchestrations, expressive vocal dynamics, tender lyrical phrasing, and smooth mid-tempo rhythm sections.",
    "Sad" = "Minor scale melodies, acoustic guitar & flute accents, melancholic atmospheric pads with deep emotional resonance.",
    "Chill" = "Lo-fi synth textures, relaxed acoustic strums, sub-100 BPM rhythm, ideal for relaxation and focused study sessions.",
    "Melancholic" = "Complex harmonic dissonance, introspective tempo, ambient reverb spaces with rich string layers.",
    "Party" = "Sub-bass Kuthu rhythm, explosive drop sequences, multi-layered group chorus designed for festival dance floors.",
    "Motivational" = "Triumphant horn sections, driving drum loops, inspiring vocal arrangements designed for perseverance."
  )
  
  if (mood_name %in% names(descriptions)) {
    return(descriptions[[mood_name]])
  } else {
    return("Dynamic musical arrangement derived from artist compositional attributes.")
  }
}
