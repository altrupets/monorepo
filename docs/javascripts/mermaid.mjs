import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";

mermaid.initialize({
  startOnLoad: false,
  theme: "base",
  securityLevel: "loose",
  flowchart: {
    useMaxWidth: false,
  },
  sequenceDiagram: {
    useMaxWidth: false,
  },
});

document.addEventListener("DOMContentLoaded", () => {
  mermaid.run({
    querySelector: ".mermaid",
  });
});
