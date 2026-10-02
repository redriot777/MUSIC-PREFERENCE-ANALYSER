# ==========================================
# MusicMind - Data Cleaning & Transformation
# ==========================================

suppressPackageStartupMessages({
  library(dplyr)
  library(scales)
})

clean_and_transform_data <- function(df) {
  if (nrow(df) == 0) return(df)
  
  df <- df %>%
    mutate(
      song_name = trimws(song_name),
      artist = trimws(artist),
      album_or_movie = trimws(album_or_movie),
      mood = trimws(mood),
      genre = trimws(genre)
    )
  
  # Fill NAs in numerical columns
  num_cols <- c("energy", "danceability", "romantic_score", "sadness_score", "happiness_score", "popularity", "tempo")
  for (col in num_cols) {
    if (col %in% colnames(df)) {
      df[[col]][is.na(df[[col]])] <- median(df[[col]], na.rm = TRUE)
    }
  }
  
  return(df)
}

# Scale numerical feature vectors to [0, 1] range for similarity calculations
normalize_feature_matrix <- function(df) {
  feature_cols <- c("energy", "danceability", "romantic_score", "sadness_score", "happiness_score", "tempo")
  
  mat <- df[, feature_cols]
  mat_scaled <- apply(mat, 2, function(x) {
    min_x <- min(x, na.rm = TRUE)
    max_x <- max(x, na.rm = TRUE)
    if (max_x == min_x) return(rep(0.5, length(x)))
    return((x - min_x) / (max_x - min_x))
  })
  
  rownames(mat_scaled) <- df$song_id
  return(mat_scaled)
}

# Calculate Dataset Summary KPIs
get_dataset_summary <- function(df) {
  list(
    total_songs = nrow(df),
    total_artists = length(unique(df$artist)),
    most_common_mood = names(which.max(table(df$mood))),
    avg_popularity = round(mean(df$popularity, na.rm = TRUE), 1),
    avg_energy = round(mean(df$energy, na.rm = TRUE), 1),
    earliest_year = min(df$release_year, na.rm = TRUE),
    latest_year = max(df$release_year, na.rm = TRUE)
  )
}
