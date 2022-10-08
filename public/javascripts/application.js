$(()=> {
  function snakify(name) {
    return name.toLowerCase().split(" ").join("_");
  }

  $("form").on("click", ".add_input", event => {
    event.preventDefault();

    let $input_wrapper = $(event.target).prev();
    let $new_input_wrapper = $input_wrapper.clone();
    $new_input_wrapper.find("input").removeClass("invalid");

    $new_input_wrapper.find("label, input, select").each((_, element) => {
      let $element = $(element);

      if (element.tagName === "LABEL") {
        $element.attr("for", $element.attr("for").replace(/\d+$/, num => String(Number(num) + 1)));
      } else {
        $element.attr("id", $element.attr("id").replace(/\d+$/, num => String(Number(num) + 1)));
        $element.attr("name", $element.attr("name").replace(/\d+$/, num => String(Number(num) + 1)));
        
        if (element.tagName === "INPUT") {
          element.value = ""
        } else {
          element.selected = false;
        }
      }
    });

    $(event.target).before($new_input_wrapper);
  });

  $("form").on("blur", "input", event => {
    let $element = $(event.target);

    if ($element.val().trim() === "") {
      $element.addClass("invalid");
    } else {
      $element.removeClass("invalid");
    }
  });

  $("form").on("click", ".delete", event => {
    event.preventDefault();
    event.stopPropagation();

    let $target = $(event.target).closest(".delete");
    if ($target.parent().hasClass("input_wrapper") &&
        $target.parent().parent().find(".input_wrapper").length === 1) {
      return;
    }

    $target.next().css("display", "block");
    $target.next().next().css("display", "block");
  });

  $("form").on("click", "button.cancel, .overlay", event => {
    event.preventDefault();

    let $target = $(event.target);
    if ($target.hasClass("cancel")) {
      $target.closest(".dialog").css("display", "none");
      $target.closest(".dialog").next().css("display", "none");
    } else {
      $target.closest(".overlay").css("display", "none");
      $target.closest(".overlay").prev().css("display", "none");
    }
  });

  $("form").on("click", "button.confirm", event => {
    event.preventDefault();

    $container = $(event.target).parent().parent();

    if ($container.hasClass("input_wrapper")) {
      $container.remove();
    } else if ($container.hasClass("category_name")) {
      $container = $container.parent();
      $input_wrappers = $container.find(".input_wrapper");

      if ($(".category_wrapper").length === 1) {
        $container.css("display", "none");
        $input_wrapper = $input_wrappers.first();
        $input_wrappers.remove();

        $input_wrapper.find("input").val("").removeClass("invalid");
        $input_wrapper.find("select").val("daily");
        $container.find(".category_name").after($input_wrapper);

        $container.find(".dialog, .overlay").css("display", "none");
        $("#save_expenses fieldset ~ button").css("display", "none");
      } else {
        $container.remove();
      }
    }
  });

  $("#save_income").submit(event => {
    event.preventDefault();

    $(".flash").remove();
    $(".invalid").removeClass("invalid");

    $inputs = $(event.target).find("input");
    $name_inputs = $inputs.filter((_, input) => $(input).attr("id").includes("name"));

    let messages = [];
    let message;
    $inputs.each((_, input) => {
      let $input = $(input);
      let value = $input.val().trim();

      if (value === "") {
        $input.addClass("invalid");
        message = "Please provide the missing details.";
        if (!messages.includes(message)) messages.push(message);
      } else if ($input.attr("id").includes("name") &&
                 $name_inputs.filter((_, input) => $(input).val() === value).length > 1) {
        $input.addClass("invalid");
        message = "Income names must be unique."
        if (!messages.includes(message)) messages.push(message);
      }
    });

    if ($("input.invalid").length > 0) {
      if ($(".flash.error").length < 1) {
        messages.forEach(message => {
          $("body > header").after($(`<div class = 'flash error'><p>${message}</p></div>`));
        });
      }
    } else {
      event.target.submit();
    }
  });

  $("#add_category").submit(event => {
    event.preventDefault();

    $(".flash").remove();

    let category = $(event.target).find("input").val().trim();

    $category_wrapper = $("#save_expenses .category_wrapper");

    if (category === "") {
      return;
    } else if ($category_wrapper.filter(function() { return $(this).find(".category_name input").val() === snakify(category) }).length > 0) {
      $("body > header").after($(`<div class = 'flash error'><p>Category names must be unique.</p></div>`));
      return;
    }

    if ($category_wrapper.length === 1 && $category_wrapper.css("display") === "none") {
      $category_wrapper.find(".category_name h3").text(category);
      $category_wrapper.find(".category_name input").attr("id", "category_name_1")
                                                    .attr("name", "category_name_1")
                                                    .val(snakify(category));
      $category_wrapper.find(".input_wrapper").find("label, input, select").each((_, element) => {
        let $element = $(element);
        if (element.tagName === "LABEL") {
          let old_category = $element.attr("for").split(/_(name|amount|occurance)_\d+$/)[0];
          
          $element.attr("for", $element.attr("for").replace(old_category, snakify(category)));
          $element.attr("for", $element.attr("for").replace(/\d+$/, "1"));
        } else {
          let old_category = $element.attr("name").split(/_(name|amount|occurance)_\d+$/)[0];
          
          $element.attr("id", $element.attr("id").replace(old_category, snakify(category)));
          $element.attr("id", $element.attr("id").replace(/\d+$/, "1"));
          $element.attr("name", $element.attr("name").replace(old_category, snakify(category)));
          $element.attr("name", $element.attr("name").replace(/\d+$/, "1"));
        }
      });

      $category_wrapper.css("display", "block");
      $("#save_expenses fieldset ~ button").css("display", "block");
    } else {
      $new_category_wrapper = $category_wrapper.last().clone();
      $new_input_wrapper = $new_category_wrapper.find(".input_wrapper").last();
      $new_input_wrapper.find("input").val("").removeClass("invalid");
      $new_input_wrapper.find("select").val("daily");
      $new_input_wrapper.find("input, select, label").each((_, element) => {
        let $element = $(element);
        if (element.tagName === "LABEL") {
          let old_category = $element.attr("for").split(/_(name|amount|occurance)_\d+$/)[0];

          $element.attr("for", $element.attr("for").replace(old_category, snakify(category)));
          $element.attr("for", $element.attr("for").replace(/\d+$/, "1"));
        } else {
          let old_category = $element.attr("name").split(/_(name|amount|occurance)_\d+$/)[0];

          $element.attr("id", $element.attr("id").replace(old_category, snakify(category)));
          $element.attr("id", $element.attr("id").replace(/\d+$/, "1"));
          $element.attr("name", $element.attr("name").replace(old_category, snakify(category)));
          $element.attr("name", $element.attr("name").replace(/\d+$/, "1"));
        }
      });

      $new_category_wrapper.find(".input_wrapper").remove();
      $new_category_wrapper.find(".category_name").after($new_input_wrapper);

      $new_category_wrapper.find(".category_name h3").text(category);
      $new_category_name_input = $new_category_wrapper.find(".category_name input");
      $new_category_name_input.attr("id", $new_category_name_input.attr("id").replace(/\d+$/, num => String(Number(num) + 1)));
      $new_category_name_input.attr("name", $new_category_name_input.attr("name").replace(/\d+$/, num => String(Number(num) + 1)));
      $new_category_name_input.val(snakify(category));

      $new_category_wrapper.css("display", "block");
      $category_wrapper.last().after($new_category_wrapper);
    }

    event.target.reset();
  });

  $("#save_expenses").submit(event => {
    event.preventDefault();

    $(".flash").remove();
    $(".invalid").removeClass("invalid");

    let messages = [];
    let message;
    $("#save_expenses .category_wrapper").each((_, category_wrapper) => {
      $inputs = $(category_wrapper).find(".input_wrapper input");
      $name_inputs = $inputs.filter((_, input) => $(input).attr("id").includes("name"));

      $inputs.each((_, input) => {
        let $input = $(input);
        let value = $input.val().trim();
  
        if (value === "") {
          $input.addClass("invalid");
          message = "Please provide the missing details.";
          if (!messages.includes(message)) messages.push(message);
        } else if ($input.attr("id").includes("name") &&
                   $name_inputs.filter((_, input) => $(input).val() === value).length > 1) {
          $input.addClass("invalid");
          message = "Expense names must be unique."
          if (!messages.includes(message)) messages.push(message);
        }
      });
    });

    if ($("input.invalid").length > 0) {
      messages.forEach(message => {
        $("body > header").after($(`<div class = 'flash error'><p>${message}</p></div>`));
      });
    } else {
      event.target.submit();
    }
  });
});
