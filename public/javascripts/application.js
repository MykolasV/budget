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
          $element.find("option").first().attr("selected", true);
        }
      }
    });

    $(event.target).before($newInputWrapper);
  });

  $("#save_income, #save_expenses").on("blur", "input", event => {
    $(".flash").remove();

    let $input = $(event.target);
    let value = $input.val().toLowerCase().trim().replace(/\s+/g, " ");
    $input.val(value);
    let $container = $input.closest(".input_wrapper").parent();
    let $inputs = $container.find("input");

    let isAmountInput = $input.attr("id").includes("amount");

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
    } else if (isAmountInput && value.match(/^\d+\.{1}\d{3,}$/)) {
      value = value.match(/^\d+\.{1}\d{2}/)[0];
      $input.val(value);
      $input.removeClass("invalid").removeClass("empty");
    } else if (isAmountInput && value.match(/^\d+\.{1}\d{1}$/)) {
      value += "0"
      $input.val(value);
      $input.removeClass("invalid").removeClass("empty");
    } else {
      $input.removeClass("invalid").removeClass("empty").removeClass("duplicate");
    
      if (isAmountInput && value.slice(-3, -2) !== ".") $input.val(value + ".00");
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

    let $actions = $target.closest(".actions");

    if ($actions.length > 0) {
      $actions.next().css("display", "block").next().css("display", "block");
    } else {
      $target.next().css("display", "block").next().css("display", "block");
    }
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

    let $input = $(event.target).find("input");
    let category = $input.val().toLowerCase().trim().replace(/\s+/g, " ");

    $input.removeClass("invalid");
    $input.val(category);

    $categoryWrapper = $("#save_expenses .category_wrapper");

    if (category === "") {
      return;
    } else if ($categoryWrapper.filter((_, wrapper) => $(wrapper).find(".category_name input").val() === snakify(category)).length > 0) {
      $("body > header").after($(`<div class = 'flash error'><p>Category names must be unique.</p></div>`));
      $input.addClass("invalid");
      return;
    }

    if ($categoryWrapper.length === 1 && $categoryWrapper.css("display") === "none") {
      $categoryWrapper.find(".category_name h3").text(formatTitle(category));
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

      $newCategoryWrapper.find(".category_name h3").text(formatTitle(category));
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
    if ($amount.text().match(/\.\d{1}$/)) $amount.text($amount.text() + "0");
  });

  $("select#occurance").change(event => {
    $(".flash").remove();

    let $select = $(event.target);
    let selectedOccurance = $select.find("option:selected").val();

    $(".amount").each((_, amount) => {
      let $amount = $(amount);
      let monthlyValue = parseFloat($amount.attr("data-monthly-amount"));
      let newValue = convertAmountFromMonthly(monthlyValue, selectedOccurance);
      newValue = newValue.toLocaleString();
      if (newValue.match(/\.\d{1}$/)) newValue += "0";
      $amount.text(newValue);
    });

    $select.attr("data-occurance", selectedOccurance);
  });

  $("#save_expenses").on("click", ".category_name .edit", event => {
    event.preventDefault();

    let $target = $(event.target);
    let $container = $target.closest(".category_name");
    let $h3 = $container.find("h3");

    $h3.attr("contenteditable", true).focus();
  });

  $("#save_expenses").on("blur", ".category_name h3", event => {
    $(".flash").remove();

    let $target = $(event.target);
    let newCategory = $target.text().replace(/\s+/g, " ");

    if (newCategory === "") {
      $("body > header").after($(`<div class = 'flash error'><p>Please provide a new category name.</p></div>`));
      $target.focus();
      return;
    }

    let $duplicates = $(".category_name h3").filter((_, h3) => {
      return h3 !== $target[0] && $(h3).text().toLowerCase() === newCategory.toLowerCase();
    });

    if ($duplicates.length > 0) {
      $("body > header").after($(`<div class = 'flash error'><p>Category name exists.</p></div>`));
      $target.focus();
      return;
    }

    let $categoryWrapper = $target.closest(".category_wrapper");
    $categoryWrapper.find(".input_wrapper").find("label, input, select").each((_, element) => {
      let $element = $(element);

      if ($element.prop("tagName") === "LABEL") {
        let oldCategory = $element.attr("for").split(/_(name|amount|occurance)_\d+$/)[0];
        $element.attr("for", $element.attr("for").replace(oldCategory, snakify(newCategory)));
      } else {
        let oldCategory = $element.attr("name").split(/_(name|amount|occurance)_\d+$/)[0];
        $element.attr("id", $element.attr("id").replace(oldCategory, snakify(newCategory)));
        $element.attr("name", $element.attr("name").replace(oldCategory, snakify(newCategory)));
      }
    });

    $target.text(formatTitle(newCategory));
    $target.next("input").val(snakify(newCategory));
    $target.attr("contenteditable", false);
  });

  // ===== Helper Methods =====

  function formatTitle(name) {
    return name.trim().split(" ").map(str => str.replace(str[0], str[0].toUpperCase())).join(" ");
  }

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

  function convertAmountFromMonthly(amount, newOccurance) {
    function isLeapYear(year) {
      return year % 400 === 0 || (year % 100 !== 0 && year % 4 === 0);
    }

    const YEAR = new Date().getFullYear();
    const DAYS_IN_YEAR = isLeapYear(YEAR) ? 366 : 365;
    const WEEKS_IN_YEAR = DAYS_IN_YEAR / 7;

    let newAmount;

    if (newOccurance === "daily") {
      newAmount = (amount * 12) / DAYS_IN_YEAR;
    } else if (newOccurance === "weekly") {
      newAmount = (amount * 12) / WEEKS_IN_YEAR;
    } else if (newOccurance === "fortnightly") {
      newAmount = ((amount * 12) / WEEKS_IN_YEAR) * 2;
    } else if (newOccurance === "quarterly") {
      newAmount = amount * 3;
    } else if (newOccurance === "six_monthly") {
      newAmount = amount * 6;
    } else if (newOccurance === "yearly") {
      newAmount = amount * 12;
    } else {
      newAmount = amount;
    }

    return parseFloat(newAmount.toFixed(2));
  }
});
