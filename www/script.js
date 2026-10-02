/* =========================================================
   MusicMind - Frontend Interaction & Mini Player JS Controller
   ========================================================= */

$(document).ready(function() {
  console.log("MusicMind R/Shiny Frontend Initialized.");

  let isPlaying = false;
  let playInterval = null;
  let progressPercent = 35;

  // Fallback handler for missing or failed images
  window.handleImgError = function(img) {
    img.onerror = null;
    img.src = 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop';
  };

  // Play button click listener on cards
  $(document).on('click', '.play-overlay-btn, .btn-play-trigger', function(e) {
    e.stopPropagation();
    const songId = $(this).data('song-id');
    const songName = $(this).data('song-name') || 'Selected Track';
    const artistName = $(this).data('artist') || 'Tamil Artist';
    const coverUrl = $(this).data('cover') || '';

    // Update Mini Player UI
    $('#mini-player-title').text(songName);
    $('#mini-player-artist').text(artistName);
    if (coverUrl) {
      $('#mini-player-cover').attr('src', coverUrl);
    }
    
    // Set Playing State
    setPlayState(true);

    // Notify Shiny Backend
    if (Shiny && Shiny.setInputValue) {
      Shiny.setInputValue('play_song_event', {
        song_id: songId,
        song_name: songName,
        artist: artistName,
        timestamp: new Date().getTime()
      }, {priority: 'event'});
    }
  });

  // Mini Player Play/Pause Button
  $(document).on('click', '#mini-player-toggle', function() {
    setPlayState(!isPlaying);
  });

  function setPlayState(play) {
    isPlaying = play;
    const playBtnIcon = $('#mini-player-toggle i');
    const waveAnim = $('#audio-wave-anim');

    if (isPlaying) {
      playBtnIcon.removeClass('fa-play').addClass('fa-pause');
      waveAnim.show();
      startProgress();
    } else {
      playBtnIcon.removeClass('fa-pause').addClass('fa-play');
      waveAnim.hide();
      stopProgress();
    }
  }

  function startProgress() {
    stopProgress();
    playInterval = setInterval(function() {
      progressPercent += 0.5;
      if (progressPercent > 100) progressPercent = 0;
      $('#mini-player-fill').css('width', progressPercent + '%');
    }, 500);
  }

  function stopProgress() {
    if (playInterval) clearInterval(playInterval);
  }

  // Seek bar click
  $(document).on('click', '#mini-player-seekbar', function(e) {
    const barWidth = $(this).width();
    const clickX = e.offsetX;
    progressPercent = (clickX / barWidth) * 100;
    $('#mini-player-fill').css('width', progressPercent + '%');
  });
});
