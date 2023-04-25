import ready from "custom/main";

ready(() => {
  let element = document.getElementById("turing-module-select");
  if (element !== null) {
    document.getElementById("turing-module-select").addEventListener("change", event => {
      const moduleID = event.target.selectedOptions[0].value
      window.location.href = `/modules/${moduleID}`
    });
  }
  
  element = document.getElementById("redo-setup");
  if (element !== null) {
    document.getElementById("redo-setup").addEventListener("click", event => {
      event.preventDefault();
      if (confirm("Are you sure?") == true) {
        window.location = event.target.href
      } 
    });
  }
});
