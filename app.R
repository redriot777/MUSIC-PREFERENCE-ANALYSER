# =========================================================
# MusicMind - Tamil Music Intelligence & Discovery System
# Main Shiny Application File
# =========================================================

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(shinyWidgets)
  library(dplyr)
  library(ggplot2)
  library(plotly)
  library(DT)
  library(scales)
  library(htmltools)
})

# Source modular R engines
source("R/data_loader.R")
source("R/data_cleaning.R")
source("R/mood_engine.R")
source("R/similarity_engine.R")
source("R/recommendation_engine.R")
source("R/analytics.R")

# Load & Clean Dataset
raw_dataset <- load_music_data("data/tamil_music.csv")
music_df    <- clean_and_transform_data(raw_dataset)
summary_kpis <- get_dataset_summary(music_df)

# Target Artists
TARGET_ARTISTS <- c("All", "Anirudh Ravichander", "Hiphop Tamizha", "Sai Abhyankkar", "G. V. Prakash Kumar")
ALL_MOODS      <- c("All", "Energetic", "Happy", "Romantic", "Sad", "Chill", "Melancholic", "Party", "Motivational")
ALL_GENRES     <- c("All", unique(music_df$genre))

# Helper: Render Song Card HTML
render_song_card_html <- function(row) {
  mood_class <- paste0("badge-mood-", tolower(row$mood))
  
  tags$div(
    class = "song-card",
    tags$div(
      class = "album-cover-wrapper",
      tags$img(
        src = row$album_cover,
        class = "album-cover-img",
        alt = row$song_name,
        onerror = "handleImgError(this)"
      ),
      tags$button(
        class = "play-overlay-btn",
        `data-song-id` = row$song_id,
        `data-song-name` = row$song_name,
        `data-artist` = row$artist,
        `data-cover` = row$album_cover,
        tags$i(class = "fa fa-play")
      )
    ),
    tags$div(class = "song-title", title = row$song_name, row$song_name),
    tags$div(class = "song-artist", paste(row$artist, "•", row$album_or_movie)),
    tags$div(
      class = "song-meta-bar",
      tags$span(class = paste("badge-pill", mood_class), row$mood),
      tags$span(class = "popularity-tag", tags$i(class = "fa fa-fire"), row$popularity)
    ),
    tags$div(
      style = "margin-top: 10px;",
      actionButton(
        inputId = paste0("view_detail_", row$song_id),
        label = "View Details",
        icon = icon("circle-info"),
        class = "btn btn-sm btn-outline-secondary style-detail-btn",
        onclick = sprintf("Shiny.setInputValue('select_song_detail', '%s', {priority: 'event'})", row$song_id)
      )
    )
  )
}

# =========================================================
# UI DEFINITION
# =========================================================

