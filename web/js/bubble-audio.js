/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

function getMediaFilePath(mediaItem) {
  return "ext-content/" + mediaItem.dir + '/' + mediaItem.title +
    mediaItem.file_ext;
}

function renderAudio(mediaItem) {
  $("#audio_elm").empty(); // clear previous source element
  var video_src = $("<source/>", {
    "src": getMediaFilePath(mediaItem),
    "type": "audio/mp3"
  }).appendTo("#audio_elm");
  $("#audio_elm").load();
}
/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {
  var mediaFiles = $(result).filter(function() {
    return this.category == "music";
  });
  $.each(mediaFiles, function(i, mediaItem) {
    var btn = $("<button></button>", {
      "type": "button",
      "class": "btn btn-primary btn-lg gradient round btn-block ellipsis",
      "data-toggle": "modal",
      "data-target": "#audio_modal",
      "value": mediaItem
    }).appendTo("#files_list");
    btn.html(mediaItem.title);
    btn.on("click", function() {
      renderAudio(mediaItem);
    });
  });
}); // end of getJSON()

/*
 * Pause the audio when bootstrap modal is hidden.
 */
$("#audio_modal").on("hide.bs.modal", function(e) {
  $("#audio_elm")[0].pause();
});
