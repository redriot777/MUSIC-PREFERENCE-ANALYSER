# ==========================================
# MusicMind - Data Loader Module
# ==========================================

suppressPackageStartupMessages({
  library(dplyr)
})

load_music_data <- function(filepath = "data/tamil_music.csv") {
  if (!file.exists(filepath)) {
    warning(paste("Dataset file not found at:", filepath, "- Returning fallback mock dataset."))
    return(create_fallback_dataset())
  }
  
  df <- tryCatch({
    read.csv(filepath, stringsAsFactors = FALSE, check.names = FALSE)
  }, error = function(e) {
    warning(paste("Error reading dataset:", e$message))
    return(create_fallback_dataset())
  })
  
  # Ensure expected columns exist
  required_cols <- c("song_id", "song_name", "artist", "album_or_movie", 
                     "release_year", "genre", "language", "mood", 
                     "energy", "danceability", "romantic_score", 
                     "sadness_score", "happiness_score", "popularity", 
                     "tempo", "duration", "album_cover")
  
  missing <- setdiff(required_cols, colnames(df))
  if (length(missing) > 0) {
    warning(paste("Missing columns in dataset:", paste(missing, collapse = ", ")))
    for (col in missing) {
      if (col %in% c("energy", "danceability", "romantic_score", "sadness_score", "happiness_score", "popularity", "tempo")) {
        df[[col]] <- 50
      } else {
        df[[col]] <- "N/A"
      }
    }
  }
  
  # Convert numerical types strictly
  df <- df %>%
    mutate(
      release_year = as.integer(release_year),
      energy = as.numeric(energy),
      danceability = as.numeric(danceability),
      romantic_score = as.numeric(romantic_score),
      sadness_score = as.numeric(sadness_score),
      happiness_score = as.numeric(happiness_score),
      popularity = as.numeric(popularity),
      tempo = as.numeric(tempo)
    )
  
  # Filter strictly to the 4 primary target artists
  valid_artists <- c("Anirudh Ravichander", "Hiphop Tamizha", "Sai Abhyankkar", "G. V. Prakash Kumar")
  df <- df %>% filter(artist %in% valid_artists)
  
  return(df)
}

create_fallback_dataset <- function() {
  data.frame(
    song_id = "AR001",
    song_name = "Hukum - Thalaivar Alappara",
    artist = "Anirudh Ravichander",
    album_or_movie = "Jailer",
    release_year = 2023,
    genre = "EDM / Kuthu",
    language = "Tamil",
    mood = "Energetic",
    energy = 96,
    danceability = 88,
    romantic_score = 10,
    sadness_score = 5,
    happiness_score = 92,
    popularity = 98,
    tempo = 135,
    duration = "3:26",
    album_cover = "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop",
    stringsAsFactors = FALSE
  )
}
