let isFullscreen = false;

const handleFullscreen = () => {
  let main = document.querySelector("main");
  let nav = document.querySelector("nav");

  if (isFullscreen) {
    main.style.width = "";
    nav.style.display = "";
  } else {
    main.style.width = "100%";
    nav.style.display = "none";
  }

  isFullscreen = !isFullscreen;
}

document.addEventListener("keypress", function onPress(event) {
  switch (event.key) {
    case "f":
      handleFullscreen();
      break;
    case "i":
      window.location = "/";
      break;
    case "r":
      window.location.reload();
      break;
    default:
    console.log(`unhandled keypress: ${event.key}`);
  }
});
