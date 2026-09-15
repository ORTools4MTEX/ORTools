document.addEventListener("DOMContentLoaded", function () {
  // Add target="_blank" and rel="noopener noreferrer" to all external links
  document.querySelectorAll("a[href]").forEach(function (link) {
    var href = link.getAttribute("href");
    // Only process absolute external URLs (http/https) that don't point to this site
    if (
      href &&
      (href.startsWith("http://") || href.startsWith("https://")) &&
      !href.includes("ortools4mtex.github.io")
    ) {
      link.setAttribute("target", "_blank");
      link.setAttribute("rel", "noopener noreferrer");
    }
  });
});
