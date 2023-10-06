import ready from "custom/main";

ready(() => {
  let buttons = Array.from(document.querySelectorAll(".remove-alias"));

  const warningMessage = "Warning! Removing this student's zoom alias could have effects on past attendances. You will need to retake any attendances that were affected."
  const handleClick = (event) => {
    event.preventDefault();
    if(confirm(warningMessage) == true) {
      debugger;
    }
  }
  
  buttons.forEach(button => {
    button.addEventListener("click", handleClick)
  })
});


