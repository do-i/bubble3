/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

/*
 * Load the video list from the json file
 */
$.getJSON("data/video_list.json", function(result) {
  $.each(result, function(i, item) {
    var btnDiv = $("<div></div>", {
      "class": "col-xs-12 col-sm-6 col-md-4 col-lg-3 top-margin-1"
    }).appendTo("#files_list");

    var btn = $("<button></button>", {
      "type": "button",
      "class": "btn btn-bubble btn-lg btn-block",
      "data-toggle": "modal",
      "data-target": "#video_modal",
      "value": item
    }).appendTo(btnDiv);
    btn.html(item.substring(0, item.length - 4));
    btn.on("click", function() {
      var selection = $(this).val();
      $("#video_elm").empty(); // clear previous source element
      var video_src = $("<source/>", {
        "src": "ext-content/" + selection,
        "type": "video/mp4"
      }).appendTo("#video_elm");
      $("#video_elm").load();
    });
  });
});

$.getJSON("data/pdf_list.json", function(result) {
  $.each(result, function(i, item) {
    var btnDiv = $("<div></div>", {
      "class": "col-xs-12 col-sm-6 col-md-4 col-lg-3 top-margin-1"
    }).appendTo("#files_list");

    var btn = $("<button></button>", {
      "type": "button",
      "class": "btn btn-bubble btn-lg btn-block",
      "value": item
    }).appendTo(btnDiv);
    btn.html(item.substring(0, item.length - 4));
    btn.on("click", function() {
      var selection = $(this).val();
      window.location = "ext-content/" + selection;
    });
  });
});

/*
 * Pause the video when bootstrap modal is hidden.
 */
$("#video_modal").on("hide.bs.modal", function(e) {
  $("#video_elm")[0].pause();
})
