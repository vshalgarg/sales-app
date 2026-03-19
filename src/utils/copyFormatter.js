export const formatDetails = (data) => {

  const filteredEntries = Object.entries(data)
    .filter(([_, value]) => value !== undefined && value !== null && value !== "");

  const html = filteredEntries
    .map(([key, value]) => `<b>${key}:</b> ${value}<br/>`)
    .join("");

  const text = filteredEntries
    .map(([key, value]) => `${key}: ${value}`)
    .join("\n");

  return { html, text };
};

export const cleanText = (text) => {
  if (Array.isArray(text)) {
    return text.map(t => (typeof t === "string" ? t.replace(/\s+/g, " ").trim() : t));
  }

  if (typeof text === "string") {
    return text.replace(/\s+/g, " ").trim();
  }

  return text;
};

export const convertHtmlToWhatsApp = (html) => {
  if (!html) return "";

  return html
    .replace(/<b>(.*?)<\/b>/gi, "*$1*")
    .replace(/<strong>(.*?)<\/strong>/gi, "*$1*")
    .replace(/<i>(.*?)<\/i>/gi, "_$1_")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<\/p>/gi, "\n")
    .replace(/<li>(.*?)<\/li>/gi, "• $1\n")
    .replace(/<[^>]+>/g, "")
    .trim();
};