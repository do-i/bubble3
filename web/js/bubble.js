/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

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
      container: "media_list_poc",
      view: "grouplist",
      templateBack: " Category #category#",
      templateGroup: " Category #value#",
      templateItem: "#title#",
      select: true,
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
          if (mediaItem.category == 'videos') {
            rendarVideo(mediaItem);
          } else if (mediaItem.category == 'documents') {
            rendarPdf(mediaItem);
          } else {
            console.log("unsupported type " + mediaItem.category);
          }
        }
      },
      data: webix.copy(result)
    }]
  });
}); // end of getJSON()

function getMediaFilePath(mediaItem) {
  return "ext-content/" + mediaItem.dir + '/' + mediaItem.title +
    mediaItem.file_ext;
}

function rendarPdf(mediaItem) {
  window.location = getMediaFilePath(mediaItem);
}

function rendarVideo(mediaItem) {
  // Make sure URL encoding is applied to the src URL
  var videoElement = $("<video/>", {
    id: "video",
    src: getMediaFilePath(mediaItem),
    type: "video/mp4",
    controls: true
  }).get(0).outerHTML;
  webix.ui({
    view: "window",
    id: "video_window",
    fullscreen: true,
    head: {
      view: "toolbar",
      margin: -10,
      cols: [{
        view: "label",
        label: mediaItem.title
      }, {
        view: "icon",
        icon: "times-circle",
        click: "$$('video_window').close();"
      }]
    },
    body: {
      padding: 1,
      rows: [{
        template: videoElement
      }]
    }
  }).show();
}