ui <- fluidPage(
  title = "MusicMind ✦ Tamil Music Intelligence",
  theme = bs_theme(version = 5, bg = "#08090d", fg = "#f8fafc", primary = "#8b5cf6"),
  
  # Custom CSS & FontAwesome CDN & Custom JS
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"),
    tags$link(rel = "stylesheet", href = "style.css"),
    tags$script(src = "script.js")
  ),

  # Top Glass Navbar
  tags$div(
    class = "musicmind-navbar",
    tags$a(
      href = "#",
      class = "brand-title",
      tags$div(class = "brand-icon", tags$i(class = "fa fa-compact-disc")),
      "MusicMind"
    ),
    tags$ul(
      class = "nav nav-pills",
      id = "main_tabs",
      role = "tablist",
      tags$li(class = "active", tags$a(href = "#tab-home", `data-toggle` = "tab", tags$i(class = "fa fa-house"), "Home")),
      tags$li(tags$a(href = "#tab-discover", `data-toggle` = "tab", tags$i(class = "fa fa-compass"), "Discover")),
      tags$li(tags$a(href = "#tab-mood", `data-toggle` = "tab", tags$i(class = "fa fa-face-smile"), "Mood")),
      tags$li(tags$a(href = "#tab-similarity", `data-toggle` = "tab", tags$i(class = "fa fa-sliders"), "Similarity")),
      tags$li(tags$a(href = "#tab-artists", `data-toggle` = "tab", tags$i(class = "fa fa-microphone"), "Artists")),
      tags$li(tags$a(href = "#tab-insights", `data-toggle` = "tab", tags$i(class = "fa fa-chart-pie"), "Insights")),
      tags$li(tags$a(href = "#tab-profile", `data-toggle` = "tab", tags$i(class = "fa fa-user-astronaut"), "Profile"))
    )
  ),

  # Main Tab Contents Container
  tags$div(
    class = "container-fluid style-container",
    style = "padding: 1.5rem 2rem;",
    
    tags$div(
      class = "tab-content",
      
      # ----------------------------------------------------
      # TAB 1: HOME
      # ----------------------------------------------------
      tags$div(
        class = "tab-pane fade in active show",
        id = "tab-home",
        
        # Hero Section
        tags$div(
          class = "hero-card",
          tags$div(
            class = "row align-items-center",
            tags$div(
              class = "col-lg-8",
              tags$span(class = "badge-pill badge-mood-energetic", "TAMIL MUSIC INTELLIGENCE PLATFORM"),
              tags$h1(
                class = "hero-title",
                style = "margin-top: 12px;",
                "Understand your music.", tags$br(),
                tags$span(class = "hero-gradient-text", "Discover your next vibe.")
              ),
              tags$p(
                class = "hero-subtitle",
                "MusicMind leverages R-based feature extraction, vector distance similarity calculations, and analytical audio profiling across Tamil cinema's four defining music visionaries."
              ),
              tags$div(
                style = "display: flex; gap: 12px; margin-top: 1rem;",
                tags$a(
                  href = "#tab-discover",
                  class = "btn-musicmind",
                  onclick = "$('a[href=\"#tab-discover\"]').tab('show')",
                  tags$i(class = "fa fa-play"), "Explore Music Library"
                ),
                tags$a(
                  href = "#tab-similarity",
                  class = "btn btn-outline-light",
                  style = "border-radius: 30px; padding: 10px 24px; font-weight: 600;",
                  onclick = "$('a[href=\"#tab-similarity\"]').tab('show')",
                  tags$i(class = "fa fa-wand-magic-sparkles"), "Vibe Matcher"
                )
              )
            ),
            tags$div(
              class = "col-lg-4 text-center d-none d-lg-block",
              tags$div(
                class = "song-card",
                style = "max-width: 280px; margin: 0 auto;",
                tags$div(
                  class = "album-cover-wrapper",
                  tags$img(src = "https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=600&auto=format&fit=crop", class = "album-cover-img")
                ),
                tags$div(class = "song-title", "Katchi Sera"),
                tags$div(class = "song-artist", "Sai Abhyankkar • 2024"),
                tags$span(class = "badge-pill badge-mood-happy", "FEATURED SPOTLIGHT")
              )
            )
          )
        ),
        
        # KPI Cards Row
        tags$div(
          class = "row g-3",
          style = "margin-bottom: 2rem;",
          tags$div(
            class = "col-md-3 col-6",
            tags$div(
              class = "kpi-card",
              tags$div(class = "kpi-icon-box kpi-icon-purple", tags$i(class = "fa fa-music")),
              tags$div(
                tags$div(class = "kpi-val", summary_kpis$total_songs),
                tags$div(class = "kpi-label", "Curated Songs")
              )
            )
          ),
          tags$div(
            class = "col-md-3 col-6",
            tags$div(
              class = "kpi-card",
              tags$div(class = "kpi-icon-box kpi-icon-pink", tags$i(class = "fa fa-user-group")),
              tags$div(
                tags$div(class = "kpi-val", "4 Visionaries"),
                tags$div(class = "kpi-label", "Core Scope")
              )
            )
          ),
          tags$div(
            class = "col-md-3 col-6",
            tags$div(
              class = "kpi-card",
              tags$div(class = "kpi-icon-box kpi-icon-cyan", tags$i(class = "fa fa-bolt")),
              tags$div(
                tags$div(class = "kpi-val", summary_kpis$most_common_mood),
                tags$div(class = "kpi-label", "Dominant Vibe")
              )
            )
          ),
          tags$div(
            class = "col-md-3 col-6",
            tags$div(
              class = "kpi-card",
              tags$div(class = "kpi-icon-box kpi-icon-gold", tags$i(class = "fa fa-star")),
              tags$div(
                tags$div(class = "kpi-val", paste0(summary_kpis$avg_popularity, "/100")),
                tags$div(class = "kpi-label", "Avg Popularity")
              )
            )
          )
        ),
        
        # Trending Hits Showcase
        tags$h3(style = "font-weight: 700; margin-bottom: 1rem;", tags$i(class = "fa fa-fire", style = "color: #f59e0b; margin-right: 8px;"), "Popularity Hall of Fame"),
        uiOutput("home_top_cards_grid")
      ),
      
      # ----------------------------------------------------
      # TAB 2: DISCOVER
      # ----------------------------------------------------
      tags$div(
        class = "tab-pane fade",
        id = "tab-discover",
        
        tags$div(
          class = "glass-panel",
          tags$h4(style = "font-weight: 700; margin-bottom: 1.25rem;", tags$i(class = "fa fa-sliders", style = "color: #8b5cf6; margin-right: 8px;"), "Explore & Filter Music Library"),
          tags$div(
            class = "row g-3",
            tags$div(
              class = "col-md-3",
              textInput("disc_search", "Search Song / Movie:", value = "", placeholder = "Type track or album...")
            ),
            tags$div(
              class = "col-md-3",
              selectInput("disc_artist", "Filter by Artist:", choices = TARGET_ARTISTS, selected = "All")
            ),
            tags$div(
              class = "col-md-2",
              selectInput("disc_mood", "Filter by Mood:", choices = ALL_MOODS, selected = "All")
            ),
            tags$div(
              class = "col-md-2",
              selectInput("disc_genre", "Filter by Genre:", choices = ALL_GENRES, selected = "All")
            ),
            tags$div(
              class = "col-md-2",
              selectInput("disc_sort", "Sort Tracks By:", choices = c("Popularity" = "popularity", "Release Year" = "release_year", "Energy" = "energy", "Song Title" = "song_name"), selected = "popularity")
            )
          )
        ),
        
        tags$div(
          style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;",
          tags$h4(style = "font-weight: 700; margin: 0;", uiOutput("discover_count_label")),
          radioGroupButtons(
            inputId = "disc_view_mode",
            choices = c("Card Grid" = "grid", "Data Table" = "table"),
            selected = "grid",
            status = "secondary",
            size = "sm"
          )
        ),
        
        uiOutput("discover_main_output")
      ),

      # ----------------------------------------------------
      # TAB 3: MOOD ENGINE
      # ----------------------------------------------------
      tags$div(
        class = "tab-pane fade",
        id = "tab-mood",
        
        tags$div(
          class = "hero-card",
          style = "padding: 2rem;",
          tags$h2(style = "font-weight: 800;", tags$i(class = "fa fa-face-smile", style = "color: #ec4899; margin-right: 10px;"), "Music Mood Intelligence"),
          tags$p(class = "text-muted", "Categorize Tamil tracks into emotional mood profiles using analytical acoustic features.")
        ),
        
        tags$div(
          class = "row",
          tags$div(
            class = "col-lg-4",
            tags$div(
              class = "glass-panel",
              tags$h5(style = "font-weight: 700; margin-bottom: 1rem;", "Select Mood Vibe"),
              selectInput("mood_select", "Target Mood Category:", choices = ALL_MOODS[ALL_MOODS != "All"], selected = "Energetic"),
              tags$hr(style = "border-color: var(--glass-border);"),
              uiOutput("mood_description_card")
            )
          ),
          tags$div(
            class = "col-lg-8",
            tags$div(
              class = "glass-panel",
              plotlyOutput("mood_radar_plot", height = "380px")
            )
          )
        ),
        
        tags$h4(style = "font-weight: 700; margin: 1.5rem 0 1rem 0;", "Matching Songs in this Mood"),
        uiOutput("mood_songs_grid")
      ),

      # ----------------------------------------------------
      # TAB 4: SIMILARITY ENGINE
      # ----------------------------------------------------
      tags$div(
        class = "tab-pane fade",
        id = "tab-similarity",
        
        tags$div(
          class = "glass-panel",
          tags$h3(style = "font-weight: 800;", tags$i(class = "fa fa-wand-magic-sparkles", style = "color: #8b5cf6; margin-right: 10px;"), "Vibe Matcher - Song Similarity Engine"),
          tags$p(class = "text-muted", "Find songs with a similar musical vibe by calculating normalized Euclidean distance & Cosine similarity across energy, danceability, romance, sadness, happiness, and tempo."),
          tags$div(
            class = "row g-3",
            tags$div(
              class = "col-md-6",
              selectInput("sim_target_song", "Choose Target Song:", choices = NULL)
            ),
            tags$div(
              class = "col-md-3",
              selectInput("sim_method", "Similarity Metric:", choices = c("Cosine Similarity" = "cosine", "Euclidean Distance" = "euclidean"), selected = "cosine")
            ),
            tags$div(
              class = "col-md-3",
              sliderInput("sim_top_n", "Top Recommendations:", min = 3, max = 10, value = 5, step = 1)
            )
          )
        ),
        
        uiOutput("similarity_results_ui")
      ),

      # ----------------------------------------------------
      # TAB 5: ARTISTS
      # ----------------------------------------------------
      tags$div(
        class = "tab-pane fade",
        id = "tab-artists",
        
        tags$div(
          class = "glass-panel",
          tags$h3(style = "font-weight: 800;", tags$i(class = "fa fa-microphone", style = "color: #06b6d4; margin-right: 10px;"), "Artist Intelligence & Comparative Analytics"),
          selectInput("artist_focus", "Focus Artist:", choices = TARGET_ARTISTS[TARGET_ARTISTS != "All"], selected = "Anirudh Ravichander")
        ),
        
        uiOutput("artist_profile_header"),
        
        tags$div(
          class = "row g-3",
          style = "margin-top: 1rem;",
          tags$div(
            class = "col-lg-6",
            tags$div(class = "glass-panel", plotlyOutput("artist_comp_radar", height = "380px"))
          ),
          tags$div(
            class = "col-lg-6",
            tags$div(class = "glass-panel", plotlyOutput("artist_timeline_plot", height = "380px"))
          )
        ),
        
        tags$h4(style = "font-weight: 700; margin: 1.5rem 0 1rem 0;", "Top Artist Tracks in Dataset"),
        uiOutput("artist_songs_grid")
      ),

      # ----------------------------------------------------
      # TAB 6: INSIGHTS
      # ----------------------------------------------------
      tags$div(
        class = "tab-pane fade",
        id = "tab-insights",
        
        tags$div(
          class = "glass-panel",
          tags$h3(style = "font-weight: 800;", tags$i(class = "fa fa-chart-pie", style = "color: #f59e0b; margin-right: 10px;"), "Music Insights Dashboard"),
          tags$p(class = "text-muted", "Interactive statistical visualisations exploring Tamil music trends and acoustic distributions.")
        ),
        
        tags$div(
          class = "row g-3",
          tags$div(
            class = "col-lg-8",
            tags$div(class = "glass-panel", plotlyOutput("insights_timeline_plot", height = "420px"))
          ),
          tags$div(
            class = "col-lg-4",
            tags$div(class = "glass-panel", plotlyOutput("insights_mood_donut", height = "420px"))
          )
        ),
        
        tags$div(
          class = "row g-3",
          style = "margin-top: 0.5rem;",
          tags$div(
            class = "col-lg-6",
            tags$div(class = "glass-panel", plotlyOutput("insights_energy_pop_scatter", height = "360px"))
          ),
          tags$div(
            class = "col-lg-6",
            tags$div(class = "glass-panel", plotlyOutput("insights_genre_bar", height = "360px"))
          )
        )
      ),

      # ----------------------------------------------------
      # TAB 7: PROFILE
      # ----------------------------------------------------
      tags$div(
        class = "tab-pane fade",
        id = "tab-profile",
        
        tags$div(
          class = "hero-card",
          style = "padding: 2rem;",
          tags$h2(style = "font-weight: 800;", tags$i(class = "fa fa-user-astronaut", style = "color: #a855f7; margin-right: 10px;"), "Personalized Preference Profile"),
          tags$p(class = "text-muted", "Configure your musical preferences to generate your custom Tamil Vibe Profile & tailored recommendations.")
        ),
        
        tags$div(
          class = "row",
          tags$div(
            class = "col-lg-5",
            tags$div(
              class = "glass-panel",
              tags$h4(style = "font-weight: 700; margin-bottom: 1rem;", "Configure Your Vibe"),
              selectInput("pref_artist", "Favorite Artist Preference:", choices = TARGET_ARTISTS, selected = "All"),
              selectInput("pref_mood", "Preferred Target Mood:", choices = ALL_MOODS, selected = "All"),
              sliderInput("pref_energy", "Desired Energy Level:", min = 0, max = 100, value = 85, step = 5),
              sliderInput("pref_romance", "Romance Level:", min = 0, max = 100, value = 60, step = 5),
              sliderInput("pref_happiness", "Happiness Level:", min = 0, max = 100, value = 80, step = 5),
              sliderInput("pref_sadness", "Sadness Tolerance:", min = 0, max = 100, value = 20, step = 5),
              selectInput("pref_era", "Preferred Era:", choices = c("All Eras" = "All", "2020s Modern Hits" = "2020s", "2010s Golden Era" = "2010s", "Pre-2010 Classics" = "Classics"), selected = "All")
            )
          ),
          tags$div(
            class = "col-lg-7",
            uiOutput("user_profile_archetype_card"),
            tags$h4(style = "font-weight: 700; margin: 1.5rem 0 1rem 0;", "Tailored Recommendations For You"),
            uiOutput("user_recommendations_grid")
          )
        )
      )
    )
  ),

  # Fixed Mini Player UI Bar
  tags$div(
    class = "mini-player-bar",
    tags$div(
      class = "player-left",
      tags$img(
        id = "mini-player-cover",
        src = "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop",
        class = "player-thumb",
        alt = "Cover",
        onerror = "handleImgError(this)"
      ),
      tags$div(
        tags$div(id = "mini-player-title", class = "player-info-title", "Hukum - Thalaivar Alappara"),
        tags$div(id = "mini-player-artist", class = "player-info-artist", "Anirudh Ravichander")
      )
    ),
    tags$div(
      class = "player-center",
      tags$div(
        class = "player-controls",
        tags$button(class = "btn-player-action", tags$i(class = "fa fa-backward-step")),
        tags$button(id = "mini-player-toggle", class = "btn-player-play", tags$i(class = "fa fa-play")),
        tags$button(class = "btn-player-action", tags$i(class = "fa fa-forward-step"))
      ),
      tags$div(
        class = "player-progress-container",
        tags$span(class = "time-stamp", "1:15"),
        tags$div(
          id = "mini-player-seekbar",
          class = "player-progress-bar",
          tags$div(id = "mini-player-fill", class = "player-progress-fill")
        ),
        tags$span(class = "time-stamp", "3:26")
      )
    ),
    tags$div(
      class = "d-none d-md-flex align-items-center gap-3",
      tags$div(
        id = "audio-wave-anim",
        class = "audio-wave",
        style = "display: none;",
        tags$span(), tags$span(), tags$span(), tags$span()
      ),
      tags$i(class = "fa fa-volume-high", style = "color: var(--text-muted);")
    )
  )
)

