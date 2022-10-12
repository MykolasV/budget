$(()=> {
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
          $element.val("");
          if ($element.attr("id").includes("name")) $element.attr("data-previous-value", "");
        } else {
          element.selected = false;
        }
      }
    });

    $(event.target).before($new_input_wrapper);
  });

  $("#save_income, #save_expenses").on("blur", "input", event => {
    $(".flash").remove();

    let $input = $(event.target);
    let value = $input.val().trim();
    let $container = $input.closest(".input_wrapper").parent();
    let $inputs = $container.find("input");

    let isNameInput = $input.attr("id").includes("name");
    let $nameInputs;
    let $duplicates;
    let $previousValueDuplicates
    if (isNameInput) {
      $nameInputs = $inputs.filter((_, input) => $(input).attr("id").includes("name")); 
      $duplicates = $nameInputs.filter((_, input) => $input[0] !== input && $(input).val() === value);
      $previousValueDuplicates = $nameInputs.filter((_, input) => $input[0] !== input && $(input).val() === $input.attr("data-previous-value"));
    }

    if (value === "") {
      $input.addClass("invalid").addClass("empty").removeClass("duplicate");
    } else if (isNameInput && $duplicates.length > 0) {
      $input.addClass("invalid").addClass("duplicate").removeClass("empty");
      $duplicates.addClass("invalid").addClass("duplicate").removeClass("empty");
    } else {
      $input.removeClass("invalid").removeClass("empty").removeClass("duplicate");
    }

    if (isNameInput && $previousValueDuplicates.length === 1 && $previousValueDuplicates.val() !== value) {
      $previousValueDuplicates.removeClass("invalid").removeClass("duplicate");
    }

    if (isNameInput) $input.attr("data-previous-value", value);

    let message;
    if ($(".invalid.empty").length > 0) {
      message = "Please provide the missing details.";
      $("body > header").after($(`<div class = 'flash error'><p>${message}</p></div>`));
    }

    if ($(".invalid.duplicate").length > 0) {
      message = `${$container.hasClass("category_wrapper") ? "Expense" : "Income"} names must be unique.`;
      $("body > header").after($(`<div class = 'flash error'><p>${message}</p></div>`));
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

    let $container = $(event.target).parent().parent();
    let $invalidInputs;
    let $allEmpty;
    let $duplicates;

    if ($container.hasClass("input_wrapper")) {
      $invalidInputs = $container.find(".invalid");
      $allEmpty = $(".invalid.empty");
      $duplicates = $container.parent().find(".invalid.duplicate");

      $container.remove();
    } else if ($container.hasClass("category_name")) {
      $container = $container.parent();
      let $input_wrappers = $container.find(".input_wrapper");

      $invalidInputs = $container.find(".invalid");
      $allEmpty = $(".invalid.empty");
      $duplicates = $container.find(".invalid.duplicate");

      if ($(".category_wrapper").length === 1) {
        $container.css("display", "none");
        $container.find(".category_name h3").text("")
        $container.find(".category_name input").val("")

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

    if ($invalidInputs.length > 0) {
      if ($invalidInputs.hasClass("empty") && $allEmpty.length <= 1) {
        $(".flash.error").filter((_, error) => $(error).find("p").text().includes("missing details")).remove();
      }

      if ($invalidInputs.hasClass("duplicate") && $duplicates.length <= 2) {
        $duplicates.removeClass("invalid").removeClass("duplicate");
        $(".flash.error").filter((_, error) => $(error).find("p").text().includes("unique")).remove();
      }
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

          if (element.tagName === "INPUT" && element.id.includes("name")) $element.attr("data-previous-value", "");
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

          if (element.tagName === "INPUT" && element.id.includes("name")) $element.attr("data-previous-value", "");
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

  $("#save_income, #save_expenses").submit(event => {
   event.preventDefault();

    $(".flash").remove();
    $(".invalid").removeClass("invalid").removeClass("empty").removeClass("duplicate");

    if ($(".category_wrapper").length > 0) {
      $(".category_wrapper").each((_, category_wrapper) => {
        let $inputs = $(category_wrapper).find(".input_wrapper input");
        markInvalidInputs($inputs);
      });
    } else {
      let $inputs = $(".input_wrapper input");
      markInvalidInputs($inputs);
    }

    let message;
    if ($(".invalid.empty").length > 0) {
      message = "Please provide the missing details.";
      $("body > header").after($(`<div class = 'flash error'><p>${message}</p></div>`));
    }

    if ($(".invalid.duplicate").length > 0) {
      message = `${$(".category_wrapper").length > 0 ? "Expense" : "Income"} names must be unique.`;
      $("body > header").after($(`<div class = 'flash error'><p>${message}</p></div>`));
    }

    if ($(".invalid").length > 0) {
      return;
    } else {
      event.target.submit();
    }
  });

  // ===== Helper Methods =====

  function snakify(name) {
    return name.toLowerCase().split(" ").join("_");
  }

  function markInvalidInputs($inputs) {
    let $nameInputs = $inputs.filter((_, input) => $(input).attr("id").includes("name"));

    $inputs.each((_, input) => {
      let $input = $(input);
      let value = $input.val().trim();

      if (value === "") {
        $input.addClass("invalid").addClass("empty").removeClass("duplicate");
      } else if ($input.attr("id").includes("name") && 
                $nameInputs.filter((_, input) => $(input).val() === value).length > 1) {
        $input.addClass("invalid").addClass("duplicate").removeClass("empty");
      } else {
        $input.removeClass("invalid").removeClass("empty").removeClass("duplicate");
      }
    });
  }
});
