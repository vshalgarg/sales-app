export const downloadFile = ({ data, type, headers, defaultFileName }) => {
  let url;
  let link;
  try {
    const blob = new Blob([data], { type });
    url = window.URL.createObjectURL(blob);
    link = document.createElement("a");
    link.href = url;

    const disposition = headers?.["content-disposition"];
    let fileName = defaultFileName;
    if (disposition) {
      const match = disposition.match(/filename="?([^"]+)"?/);
      if (match) {
        fileName = match[1];
      }
    }

    link.download = fileName;
    document.body.appendChild(link);
    link.click();
  } finally {
    if (link) {
      link.remove();
    }
    if (url) {
      window.URL.revokeObjectURL(url);
    }
  }
};
