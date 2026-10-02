# ==========================================
# MusicMind - User Preference Recommendation Engine
# ==========================================

suppressPackageStartupMessages({
  library(dplyr)
})

generate_user_recommendations <- function(df, 
                                          fav_artist = "All", 
                                          pref_mood = "All",
                                          pref_energy = 80,
                                          pref_romance = 50,
                                          pref_happiness = 70,
                                          pref_sadness = 30,
                                          pref_era = "All",
                                          top_n = 6) {
  if (nrow(df) == 0) return(df)
  
  filtered <- df
  
  # Optional hard filter or soft bonus for artist
  if (fav_artist != "All" && !is.null(fav_artist) && fav_artist != "") {
    # Keep artist weight strong in scoring
  }
  
  # Calculate user preference match score for each song
  scores <- sapply(seq_len(nrow(filtered)), function(i) {
    row <- filtered[i, ]
    
    # Feature distance penalty
    e_diff <- abs(row$energy - pref_energy) / 100
    r_diff <- abs(row$romantic_score - pref_romance) / 100
    h_diff <- abs(row$happiness_score - pref_happiness) / 100
    s_diff <- abs(row$sadness_score - pref_sadness) / 100
    
    feature_dist <- (e_diff + r_diff + h_diff + s_diff) / 4
    base_match <- (1 - feature_dist) * 80
    
    # Bonuses
    artist_bonus <- if (fav_artist != "All" && row$artist == fav_artist) 12 else 0
    mood_bonus <- if (pref_mood != "All" && row$mood == pref_mood) 8 else 0
    
    # Era bonus
    era_bonus <- 0
    if (pref_era == "2020s" && row$release_year >= 2020) era_bonus <- 5
    if (pref_era == "2010s" && row$release_year >= 2010 && row$release_year < 2020) era_bonus <- 5
    if (pref_era == "Classics" && row$release_year < 2010) era_bonus <- 5
    
    total_score <- base_match + artist_bonus + mood_bonus + era_bonus
    min(round(total_score, 1), 99.9)
  })
  
  filtered$match_score <- scores
  
  recommended <- filtered %>%
    arrange(desc(match_score)) %>%
    head(top_n)
  
  return(recommended)
}

# Profile Archetype Classifier based on slider values
classify_user_archetype <- function(pref_energy, pref_romance, pref_happiness, pref_sadness) {
  if (pref_energy >= 85 && pref_happiness >= 75) {
    return(list(
      title = "High-Energy Party Pioneer ⚡",
      desc = "You thrive on heavy Kuthu bass, high BPM beats, and electrifying concert anthems. You love tracks by Anirudh and Hiphop Tamizha that get crowd adrenaline pumping!"
    ))
  } else if (pref_romance >= 80) {
    return(list(
      title = "Hopeless Melodic Romanticist 💖",
      desc = "Lush string acoustic melodies, soulful vocals, and warm chord progressions speak to your heart. Sai Abhyankkar and G. V. Prakash melodies are your sweet spot."
    ))
  } else if (pref_sadness >= 65) {
    return(list(
      title = "Introspective Melancholic Soul 🌙",
      desc = "You appreciate the deep artistic beauty in minor keys, emotional ballads, and reflective storytelling. G. V. Prakash and Anirudh's sad melodies echo your vibe."
    ))
  } else if (pref_energy < 60 && pref_happiness >= 60) {
    return(list(
      title = "Chill Sunset Acoustic Listener ☕",
      desc = "You prefer relaxed mid-tempo grooves, lo-fi textures, and easy-listening Tamil acoustic gems for work, coffee sessions, and late night drives."
    ))
  } else {
    return(list(
      title = "Versatile Tamil Cine-Music Connoisseur 🎧",
      desc = "You enjoy a balanced spectrum of Tamil music—from high-energy folk rap to soothing romantic classics and motivational tracks."
    ))
  }
}
