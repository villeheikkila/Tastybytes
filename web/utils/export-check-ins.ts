import { supabaseClient } from "@supabase/auth-helpers-nextjs";

export function downloadCSV(content: string): void {
  const uriEncodedContents =
    "data:text/csv;charset=utf-8,%EF%BB%BF" + encodeURIComponent(content);
  const downloadLink = document.createElement("a");
  downloadLink.href = uriEncodedContents;
  downloadLink.download = "export.csv";
  downloadLink.click();
}

export const getExportCSVByUsername = async (username: string) => {
  const { data } = await supabaseClient
    .from("csv_export")
    .select("*")
    .eq("username", username)
    .csv();

  if (data) {
    downloadCSV(data);
  }
};
