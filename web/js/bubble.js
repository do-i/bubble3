/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {
  console.log(result);
  webix.ui({
    margin: 10,
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
          }
        }
      },
      data: webix.copy(result)
    }]
  });

  function getMediaFilePath(mediaItem) {
    return "ext-content/" + mediaItem.dir + '/' + mediaItem.title +
      mediaItem.file_ext;
  }

  function rendarPdf(mediaItem) {
    window.location = getMediaFilePath(mediaItem);
  }

  function rendarVideo(mediaItem) {
    webix.ui({
      view: "window",
      id: "video_window",
      fullscreen: true,
      head: {
        view: "toolbar",
        margin: -4,
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
          template: '<video id="video_elm" width="100%" preload="autoplay" controls><source src=' +
            getMediaFilePath(mediaItem) + ' type="video/mp4"/></video>'
        }]
      }
    }).show();
  }

  //
  // if (result.hasOwnProperty("documents")) {
  //   $.each(result["documents"]["files"], function(i, item) {
  //     var btnDiv = $("<div></div>", {
  //       "class": "col-xs-12 col-sm-6 col-md-4 col-lg-3 top-margin-1"
  //     }).appendTo("#files_list");
  //
  //     var btn = $("<button></button>", {
  //       "type": "button",
  //       "class": "btn btn-bubble btn-lg btn-block",
  //       "value": item
  //     }).appendTo(btnDiv);
  //     btn.html(item.substring(0, item.lastIndexOf('.')));
  //     btn.on("click", function() {
  //       var selection = $(this).val();
  //       window.location = "ext-content/" + result['documents']['dir'] + '/' + selection;
  //     });
  //   });
  // } // end if json has documents section
}); // end of getJSON()
