#Matrix.new
require "./../*"
require "./*"


filename = "./src/cryzzly/dev/sample.csv"

#df = Matrix(Any).load_csv(filename, index_col: 0, index_type: "datetime")
#pp df.sum("col1", "col2", "col3", "col4")
#
#pp df.mean("col1", "col2", "col3", "col4")

df = Matrix.load_csv(filename, index_col: 0, index_type: "datetime", col_type: ["datetime", "Int32", "Int32", "Float64", "Float64", "String"])

pp df.sum("col1", "col2", "col3", "col4")
#
pp df.mean("col1", "col2", "col3", "col4")

