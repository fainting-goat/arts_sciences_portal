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

function printpage()
{
    window.print()
}

$(document).on("change", "#entry_category_id", function() {
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

$(document).on("change", ".children_for_Scope", function() {
    var collection = $(".children_for_Scope");
    var total = 0;
    var tmp = 0;
    var size = 0;

    $.each(collection, function(index, object) {
        tmp = parseFloat($(object).val());
        if (isNaN(tmp)) {
            tmp = 0;
        }
        else {
            size++;
        }
        total = total + tmp;
    });

    total = (total / size).toFixed(2);

    $(".total_for_Scope").val(total);
});

$(document).on("change", ".children_for_Skill", function() {
    var collection = $(".children_for_Skill");
    var total = 0;
    var tmp = 0;
    var size = 0;

    $.each(collection, function(index, object) {
        tmp = parseFloat($(object).val());
        if (isNaN(tmp)) {
            tmp = 0;
        }
        else {
            size++;
        }
        total = total + tmp;
    });

    total = (total / size).toFixed(2);

    $(".total_for_Skill").val(total);
});
import "controllers"