# =========================================================
# SERVER LOGIC
# =========================================================

server <- function(input, output, session) {

  # Populate Similarity Dropdown choices
  observe({
    song_choices <- setNames(music_df$song_id, paste(music_df$song_name, "-", music_df$artist))
    updateSelectInput(session, "sim_target_song", choices = song_choices, selected = music_df$song_id[1])
  })

  # ----------------------------------------------------
  # 1. HOME TAB RENDERING
  # ----------------------------------------------------
  output$home_top_cards_grid <- renderUI({
    top_songs <- music_df %>% arrange(desc(popularity)) %>% head(4)
    cards <- lapply(seq_len(nrow(top_songs)), function(i) {
      tags$div(class = "col-md-3 col-6", render_song_card_html(top_songs[i, ]))
    })
    tags$div(class = "row g-3", cards)
  })

  # ----------------------------------------------------
  # 2. DISCOVER TAB FILTERING & RENDERING
  # ----------------------------------------------------
  filtered_discover_df <- reactive({
    df <- music_df
    
    # Text search
    if (nzchar(trimws(input$disc_search))) {
      q <- tolower(trimws(input$disc_search))
      df <- df %>% filter(grepl(q, tolower(song_name)) | grepl(q, tolower(album_or_movie)))
    }
    # Artist filter
    if (input$disc_artist != "All") {
      df <- df %>% filter(artist == input$disc_artist)
    }
    # Mood filter
    if (input$disc_mood != "All") {
      df <- df %>% filter(mood == input$disc_mood)
    }
    # Genre filter
    if (input$disc_genre != "All") {
      df <- df %>% filter(genre == input$disc_genre)
    }
    # Sort
    sort_col <- input$disc_sort
    if (sort_col %in% colnames(df)) {
      if (sort_col == "song_name") {
        df <- df %>% arrange(.data[[sort_col]])
      } else {
        df <- df %>% arrange(desc(.data[[sort_col]]))
      }
    }
    
    df
  })

  output$discover_count_label <- renderUI({
    cnt <- nrow(filtered_discover_df())
    tags$span(paste("Showing", cnt, "Songs"))
  })

  output$discover_main_output <- renderUI({
    df <- filtered_discover_df()
    
    if (nrow(df) == 0) {
      return(
        tags$div(
          class = "glass-panel text-center",
          style = "padding: 3rem;",
          tags$i(class = "fa fa-compact-disc fa-3x", style = "color: var(--text-subtle); margin-bottom: 1rem;"),
          tags$h4("No songs found matching filters."),
          tags$p(class = "text-muted", "Try broadening your search query or artist filters.")
        )
      )
    }
    
    if (input$disc_view_mode == "grid") {
      cards <- lapply(seq_len(nrow(df)), function(i) {
        tags$div(class = "col-lg-3 col-md-4 col-sm-6 mb-4", render_song_card_html(df[i, ]))
      })
      tags$div(class = "row", cards)
    } else {
      # Render DataTable
      DT::DTOutput("discover_table")
    }
  })

  output$discover_table <- DT::renderDT({
    df <- filtered_discover_df() %>%
      select(song_name, artist, album_or_movie, release_year, genre, mood, energy, popularity)
    
    DT::datatable(
      df,
      options = list(pageLength = 10, autoWidth = TRUE, dom = 'ftp'),
      rownames = FALSE,
      class = 'table table-dark table-hover'
    )
  })

  # ----------------------------------------------------
  # 3. MOOD TAB RENDERING
  # ----------------------------------------------------
  output$mood_description_card <- renderUI({
    m <- input$mood_select
    desc <- get_mood_description(m)
    
    tags$div(
      tags$h5(style = "color: var(--accent-pink); font-weight: 700;", paste(m, "Acoustic Profile")),
      tags$p(style = "color: var(--text-muted); font-size: 0.9rem;", desc)
    )
  })

  output$mood_radar_plot <- renderPlotly({
    m_songs <- music_df %>% filter(mood == input$mood_select)
    if (nrow(m_songs) == 0) return(NULL)
    
    m_row <- data.frame(
      song_name = paste(input$mood_select, "Average Vibe"),
      energy = mean(m_songs$energy),
      danceability = mean(m_songs$danceability),
      romantic_score = mean(m_songs$romantic_score),
      sadness_score = mean(m_songs$sadness_score),
      happiness_score = mean(m_songs$happiness_score)
    )
    plot_song_radar(m_row)
  })

  output$mood_songs_grid <- renderUI({
    m_songs <- music_df %>% filter(mood == input$mood_select)
    if (nrow(m_songs) == 0) return(tags$p("No songs in this mood."))
    
    cards <- lapply(seq_len(nrow(m_songs)), function(i) {
      tags$div(class = "col-md-3 col-6", render_song_card_html(m_songs[i, ]))
    })
    tags$div(class = "row g-3", cards)
  })

  # ----------------------------------------------------
  # 4. SIMILARITY TAB RENDERING
  # ----------------------------------------------------
  output$similarity_results_ui <- renderUI({
    req(input$sim_target_song)
    target_id <- input$sim_target_song
    target_song <- music_df %>% filter(song_id == target_id)
    if (nrow(target_song) == 0) return(NULL)
    
    sim_results <- find_similar_songs(music_df, target_id, top_n = input$sim_top_n, method = input$sim_method)
    
    # Target Song Header Box
    target_box <- tags$div(
      class = "glass-panel",
      style = "border-color: var(--primary);",
      tags$div(
        class = "row align-items-center",
        tags$div(
          class = "col-auto",
          tags$img(src = target_song$album_cover[1], style = "width: 90px; height: 90px; border-radius: 12px; object-fit: cover;", onerror = "handleImgError(this)")
        ),
        tags$div(
          class = "col",
          tags$span(class = "badge-pill badge-mood-energetic", "SELECTED REFERENCE TRACK"),
          tags$h3(style = "font-weight: 800; margin: 4px 0;", target_song$song_name[1]),
          tags$p(class = "text-muted", style = "margin: 0;", paste(target_song$artist[1], "•", target_song$album_or_movie[1], "(", target_song$release_year[1], ")"))
        )
      )
    )
    
    # Similar Cards Grid
    sim_cards <- lapply(seq_len(nrow(sim_results)), function(i) {
      s_row <- sim_results[i, ]
      tags$div(
        class = "col-lg-4 col-md-6 mb-4",
        tags$div(
          class = "song-card",
          tags$div(
            style = "position: absolute; top: 12px; right: 12px; z-index: 10; background: var(--primary-gradient); color: white; padding: 4px 12px; border-radius: 20px; font-weight: 800; font-size: 0.85rem; box-shadow: 0 4px 12px rgba(0,0,0,0.4);",
            paste0(s_row$similarity_score, "% Match")
          ),
          render_song_card_html(s_row)
        )
      )
    })
    
    tags$div(
      target_box,
      tags$h4(style = "font-weight: 700; margin: 1.5rem 0 1rem 0;", tags$i(class = "fa fa-vibe", style = "color: #06b6d4;"), "Top Recommended Tracks with Similar Acoustic Vibe"),
      tags$div(class = "row", sim_cards)
    )
  })

  # ----------------------------------------------------
  # 5. ARTISTS TAB RENDERING
  # ----------------------------------------------------
  output$artist_profile_header <- renderUI({
    art <- input$artist_focus
    art_df <- music_df %>% filter(artist == art)
    if (nrow(art_df) == 0) return(NULL)
    
    avg_pop <- round(mean(art_df$popularity), 1)
    avg_eng <- round(mean(art_df$energy), 1)
    top_m   <- names(which.max(table(art_df$mood)))
    
    tags$div(
      class = "glass-panel",
      tags$div(
        class = "row align-items-center",
        tags$div(
          class = "col-md-8",
          tags$h2(style = "font-weight: 800;", art),
          tags$p(class = "text-muted", paste(nrow(art_df), "Tracks in Dataset • Era:", min(art_df$release_year), "-", max(art_df$release_year))),
          tags$div(
            style = "display: flex; gap: 15px; margin-top: 1rem;",
            tags$span(class = "badge-pill badge-mood-happy", paste("Popularity:", avg_pop, "/ 100")),
            tags$span(class = "badge-pill badge-mood-energetic", paste("Avg Energy:", avg_eng, "%")),
            tags$span(class = "badge-pill badge-mood-chill", paste("Signature Mood:", top_m))
          )
        )
      )
    )
  })

  output$artist_comp_radar <- renderPlotly({
    plot_artist_comparison(music_df)
  })

  output$artist_timeline_plot <- renderPlotly({
    art_df <- music_df %>% filter(artist == input$artist_focus)
    plot_music_timeline(art_df)
  })

  output$artist_songs_grid <- renderUI({
    art_df <- music_df %>% filter(artist == input$artist_focus)
    cards <- lapply(seq_len(nrow(art_df)), function(i) {
      tags$div(class = "col-md-3 col-6", render_song_card_html(art_df[i, ]))
    })
    tags$div(class = "row g-3", cards)
  })

  # ----------------------------------------------------
  # 6. INSIGHTS TAB RENDERING
  # ----------------------------------------------------
  output$insights_timeline_plot     <- renderPlotly({ plot_music_timeline(music_df) })
  output$insights_mood_donut        <- renderPlotly({ plot_mood_distribution(music_df) })
  output$insights_energy_pop_scatter <- renderPlotly({ plot_energy_vs_popularity(music_df) })
  output$insights_genre_bar         <- renderPlotly({ plot_genre_distribution(music_df) })

  # ----------------------------------------------------
  # 7. USER PROFILE TAB RENDERING
  # ----------------------------------------------------
  output$user_profile_archetype_card <- renderUI({
    arch <- classify_user_archetype(input$pref_energy, input$pref_romance, input$pref_happiness, input$pref_sadness)
    
    tags$div(
      class = "glass-panel",
      style = "background: linear-gradient(135deg, rgba(139, 92, 246, 0.2) 0%, rgba(15, 18, 26, 0.9) 100%); border-color: var(--primary);",
      tags$h3(style = "font-weight: 800; color: #ffffff;", arch$title),
      tags$p(style = "color: var(--text-muted); font-size: 1rem; line-height: 1.6;", arch$desc)
    )
  })

  output$user_recommendations_grid <- renderUI({
    recs <- generate_user_recommendations(
      df = music_df,
      fav_artist = input$pref_artist,
      pref_mood = input$pref_mood,
      pref_energy = input$pref_energy,
      pref_romance = input$pref_romance,
      pref_happiness = input$pref_happiness,
      pref_sadness = input$pref_sadness,
      pref_era = input$pref_era,
      top_n = 6
    )
    
    cards <- lapply(seq_len(nrow(recs)), function(i) {
      r_row <- recs[i, ]
      tags$div(
        class = "col-md-4 col-6 mb-4",
        tags$div(
          class = "song-card",
          tags$div(
            style = "position: absolute; top: 12px; right: 12px; z-index: 10; background: var(--primary-gradient); color: white; padding: 4px 10px; border-radius: 20px; font-weight: 800; font-size: 0.75rem;",
            paste0(r_row$match_score, "% Vibe Match")
          ),
          render_song_card_html(r_row)
        )
      )
    })
    tags$div(class = "row", cards)
  })

  # ----------------------------------------------------
  # SONG DETAIL MODAL EVENT
  # ----------------------------------------------------
  observeEvent(input$select_song_detail, {
    s_id <- input$select_song_detail
    s_row <- music_df %>% filter(song_id == s_id)
    if (nrow(s_row) == 0) return()
    
    sim_recs <- find_similar_songs(music_df, s_id, top_n = 3)
    
    showModal(modalDialog(
      title = paste("Song Details -", s_row$song_name),
      easyClose = TRUE,
      size = "l",
      footer = modalButton("Close"),
      tags$div(
        class = "row",
        tags$div(
          class = "col-md-5 text-center",
          tags$img(src = s_row$album_cover, style = "width: 100%; max-width: 260px; border-radius: 16px; object-fit: cover;", onerror = "handleImgError(this)"),
          tags$h3(style = "font-weight: 800; margin-top: 1rem;", s_row$song_name),
          tags$h5(style = "color: var(--primary);", s_row$artist),
          tags$p(class = "text-muted", paste(s_row$album_or_movie, "•", s_row$release_year)),
          tags$span(class = paste("badge-pill", paste0("badge-mood-", tolower(s_row$mood))), s_row$mood)
        ),
        tags$div(
          class = "col-md-7",
          plotlyOutput("modal_radar_plot", height = "300px"),
          tags$hr(style = "border-color: var(--glass-border);"),
          tags$h5(style = "font-weight: 700;", "Acoustic Metric Breakdown"),
          tags$div(
            style = "font-size: 0.9rem;",
            tags$div(paste("Energy:", s_row$energy, "%")),
            tags$div(paste("Danceability:", s_row$danceability, "%")),
            tags$div(paste("Romance Score:", s_row$romantic_score, "%")),
            tags$div(paste("Popularity Score:", s_row$popularity, "/ 100")),
            tags$div(paste("Tempo:", s_row$tempo, "BPM")),
            tags$div(paste("Duration:", s_row$duration))
          )
        )
      )
    ))
    
    output$modal_radar_plot <- renderPlotly({
      plot_song_radar(s_row)
    })
  })
}

# Run Application
shinyApp(ui = ui, server = server)
