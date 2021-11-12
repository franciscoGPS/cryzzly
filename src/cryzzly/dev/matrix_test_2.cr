require "./../*"
require "./*"
require "num"


filename = "./src/cryzzly/dev/sample.csv"

cols = ["Time", "Int32", "Int32", "Float64", "Float64", "String"]

df = Matrix.load_csv(filename, index_col: 0, index_type: "Time", col_types: cols )
pp df 

pp df.sum(["col1", "col2", "col3", "col4"])
#
pp df.mean(["col1", "col2", "col3", "col4"])

pp df.min(["col1", "col2", "col3", "col4"])

max = df.max(["col1", "col2", "col3", "col4"])
def_tz = Time::Location.load("America/Chihuahua")

pp max["new_col"] = [1]

pp df.first(4)["new_int"] = [1,2,3,4]

pp df.first(4).add("new_float", [1.0,2.0,3.0,4.0])