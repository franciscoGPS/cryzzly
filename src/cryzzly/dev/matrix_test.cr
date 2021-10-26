#Matrix.new
require "./../*"
require "./*"


filename = "./src/cryzzly/dev/sample.csv"

cols = ["datetime", "Int32", "Int32", "Float64", "Float64", "String"]

df = Matrix.load_csv(filename, index_col: 0, index_type: "datetime", cols_types: cols )

pp df.sum("col1", "col2", "col3", "col4")
#
pp df.mean("col1", "col2", "col3", "col4")

pp df.min("col1", "col2", "col3", "col4")

pp df.max("col1", "col2", "col3", "col4")

result = df.select("col5", "col2", "col1", "col3", "col4") do |value, column, value_type|
  column.first_key == "col5" && value == "a" || 
  column.first_key == "col3" && value.as(Float64) >= 0.71
end

pp result



