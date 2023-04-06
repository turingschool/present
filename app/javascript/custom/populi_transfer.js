document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("populi-attendance-confirmation").addEventListener("click", event => {
    event.preventDefault();
    document.getElementById("populi-attendance-transfer").disabled = false;
  })
})