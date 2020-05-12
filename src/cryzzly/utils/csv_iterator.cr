#will return headers if headers = true 
def each_csv_row(filename, headers) : Array(String)
  File.open(filename) do |infile|
    csv_rows = CSV.new(infile, headers: headers)
    csv_rows.each do |row|
      yield row
    end
    return csv_rows.headers if headers
    return [] of String
  end
end