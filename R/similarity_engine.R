# ==========================================
# MusicMind - Song Similarity Engine
# ==========================================

suppressPackageStartupMessages({
  library(dplyr)
})

# Cosine similarity between two vectors
cosine_similarity <- function(v1, v2) {
  sum(v1 * v2) / (sqrt(sum(v1^2)) * sqrt(sum(v2^2)))
}

# Euclidean distance similarity score [0, 1]
euclidean_similarity <- function(v1, v2) {
  dist_val <- sqrt(sum((v1 - v2)^2))
  return(1 / (1 + dist_val))
}

# Find top N similar songs for a target song_id
find_similar_songs <- function(df, target_song_id, top_n = 5, method = "cosine") {
  if (nrow(df) == 0 || !(target_song_id %in% df$song_id)) {
    return(data.frame())
  }
  
  feature_cols <- c("energy", "danceability", "romantic_score", "sadness_score", "happiness_score", "tempo")
  
  # Min-Max normalize features for fair vector distance
  df_normalized <- df
  for (col in feature_cols) {
    min_v <- min(df[[col]], na.rm = TRUE)
    max_v <- max(df[[col]], na.rm = TRUE)
    if (max_v != min_v) {
      df_normalized[[col]] <- (df[[col]] - min_v) / (max_v - min_v)
    } else {
      df_normalized[[col]] <- 0.5
    }
  }
  
  target_idx <- which(df_normalized$song_id == target_song_id)
  target_vec <- as.numeric(df_normalized[target_idx, feature_cols])
  
  similarities <- numeric(nrow(df_normalized))
  
  for (i in seq_len(nrow(df_normalized))) {
    vec_i <- as.numeric(df_normalized[i, feature_cols])
    if (method == "cosine") {
      similarities[i] <- cosine_similarity(target_vec, vec_i)
    } else {
      similarities[i] <- euclidean_similarity(target_vec, vec_i)
    }
  }
  
  res_df <- df
  res_df$similarity_score <- round(similarities * 100, 1)
  
  # Filter out target song itself and sort by similarity score descending
  similar_songs <- res_df %>%
    filter(song_id != target_song_id) %>%
    arrange(desc(similarity_score)) %>%
    head(top_n)
  
  return(similar_songs)
}
