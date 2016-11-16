/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

function getMediaFilePath(mediaItem) {
  return "ext-content/" + mediaItem.dir + '/' + mediaItem.title +
    mediaItem.file_ext;
}

function renderPdf(mediaItem) {
  // Note embed nor iframe works great to render pdf. So, this is workaround until better alternative is found.
  window.location = getMediaFilePath(mediaItem);
}

/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {
  var mediaFiles = $(result).filter(function() {
    return this.category == "documents";
  });
  $.each(mediaFiles, function(i, mediaItem) {
    var btn = $("<button></button>", {
      "type": "button",
      "class": "btn btn-primary btn-lg gradient round btn-block ellipsis",
      "value": mediaItem
    }).appendTo("#files_list");
    btn.html(mediaItem.title);
    btn.on("click", function() {
      renderPdf(mediaItem);
    });
  });
}); // end of getJSON()
