import { supabaseClient } from "@supabase/auth-helpers-nextjs";

function toCSV(data: object[]): string {
    const header = Object.keys(data[0]).map(String) 
    const dataToTuple = [header, ...data.map(row => Object.values(row).map(String))]
    return dataToTuple.map(row =>
      row
      .map(v => v.replaceAll('"', '""')) 
      .map(v => `"${v}"`) 
      .join(',') 
    ).join('\r\n'); 
  }
  
  export function downloadCSV(content: string): void {
    const uriEncodedContents =
      'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(content)
      const downloadLink = document.createElement('a')
      downloadLink.href = uriEncodedContents
      downloadLink.download = 'export.csv'
      downloadLink.click()
  }
  
  const getExportData =  (username: string) =>  supabaseClient
  .from("csv_export")
  .select("*")
  .eq("username", username)

  export const getExportCSVByUsername = async (username: string) => {
    const { data } = await getExportData(username)
    if (data) {
        downloadCSV(toCSV(data))
    }

  };