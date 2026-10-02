# ==========================================
# MusicMind - Visual Analytics Engine
# ==========================================

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(plotly)
  library(scales)
})

# Custom Dark Luxury Theme for Plotly & GGPlot
DARK_THEME_PAPER <- "#12151e"
DARK_THEME_BG    <- "#0c0e14"
COLOR_PRIMARY    <- "#8b5cf6" # Violet / Purple
COLOR_SECONDARY  <- "#ec4899" # Pink
COLOR_CYAN       <- "#06b6d4" # Cyan
COLOR_GOLD       <- "#f59e0b" # Gold
COLOR_GREEN      <- "#10b981" # Emerald

ARTIST_COLORS <- c(
  "Anirudh Ravichander" = "#8b5cf6",
  "Hiphop Tamizha"     = "#ec4899",
  "Sai Abhyankkar"      = "#06b6d4",
  "G. V. Prakash Kumar" = "#f59e0b"
)

# 1. Timeline Scatter Chart (Release Year vs Popularity)
plot_music_timeline <- function(df) {
  if (nrow(df) == 0) return(NULL)
  
  fig <- plot_ly(
    data = df,
    x = ~release_year,
    y = ~popularity,
    color = ~artist,
    colors = ARTIST_COLORS,
    size = ~energy,
    sizes = c(12, 32),
    type = 'scatter',
    mode = 'markers',
    text = ~paste(
      "<b>Track:</b>", song_name, "<br>",
      "<b>Artist:</b>", artist, "<br>",
      "<b>Movie/Album:</b>", album_or_movie, "<br>",
      "<b>Year:</b>", release_year, "<br>",
      "<b>Mood:</b>", mood, "<br>",
      "<b>Energy:</b>", energy, "%<br>",
      "<b>Popularity:</b>", popularity
    ),
    hoverinfo = 'text',
    marker = list(opacity = 0.85, line = list(color = '#ffffff', width = 1.5))
  ) %>%
    layout(
      paper_bgcolor = DARK_THEME_PAPER,
      plot_bgcolor  = DARK_THEME_PAPER,
      font = list(color = '#e2e8f0', family = 'Plus Jakarta Sans, sans-serif'),
      title = list(text = "<b>Tamil Music Evolution Timeline (2006 - 2024)</b>", font = list(size = 16, color = '#ffffff')),
      xaxis = list(
        title = "Release Year", 
        gridcolor = '#222736', 
        zerolinecolor = '#222736',
        dtick = 2
      ),
      yaxis = list(
        title = "Popularity Index (0 - 100)", 
        gridcolor = '#222736', 
        zerolinecolor = '#222736',
        range = c(50, 102)
      ),
      legend = list(orientation = 'h', y = -0.2, x = 0.1),
      margin = list(t = 50, b = 60, l = 50, r = 30)
    )
  
  return(fig)
}

# 2. Mood Distribution Donut Chart
plot_mood_distribution <- function(df) {
  if (nrow(df) == 0) return(NULL)
  
  mood_counts <- df %>%
    group_by(mood) %>%
    summarise(count = n(), .groups = 'drop')
  
  fig <- plot_ly(
    mood_counts, 
    labels = ~mood, 
    values = ~count, 
    type = 'pie',
    hole = 0.6,
    textposition = 'inside',
    textinfo = 'label+percent',
    insidetextfont = list(color = '#FFFFFF'),
    hoverinfo = 'text',
    text = ~paste("<b>Mood:</b>", mood, "<br><b>Tracks:</b>", count),
    marker = list(
      colors = c("#8b5cf6", "#ec4899", "#06b6d4", "#f59e0b", "#10b981", "#3b82f6", "#a855f7", "#ef4444"),
      line = list(color = '#12151e', width = 2)
    )
  ) %>%
    layout(
      paper_bgcolor = DARK_THEME_PAPER,
      plot_bgcolor  = DARK_THEME_PAPER,
      font = list(color = '#e2e8f0', family = 'Plus Jakarta Sans, sans-serif'),
      title = list(text = "<b>Track Breakdown by Primary Mood</b>", font = list(size = 15, color = '#ffffff')),
      showlegend = TRUE,
      legend = list(orientation = 'v', x = 1.05, y = 0.5),
      margin = list(t = 40, b = 20, l = 20, r = 100)
    )
  
  return(fig)
}

