# MusicMind ✦ Tamil Music Intelligence Platform

> **Understand your music. Discover your next vibe.**  
> A luxury, modern R/Shiny music discovery and analytical intelligence application focused exclusively on four defining Tamil music visionaries.

---

## 🌟 Primary Artist Scope

MusicMind is specifically engineered to analyze, visualize, and recommend tracks from:

1. ⚡ **Anirudh Ravichander** — *Mass anthems, electrifying EDM-Kuthu, & chart-topping melodies*
2. 🔥 **Hiphop Tamizha** — *Folk fusion, pioneering Tamil Hip-Hop, youth anthems, & commercial blockbusters*
3. 🎵 **Sai Abhyankkar** — *Modern acoustic pop, lo-fi R&B fusion, & viral independent blockbusters*
4. 🎻 **G. V. Prakash Kumar** — *Soulful classical fusion, acoustic melodies, & expressive period scores*

---

## 🚀 Key Features & Modules

### 1. 🏠 Landing & Spotlight Dashboard (Home)
- **Hero Banner:** Premium cinematic dark mode intro highlighting R-based acoustic data analysis.
- **Spotlight Song:** Displays top featured track card with album artwork and quick play actions.
- **Dataset Metrics:** Key performance indicators showing total track count, artist scope, dominant mood, and average popularity.
- **Popularity Hall of Fame:** Top-trending track grid sorted by popularity index.

### 2. 🔍 Music Discovery Library (Discover)
- **Searchable Database:** Real-time filtering by song title, movie/album name, artist, mood, and genre.
- **Multi-Sort Capabilities:** Sort songs by Popularity, Release Year, Energy level, or Track Title.
- **Interactive Song Cards:** Displays high-resolution album artwork, artist, release year, mood pill badges, popularity score, and play button overlay.
- **Toggle View:** Switch seamlessly between luxury Card Grid view and interactive `DT` Data Table view.

### 3. 🎭 Music Mood Engine (Mood)
- **8 Emotional Vibe Categories:** *Energetic, Happy, Romantic, Sad, Chill, Melancholic, Party, & Motivational.*
- **Interactive Polar Radar Profiles:** Dynamic Plotly radar visualizer illustrating the average acoustic shape of each mood category.
- **Analytical Explanations:** Deep textual breakdown explaining the acoustic arrangement (BPM, key scales, percussive density) of selected moods.
- **Mood Grid:** Filtered song library corresponding to the active mood selection.

### 4. ⚡ Vibe Matcher — Similarity Engine (Similarity)
- **Multi-Metric Distance Engine:** Uses Min-Max feature normalization across `energy`, `danceability`, `romantic_score`, `sadness_score`, `happiness_score`, and `tempo`.
- **Cosine & Euclidean Algorithms:** Choose between Cosine Similarity and Euclidean Distance vector calculations.
- **Vibe Match Score:** R computes exact match percentages (e.g., `96.4% Match`) and lists the top N nearest neighbor tracks.

### 5. 🎙️ Artist Intelligence (Artists)
- **Comprehensive Visionary Profiles:** Deep-dive statistics for Anirudh, Hiphop Tamizha, Sai Abhyankkar, and G. V. Prakash Kumar.
- **Multi-Artist Radar Overlay:** Interactive 6-axis polar chart comparing all 4 artists across Energy, Danceability, Romance, Sadness, Happiness, and Popularity.
- **Artist Timeline Plot:** Interactive release year timeline showing track distribution for the selected composer.

### 6. 📊 Music Insights Dashboard (Insights)
- **Tamil Evolution Timeline:** Interactive Plotly scatter plot mapping release years (2006–2024) vs. Popularity, colored by composer and sized by energy level.
- **Mood Donut Distribution:** Visual breakdown of dataset track proportions across emotional moods.
- **Energy vs. Popularity Scatter:** Explores the correlation between acoustic energy and audience popularity index.
- **Genre Distribution:** Horizontal bar chart illustrating the distribution of musical genres.

### 7. 👤 Personalized Preference Profile (Profile)
- **Interactive Profile Quiz:** Customize sliders for Desired Energy, Romance Level, Happiness, Sadness Tolerance, Preferred Era, and Favorite Artist.
- **User Vibe Classifier:** Categorizes user personality into archetypes (e.g., *High-Energy Party Pioneer*, *Hopeless Melodic Romanticist*, *Chill Sunset Acoustic Listener*).
- **Tailored R Recommendations:** Vector matching engine returns custom track recommendations with calculated Vibe Match scores.

