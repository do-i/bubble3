/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

function getMediaFilePath(mediaItem) {
  return "ext-content/" + mediaItem.dir + '/' + mediaItem.title +
    mediaItem.file_ext;
}

function rendarMedia(id, headerTitle, mediaElement) {
  webix.ui({
    view: "window",
    id: "media_window",
    fullscreen: true,
    head: {
      view: "toolbar",
      margin: -10,
      cols: [{
        view: "label",
        label: headerTitle
      }, {
        view: "icon",
        icon: "times-circle",
        click: function() {
          $(id)[0].pause();
          $$('media_window').close();
        }
      }]
    },
    body: {
      padding: 1,
      rows: [{
        // Ensures URL encoding is applied to the src URL
        template: mediaElement.get(0).outerHTML
      }]
    }
  }).show();
}

function rendarPdf(mediaItem) {
  window.location = getMediaFilePath(mediaItem);
}

function rendarAudio(mediaItem) {
  rendarMedia("#audio_elm", mediaItem.title, $("<audio/>", {
    id: "audio_elm",
    src: getMediaFilePath(mediaItem),
    type: "audio/mp3",
    width: "100%",
    controls: true
  }));
}

function rendarVideo(mediaItem) {
  rendarMedia("#video_elm", mediaItem.title, $("<video/>", {
    id: "video_elm",
    src: getMediaFilePath(mediaItem),
    type: "video/mp4",
    width: "100%",
    controls: true
  }));
}

function rendarPhoto(mediaItem) {
  function img(obj) {
    return '<img src="' + obj.src + '" class="content" ondragstart="return false"/>'
  }
  var mediaPath = getMediaFilePath(mediaItem);
  webix.ui({
    view: "window",
    body: {
      view: "carousel",
      id: "carousel",
      width: 464,
      height: 275,
      cols: [{
        css: "image",
        template: img,
        data: {
          src: mediaPath
        }
      }, {
        css: "image",
        template: img,
        data: {
          src: mediaPath
        }
      }]
    },
    head: {
      view: "toolbar",
      type: "MainBar",
      elements: [{
        view: "label",
        label: "Photobook",
        align: 'left'
      }]
    }
  }).show();
}


/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {

  webix.ui({
    margin: 5,
    padding: 0,
    type: "wide",
    view: "flexlayout",
    cols: [{
      container: "media_list",
      view: "grouplist",
      templateBack: "{common.categoryIcon()} #value#",
      templateGroup: "{common.categoryIcon()} #value#",
      templateItem: "#title#",
      select: true,
      scroll: true,
      type: {
        categoryIcon: function(mediaItem) {
          var icon_class;
          switch (mediaItem.value) {
            case "videos":
              icon_class = "fa-film";
            case "documents":
              icon_class = "fa-file-pdf-o";
            case "books":
              icon_class = "fa-book";
            case "music":
              icon_class = "fa-music";
            case "tv":
              icon_class = "fa-tv";
            case "photos":
              icon_class = "fa-image";
            default:
              icon_class = "fa-github";
          }
          return $('<span/>', {
            "class": "webix_icon"
          }).addClass(icon_class).icon_span.get(0).outerHTML;
        }
      },
      scheme: {
        $group: {
          by: 'category'
        },
        $sort: {
          by: "value",
          dir: "desc"
        }
      },
      on: {
        onSelectChange: function() {
          var mediaItem = this.getSelectedItem();
          if (mediaItem == undefined) {
            // Case unselectAll event happens.
            return;
          }
          if (mediaItem.category == 'videos') {
            rendarVideo(mediaItem);
          } else if (mediaItem.category == 'documents') {
            rendarPdf(mediaItem);
          } else if (mediaItem.category == 'music') {
            rendarAudio(mediaItem);
          } else if (mediaItem.category == 'photos') {
            // rendarPhoto(mediaItem);
            webix.message("Feature is coming soon!");
          } else {
            webix.message("Unsupported type" + mediaItem.category);
          }
          $$(this).unselectAll();
        }
      },
      data: webix.copy(result)
    }]
  });
}); // end of getJSON()
