import "./style.css";
import logo from "./logo.svg";

document.querySelector<HTMLDivElement>("#app")!.innerHTML = `
  <div>
      <img src="${logo}" class="logo" alt="Logo" />
  </div>
`;