# 3. Artist Comparison Radar / Bar Chart
plot_artist_comparison <- function(df) {
  if (nrow(df) == 0) return(NULL)
  
  artist_stats <- df %>%
    group_by(artist) %>%
    summarise(
      Energy = mean(energy, na.rm = TRUE),
      Danceability = mean(danceability, na.rm = TRUE),
      Romance = mean(romantic_score, na.rm = TRUE),
      Sadness = mean(sadness_score, na.rm = TRUE),
      Happiness = mean(happiness_score, na.rm = TRUE),
      Popularity = mean(popularity, na.rm = TRUE),
      .groups = 'drop'
    )
  
  fig <- plot_ly(type = 'scatterpolar', fill = 'toself')
  
  metrics <- c("Energy", "Danceability", "Romance", "Sadness", "Happiness", "Popularity")
  
  for (i in seq_len(nrow(artist_stats))) {
    art_name <- artist_stats$artist[i]
    art_col <- ARTIST_COLORS[art_name]
    vals <- as.numeric(artist_stats[i, metrics])
    vals <- c(vals, vals[1]) # close polygon
    
    fig <- fig %>% add_trace(
      r = vals,
      theta = c(metrics, metrics[1]),
      name = art_name,
      line = list(color = art_col, width = 2.5),
      fillcolor = paste0(art_col, "33")
    )
  }
  
  fig <- fig %>% layout(
    paper_bgcolor = DARK_THEME_PAPER,
    plot_bgcolor  = DARK_THEME_PAPER,
    font = list(color = '#e2e8f0', family = 'Plus Jakarta Sans, sans-serif'),
    title = list(text = "<b>Artist Music Profile Radar Comparison</b>", font = list(size = 15, color = '#ffffff')),
    polar = list(
      bgcolor = DARK_THEME_PAPER,
      radialaxis = list(visible = TRUE, range = c(0, 100), color = '#64748b', gridcolor = '#222736'),
      angularaxis = list(color = '#e2e8f0', gridcolor = '#222736')
    ),
    legend = list(orientation = 'h', y = -0.15),
    margin = list(t = 50, b = 60, l = 40, r = 40)
  )
  
  return(fig)
}

# 4. Single Song Radar Feature Profile
plot_song_radar <- function(song_row) {
  if (nrow(song_row) == 0) return(NULL)
  
  metrics <- c("Energy", "Danceability", "Romance", "Sadness", "Happiness")
  vals <- c(song_row$energy, song_row$danceability, song_row$romantic_score, song_row$sadness_score, song_row$happiness_score)
  vals <- c(vals, vals[1])
  
  fig <- plot_ly(
    type = 'scatterpolar',
    fill = 'toself',
    r = vals,
    theta = c(metrics, metrics[1]),
    name = song_row$song_name,
    line = list(color = '#8b5cf6', width = 3),
    fillcolor = 'rgba(139, 92, 246, 0.35)'
  ) %>%
    layout(
      paper_bgcolor = DARK_THEME_PAPER,
      plot_bgcolor  = DARK_THEME_PAPER,
      font = list(color = '#e2e8f0', family = 'Plus Jakarta Sans, sans-serif'),
      title = list(text = paste0("<b>Audio Profile: ", song_row$song_name, "</b>"), font = list(size = 14, color = '#ffffff')),
      polar = list(
        bgcolor = DARK_THEME_PAPER,
        radialaxis = list(visible = TRUE, range = c(0, 100), color = '#64748b', gridcolor = '#222736'),
        angularaxis = list(color = '#e2e8f0', gridcolor = '#222736')
      ),
      margin = list(t = 40, b = 20, l = 30, r = 30)
    )
  
  return(fig)
}

# 5. Energy vs Popularity Scatter Plot
plot_energy_vs_popularity <- function(df) {
  if (nrow(df) == 0) return(NULL)
  
  fig <- plot_ly(
    data = df,
    x = ~energy,
    y = ~popularity,
    color = ~mood,
    text = ~paste("<b>Track:</b>", song_name, "<br><b>Artist:</b>", artist, "<br><b>Mood:</b>", mood),
    hoverinfo = 'text',
    type = 'scatter',
    mode = 'markers',
    marker = list(size = 14, opacity = 0.85, line = list(color = '#ffffff', width = 1))
  ) %>%
    layout(
      paper_bgcolor = DARK_THEME_PAPER,
      plot_bgcolor  = DARK_THEME_PAPER,
      font = list(color = '#e2e8f0', family = 'Plus Jakarta Sans, sans-serif'),
      title = list(text = "<b>Energy Level vs Popularity Index</b>", font = list(size = 15, color = '#ffffff')),
      xaxis = list(title = "Energy Level (0 - 100)", gridcolor = '#222736', zerolinecolor = '#222736'),
      yaxis = list(title = "Popularity Score (0 - 100)", gridcolor = '#222736', zerolinecolor = '#222736'),
      legend = list(orientation = 'h', y = -0.2),
      margin = list(t = 40, b = 60, l = 50, r = 30)
    )
  
  return(fig)
}

# 6. Genre Distribution Horizontal Bar Chart
plot_genre_distribution <- function(df) {
  if (nrow(df) == 0) return(NULL)
  
  genre_counts <- df %>%
    group_by(genre) %>%
    summarise(count = n(), .groups = 'drop') %>%
    arrange(count)
  
  fig <- plot_ly(
    genre_counts,
    x = ~count,
    y = ~reorder(genre, count),
    type = 'bar',
    orientation = 'h',
    marker = list(
      color = '#06b6d4',
      line = list(color = '#ffffff', width = 1)
    ),
    text = ~count,
    textposition = 'auto',
    insidetextfont = list(color = '#ffffff')
  ) %>%
    layout(
      paper_bgcolor = DARK_THEME_PAPER,
      plot_bgcolor  = DARK_THEME_PAPER,
      font = list(color = '#e2e8f0', family = 'Plus Jakarta Sans, sans-serif'),
      title = list(text = "<b>Songs by Music Genre</b>", font = list(size = 15, color = '#ffffff')),
      xaxis = list(title = "Number of Tracks", gridcolor = '#222736', zerolinecolor = '#222736'),
      yaxis = list(title = "", gridcolor = '#222736'),
      margin = list(t = 40, b = 40, l = 140, r = 30)
    )
  
  return(fig)
}
