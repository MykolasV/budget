$(()=> {
  $("#save_income .add_input").click(event => {
    event.preventDefault();

    let $input_wrapper = $("#save_income fieldset").children(".input_wrapper").last();
    let $new_input_wrapper = $input_wrapper.clone();

    $new_input_wrapper.find("label, input, select").each((_, element) => {
      let $element = $(element);

      if (element.tagName === "LABEL") {
        $element.attr("for", $element.attr("for").replace(/\d+$/, num => String(Number(num) + 1)));
      } else {
        $element.attr("id", $element.attr("id").replace(/\d+$/, num => String(Number(num) + 1)));
        $element.attr("name", $element.attr("name").replace(/\d+$/, num => String(Number(num) + 1)));
      }
    });

    $("#save_income fieldset").append($new_input_wrapper);
  });
});
