/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

function getMediaFilePath(mediaItem) {
  return "ext-content/" + mediaItem.dir + '/' + mediaItem.title +
    mediaItem.file_ext;
}

function renderVideo(mediaItem) {
  $("#video_elm").empty(); // clear previous source element
  var video_src = $("<source/>", {
    "src": getMediaFilePath(mediaItem),
    "type": "video/mp4"
  }).appendTo("#video_elm");
  $("#video_elm").load();
}
/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {
  var mediaFiles = $(result).filter(function() {
    return this.category == "videos";
  });
  $.each(mediaFiles, function(i, mediaItem) {
    var btn = $("<button></button>", {
      "type": "button",
      "class": "btn btn-primary btn-lg gradient round btn-block ellipsis",
      "data-toggle": "modal",
      "data-target": "#video_modal",
      "value": mediaItem
    }).appendTo("#files_list");
    btn.html(mediaItem.title);
    btn.on("click", function() {
      renderVideo(mediaItem);
    });
  });
}); // end of getJSON()

/*
 * Pause the video when bootstrap modal is hidden.
 */
$("#video_modal").on("hide.bs.modal", function(e) {
  $("#video_elm")[0].pause();
});
