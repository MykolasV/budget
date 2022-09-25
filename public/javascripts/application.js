$(()=> {
  $("#save_income .add_input").click(event => {
    event.preventDefault();

    console.log(event.target);
  });
});
