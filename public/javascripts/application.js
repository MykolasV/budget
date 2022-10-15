$(()=> {
  $("form").on("click", ".add_input", event => {
    event.preventDefault();

    let $inputWrapper = $(event.target).prev();
    let $newInputWrapper = $inputWrapper.clone();
    $newInputWrapper.find("input").removeClass("invalid");

    $newInputWrapper.find("label, input, select").each((_, element) => {
      let $element = $(element);

      if ($element.prop("tagName") === "LABEL") {
        $element.attr("for", $element.attr("for").replace(/\d+$/, num => String(Number(num) + 1)));
      } else {
        $element.attr("id", $element.attr("id").replace(/\d+$/, num => String(Number(num) + 1)));
        $element.attr("name", $element.attr("name").replace(/\d+$/, num => String(Number(num) + 1)));
        
        if ($element.prop("tagName") === "INPUT") {
          $element.val("");
          if ($element.attr("id").includes("name")) $element.attr("data-previous-value", "");
        } else {
          element.selected = false;
        }
      }
    });

    $(event.target).before($newInputWrapper);
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
      let $inputWrappers = $container.find(".input_wrapper");

      $invalidInputs = $container.find(".invalid");
      $allEmpty = $(".invalid.empty");
      $duplicates = $container.find(".invalid.duplicate");

      if ($(".category_wrapper").length === 1) {
        $container.css("display", "none");
        $container.find(".category_name h3").text("")
        $container.find(".category_name input").val("")

        let $inputWrapper = $inputWrappers.first();
        $inputWrappers.remove();

        $inputWrapper.find("input").val("").removeClass("invalid");
        $inputWrapper.find("input").each((_, input) => {
          let $input = $(input);
          if ($input.attr("id").includes("name")) $input.attr("data-previous-value", "");
        });
  
        $inputWrapper.find("select").val("daily");
        $container.find(".category_name").after($inputWrapper);

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

    $categoryWrapper = $("#save_expenses .category_wrapper");

    if (category === "") {
      return;
    } else if ($categoryWrapper.filter(function() { return $(this).find(".category_name input").val() === snakify(category) }).length > 0) {
      $("body > header").after($(`<div class = 'flash error'><p>Category names must be unique.</p></div>`));
      return;
    }

    if ($categoryWrapper.length === 1 && $categoryWrapper.css("display") === "none") {
      $categoryWrapper.find(".category_name h3").text(category);
      $categoryWrapper.find(".category_name input").attr("id", "category_name_1")
                                                    .attr("name", "category_name_1")
                                                    .val(snakify(category));
      $categoryWrapper.find(".input_wrapper").find("label, input, select").each((_, element) => {
        let $element = $(element);
        if ($element.prop("tagName") === "LABEL") {
          let oldCategory = $element.attr("for").split(/_(name|amount|occurance)_\d+$/)[0];
          
          $element.attr("for", $element.attr("for").replace(oldCategory, snakify(category)));
          $element.attr("for", $element.attr("for").replace(/\d+$/, "1"));
        } else {
          let oldCategory = $element.attr("name").split(/_(name|amount|occurance)_\d+$/)[0];
          
          $element.attr("id", $element.attr("id").replace(oldCategory, snakify(category)));
          $element.attr("id", $element.attr("id").replace(/\d+$/, "1"));
          $element.attr("name", $element.attr("name").replace(oldCategory, snakify(category)));
          $element.attr("name", $element.attr("name").replace(/\d+$/, "1"));

          if ($element.prop("tagName") === "INPUT" && element.id.includes("name")) $element.attr("data-previous-value", "");
        }
      });

      $categoryWrapper.css("display", "block");
      $("#save_expenses fieldset ~ button").css("display", "block");
    } else {
      $newCategoryWrapper = $categoryWrapper.last().clone();
      $newInputWrapper = $newCategoryWrapper.find(".input_wrapper").last();
      $newInputWrapper.find("input").val("").removeClass("invalid");
      $newInputWrapper.find("select").val("daily");
      $newInputWrapper.find("input, select, label").each((_, element) => {
        let $element = $(element);
        if ($element.prop("tagName") === "LABEL") {
          let oldCategory = $element.attr("for").split(/_(name|amount|occurance)_\d+$/)[0];

          $element.attr("for", $element.attr("for").replace(oldCategory, snakify(category)));
          $element.attr("for", $element.attr("for").replace(/\d+$/, "1"));
        } else {
          let oldCategory = $element.attr("name").split(/_(name|amount|occurance)_\d+$/)[0];

          $element.attr("id", $element.attr("id").replace(oldCategory, snakify(category)));
          $element.attr("id", $element.attr("id").replace(/\d+$/, "1"));
          $element.attr("name", $element.attr("name").replace(oldCategory, snakify(category)));
          $element.attr("name", $element.attr("name").replace(/\d+$/, "1"));

          if ($element.prop("tagName") === "INPUT" && element.id.includes("name")) $element.attr("data-previous-value", "");
        }
      });

      $newCategoryWrapper.find(".input_wrapper").remove();
      $newCategoryWrapper.find(".category_name").after($newInputWrapper);

      $newCategoryWrapper.find(".category_name h3").text(category);
      $newCategoryNameInput = $newCategoryWrapper.find(".category_name input");
      $newCategoryNameInput.attr("id", $newCategoryNameInput.attr("id").replace(/\d+$/, num => String(Number(num) + 1)));
      $newCategoryNameInput.attr("name", $newCategoryNameInput.attr("name").replace(/\d+$/, num => String(Number(num) + 1)));
      $newCategoryNameInput.val(snakify(category));

      $newCategoryWrapper.css("display", "block");
      $categoryWrapper.last().after($newCategoryWrapper);
    }

    event.target.reset();
  });

  $("#save_income, #save_expenses").submit(event => {
   event.preventDefault();

    $(".flash").remove();
    $(".invalid").removeClass("invalid").removeClass("empty").removeClass("duplicate");

    if ($(".category_wrapper").length > 0) {
      $(".category_wrapper").each((_, categoryWrapper) => {
        let $inputs = $(categoryWrapper).find(".input_wrapper input");
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

  $(".amount").each((_, amount) => {
    let $amount = $(amount);
    $amount.text(parseFloat($amount.text()).toLocaleString());
  });

  $("select#occurance").change(event => {
    $(".flash").remove();

    let $select = $(event.target);
    let prevOccurance = $select.attr("data-occurance");
    let newOccurance = $select.find("option:selected").val();

    $(".amount").each((_, amount) => {
      let $amount = $(amount);
      let value = parseFloat($amount.text().replace(/,/g, ""));
      let newValue = parseFloat(convertAmount(value, prevOccurance, newOccurance));
      $amount.text(newValue.toLocaleString());
    });

    $select.attr("data-occurance", newOccurance);
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

  function convertAmount(amount, occurance, newOccurance) {
    function isLeapYear(year) {
      return year % 400 === 0 || (year % 100 !== 0 && year % 4 === 0);
    }

    const YEAR = new Date().getFullYear();
    const DAYS_IN_YEAR = isLeapYear(YEAR) ? 366 : 365;
    const WEEKS_IN_YEAR = DAYS_IN_YEAR / 7;

    let newAmount;

    if (newOccurance === "daily") {
      if (occurance === "weekly") {
        newAmount = amount / 7;
      } else if (occurance === "fortnightly") {
        newAmount = amount * 14;
      } else if (occurance === "monthly") {
        newAmount = (amount * 12) / DAYS_IN_YEAR;
      } else if (occurance === "quarterly") {
        newAmount = (amount * 4) / DAYS_IN_YEAR;
      } else if (occurance === "six_monthly") {
        newAmount = (amount * 2) / DAYS_IN_YEAR;
      } else if (occurance === "yearly") {
        newAmount = amount / DAYS_IN_YEAR;
      } else {
        newAmount = amount;
      }
    } else if (newOccurance === "weekly") {
      if (occurance === "daily") {
        newAmount = amount * 7;
      } else if (occurance === "fortnightly") {
        newAmount = amount / 2;
      } else if (occurance === "monthly") {
        newAmount = (amount * 12) / WEEKS_IN_YEAR;
      } else if (occurance === "quarterly") {
        newAmount = (amount * 4) / WEEKS_IN_YEAR;
      } else if (occurance === "six_monthly") {
        newAmount = (amount * 2) / WEEKS_IN_YEAR;
      } else if (occurance === "yearly") {
        newAmount = amount / WEEKS_IN_YEAR;
      } else {
        newAmount = amount;
      }
    } else if (newOccurance === "fortnightly") {
      if (occurance === "daily") {
        newAmount = amount * 14;
      } else if (occurance === "weekly") {
        newAmount = amount * 2;
      } else if (occurance === "monthly") {
        newAmount = ((amount * 12) / WEEKS_IN_YEAR) * 2;
      } else if (occurance === "quarterly") {
        newAmount = ((amount * 4) / WEEKS_IN_YEAR) * 2;
      } else if (occurance === "six_monthly") {
        newAmount = ((amount * 2) / WEEKS_IN_YEAR) * 2;
      } else if (occurance === "yearly") {
        newAmount = (amount / WEEKS_IN_YEAR) * 2;
      } else {
        newAmount = amount;
      }
    } else if (newOccurance === "monthly") {
      if (occurance === "daily") {
        newAmount = (amount * DAYS_IN_YEAR) / 12;
      } else if (occurance === "weekly") {
        newAmount = (amount * WEEKS_IN_YEAR) / 12;
      } else if (occurance === "fortnightly") {
        newAmount = ((amount / 2) * WEEKS_IN_YEAR) / 12;
      } else if (occurance === "quarterly") {
        newAmount = (amount * 4) / 12;
      } else if (occurance === "six_monthly") {
        newAmount = (amount * 2) / 12;
      } else if (occurance === "yearly") {
        newAmount = amount / 12;
      } else {
        newAmount = amount;
      }
    } else if (newOccurance === "quarterly") {
      if (occurance === "daily") {
        newAmount = amount * (DAYS_IN_YEAR / 4);
      } else if (occurance === "weekly") {
        newAmount = amount * (WEEKS_IN_YEAR / 4);
      } else if (occurance === "fortnightly") {
        newAmount = (amount / 2) * (WEEKS_IN_YEAR / 4);
      } else if (occurance === "monthly") {
        newAmount = amount * 3;
      } else if (occurance === "six_monthly") {
        newAmount = amount / 2;
      } else if (occurance === "yearly") {
        newAmount = amount / 4;
      } else {
        newAmount = amount;
      }
    } else if (newOccurance === "six_monthly") {
      if (occurance === "daily") {
        newAmount = (amount * DAYS_IN_YEAR) / 2;
      } else if (occurance === "weekly") {
        newAmount = (amount * WEEKS_IN_YEAR) / 2;
      } else if (occurance === "fortnightly") {
        newAmount = ((amount / 2) * WEEKS_IN_YEAR) / 2;
      } else if (occurance === "monthly") {
        newAmount = amount * 6;
      } else if (occurance === "quarterly") {
        newAmount = amount * 2;
      } else if (occurance === "yearly") {
        newAmount = amount / 2;
      } else {
        newAmount = amount;
      }
    } else if (newOccurance === "yearly") {
      if (occurance === "daily") {
        newAmount = amount * DAYS_IN_YEAR;
      } else if (occurance === "weekly") {
        newAmount = amount * WEEKS_IN_YEAR;
      } else if (occurance === "fortnightly") {
        newAmount = (amount / 2) * WEEKS_IN_YEAR;
      } else if (occurance === "monthly") {
        newAmount = amount * 12;
      } else if (occurance === "quarterly") {
        newAmount = amount * 4;
      } else if (occurance === "six_monthly") {
        newAmount = amount * 2;
      } else {
        newAmount = amount;
      }
    }

    return newAmount.toFixed(2);
  }
});
