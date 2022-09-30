$(()=> {
  $("#save_income .add_input").click(event => {
    event.preventDefault();

    let $input_wrapper = $("#save_income fieldset").children(".input_wrapper").last();
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

    $("#save_income fieldset").append($new_input_wrapper);
  });

  $("#save_income").submit(event => {
    event.preventDefault();

    $(event.target).find("input").each((_, element) => {
      let $element = $(element);
      if ($element.val().trim() === "") {
        $element.addClass("invalid");
      }
    });

    if ($("input.invalid").length > 0) {
      if ($(".flash.error").length < 1) {
        $("body > header").after($("<div class = 'flash error'><p>Please provide the missing details.</p></div>"));
      }
    } else {
      event.target.submit();
    }
  });

  $("#save_income").on("blur", "input", event => {
    let $element = $(event.target);

    if ($element.val().trim() === "") {
      $element.addClass("invalid");
    } else {
      $element.removeClass("invalid");
    }
  });
});
