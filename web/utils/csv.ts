export function downloadCSV(content: string): void {
    const uriEncodedContents =
      "data:text/csv;charset=utf-8,%EF%BB%BF" + encodeURIComponent(content);
    const downloadLink = document.createElement("a");
    downloadLink.href = uriEncodedContents;
    downloadLink.download = "export.csv";
    downloadLink.click();
  }
  