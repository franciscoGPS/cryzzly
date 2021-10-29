#Matrix.new
require "./../*"
require "./*"


filename = "./src/cryzzly/dev/sample.csv"

cols = ["Time", "Int32", "Int32", "Float64", "Float64", "String"]

df = Matrix.load_csv(filename, index_col: 0, index_type: "Time", col_types: cols )
#pp df 
#
pp df.sum(["col1", "col2", "col3", "col4"])
#
pp df.mean(["col1", "col2", "col3", "col4"])

pp df.min(["col1", "col2", "col3", "col4"])

pp df.max(["col1", "col2", "col3", "col4"])

result = df.select(["col4"]) do |hash|
  hash["col5"] == "c"
end

pp result
#result = df.select("date", "col5","col2") do |value, column, value_type|
#  true
#end

#pp result
#result.each do |i|
#
#  i 
#end

