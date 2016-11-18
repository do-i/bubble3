/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

function getMediaFilePath(mediaItem) {
  return "ext-content/" + mediaItem.dir + '/' + mediaItem.title +
    mediaItem.file_ext;
}

function renderVideo(mediaItem) {
  renderMedia(mediaItem.title, $("<video/>", {
    id: "video_elm",
    src: getMediaFilePath(mediaItem),
    type: "video/mp4", // TODO  mediaItem.file_ext.toString().substring(1).toLowerCase();
    width: "100%",
    controls: true
  }), function() {
    $("#video_elm")[0].pause();
  });
}

/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {
  var videoFiles = $(result).filter(function() {
    return this.category == "videos";
  });
  console.log(videoFiles);
  $.each(videoFiles, function(i, mediaItem) {
    var btnDiv = $("<div></div>", {
      "class": "col-xs-12 col-sm-6 col-md-4 col-lg-3 top-margin-1"
    }).appendTo("#files_list");
    var btn = $("<button></button>", {
      "type": "button",
      "class": "btn btn-primary btn-lg gradient round btn-block ellipsis",
      "data-toggle": "modal",
      "data-target": "#video_modal",
      "value": mediaItem
    }).appendTo(btnDiv);
    btn.html(mediaItem.title);
    btn.on("click", function() {
      var selection = $(this).val();
      $("#video_elm").empty(); // clear previous source element
      var video_src = $("<source/>", {
        "src": getMediaFilePath(mediaItem),
        "type": "video/mp4"
      }).appendTo("#video_elm");
      $("#video_elm").load();
    });
  });
  // $.each(result, function() {
  //   if (this.category == "videos") {
  //     console.log(this.title);
  //   } else {
  //     console.log(this.category);
  //   }
  // });
}); // end of getJSON()
