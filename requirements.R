# ==========================================
# MusicMind - Package Dependencies Installer
# ==========================================

required_packages <- c(
  "shiny",
  "bslib",
  "shinyWidgets",
  "dplyr",
  "tidyr",
  "stringr",
  "ggplot2",
  "plotly",
  "DT",
  "scales",
  "readr",
  "htmltools"
)

cat("Checking and installing missing R packages for MusicMind...\n")

new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if (length(new_packages) > 0) {
  install.packages(new_packages, repos = "https://cloud.r-project.org")
  cat("Installed missing packages:", paste(new_packages, collapse = ", "), "\n")
} else {
  cat("All required R packages are already installed!\n")
}
