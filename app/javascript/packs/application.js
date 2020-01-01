// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

//= require jquery3
//= require jquery_ujs
//= require popper
//= require bootstrap-sprockets


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import $ from 'jquery';

$(document).on( "change", "#entry_category_id", function() {
    var entryCategoryDesc = $("#entry_category_desc");

    $.get("/admin/categories/" + $('#entry_category_id').val() + ".json", function(data) {
        entryCategoryDesc.html("<p>" + data.description.replace(/\n\r/g, "</p><p>") + "</p>");

        if(data.mail_in) {
            $('#mail_in_warning').text("This is a mail-in category.");
        } else {
            $('#mail_in_warning').text("")
        }
    });
});