### 8. 🎵 Glassmorphism Mini Player UI
- **Persistent Bottom Player Bar:** Displays active track artwork, title, composer, play/pause state toggle, progress seek bar, time counter, and animated audio wave equalizer.

### 9. ℹ️ Song Detail Modal View
- Clicking **"View Details"** opens a modal featuring high-res artwork, full acoustic metric breakdown (Energy, Tempo, Duration, Danceability), and an interactive song radar chart.

---

## 🛠️ Project Architecture

```text
MusicMind/
│
├── app.R                       # Main Shiny application entry point (UI & Server)
│
├── R/                          # Modular R business logic & analytics modules
│   ├── data_loader.R           # Dataset loader with fallback verification
│   ├── data_cleaning.R         # Feature normalization & summary aggregations
│   ├── mood_engine.R           # Mood categorization & radar data generation
│   ├── similarity_engine.R     # Cosine & Euclidean vector similarity calculations
│   ├── recommendation_engine.R # User preference recommendation scoring
│   └── analytics.R             # Plotly & ggplot2 chart styling & rendering
│
├── data/
│   └── tamil_music.csv         # Structured dataset containing Tamil song features
│
├── www/                        # Web assets & frontend styling
│   ├── style.css               # Dark luxury design system, glassmorphism & gradients
│   ├── script.js               # Audio player controller & image fallback script
│   └── images/                 # Image storage directory
│
├── output/                     # Output directory for saved reports / exports
├── requirements.R              # R package dependency auto-installer
└── README.md                   # Comprehensive project documentation
```

---

## 🧮 How the Similarity Engine Works

The similarity engine computes acoustic proximity between songs using a normalized multi-dimensional vector space:

$$\mathbf{v}_{\text{song}} = \begin{bmatrix} \text{Energy}_{\text{norm}} \\ \text{Danceability}_{\text{norm}} \\ \text{Romance}_{\text{norm}} \\ \text{Sadness}_{\text{norm}} \\ \text{Happiness}_{\text{norm}} \\ \text{Tempo}_{\text{norm}} \end{bmatrix}$$

### Cosine Similarity Formula:
$$\text{Similarity}(\mathbf{u}, \mathbf{v}) = \frac{\mathbf{u} \cdot \mathbf{v}}{\|\mathbf{u}\| \|\mathbf{v}\|} = \frac{\sum_{i=1}^{n} u_i v_i}{\sqrt{\sum_{i=1}^{n} u_i^2} \sqrt{\sum_{i=1}^{n} v_i^2}}$$

### Euclidean Similarity Formula:
$$d(\mathbf{u}, \mathbf{v}) = \sqrt{\sum_{i=1}^{n} (u_i - v_i)^2}, \quad \text{Similarity Score} = \frac{1}{1 + d(\mathbf{u}, \mathbf{v})}$$

Scores are converted to a standard `0% – 100% Vibe Match` scale.

---

## 💻 How to Run the Application

### Prerequisites:
Make sure **R** (v4.0 or higher) is installed on your computer.

### Step 1: Install Dependencies
Open R or RStudio in the project root directory and run:

```r
source("requirements.R")
```

### Step 2: Launch MusicMind
Run the main application file using Shiny:

```r
shiny::runApp()
```

Or from command prompt / terminal:

```bash
Rscript -e "shiny::runApp()"
```

---

## ⚠️ Important Data Integrity & Copyright Disclosure

1. **Analytical Feature Dataset:** Numerical musical attributes (`energy`, `danceability`, `romantic_score`, `sadness_score`, `happiness_score`, `tempo`, etc.) represent structured analytical feature values curated for this R data analysis project, rather than official raw Spotify API feeds.
2. **Audio Rights & Copyright Compliance:** MusicMind is a UI analytics dashboard prototype. It does **not** download, host, or redistribute copyrighted audio recordings. All song playback controls are visual demonstrations.
3. **Artwork Attribution:** Album artwork URLs utilize publicly accessible promotional media links with automatic inline SVG fallback handling for maximum reliability.

---

## 🔮 Future Enhancements

- Integration with Spotify Web API OAuth authentication for real-time playlist synchronization.
- Lyric sentiment analysis using R text mining packages (`tidytext` / `syuzhet`) for Tamil lyrics.
- Audio spectrum waveform analysis using R audio processing libraries (`tuneR` / `seewave`).

---

**Built with R, Shiny, Plotly & Bslib.**
