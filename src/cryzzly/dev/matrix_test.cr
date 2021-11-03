#Matrix.new
require "./../*"
require "./*"


filename = "./src/cryzzly/dev/sample.csv"

cols = ["Time", "Int32", "Int32", "Float64", "Float64", "String"]

df = Matrix.load_csv(filename, index_col: 0, index_type: "Time", col_types: cols )
#pp df 
#
#pp df.sum(["col1", "col2", "col3", "col4"])
##
#pp df.mean(["col1", "col2", "col3", "col4"])
#
#pp df.min(["col1", "col2", "col3", "col4"])
#
#pp df.max(["col1", "col2", "col3", "col4"])
def_tz = Time::Location.load("America/Chihuahua")

result = df.select(["date", "col4", "col5"]) do |hash|
  hash["col5"].val == "c" &&
  Time.parse(hash["date"].val.as(String), "%Y-%m-%d %H:%M:%S", Time::Location::UTC) >= Time.parse("2020-02-01 12:02:47.0", "%Y-%m-%d %H:%M:%S", Time::Location::UTC)
end


result = df.select(["date", "col4", "col5"]) do |hash|
  hash["col5"].val == "c" &&
  Time.parse(hash["date"].val.as(String), "%Y-%m-%d %H:%M:%S", Time::Location::UTC) >= Time.parse("2020-02-01 12:02:47.0", "%Y-%m-%d %H:%M:%S", Time::Location::UTC)
end

pp result
##TODO:/ Set coltype
pp result.sum(["col4"]) 


#result = df.select("date", "col5","col2") do |value, column, value_type|
#  true
#end
sorted = nil

df.sort(["col4"]) do |sorted_col|
  sorted = sorted_col
end



matrix =df.sort(["col5"]) do |sorted_col|
  sorted = sorted_col
end


matrix = df.sort(["date"]) do |sorted_col|
  sorted = sorted_col
end
pp matrix 

result = df.select(["col4", "col5"]) do |hash|
  hash["col5"].val == "c"
end

mult_filter = result.transform(["col4"]) do |val|
  val.as(Float64) * 0.001
end

pp mult_filter
