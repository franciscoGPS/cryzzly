#Matrix.new
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

pp df.max(["col1", "col2", "col3", "col4"])
def_tz = Time::Location.load("America/Chihuahua")

result = df.filter(["date", "col4", "col5"]) do |hash|
  hash["col5"].val == "c" &&
  Time.parse(hash["date"].val.as(String), "%Y-%m-%d %H:%M:%S", Time::Location::UTC) >= Time.parse("2020-02-01 12:02:47.0", "%Y-%m-%d %H:%M:%S", Time::Location::UTC)
end

pp result

result = df.filter(["date", "col4", "col5"]) do |hash|
  hash["col5"].val == "c" &&
  Time.parse(hash["date"].val.as(String), "%Y-%m-%d %H:%M:%S", Time::Location::UTC) >= Time.parse("2020-02-01 12:02:47.0", "%Y-%m-%d %H:%M:%S", Time::Location::UTC)
end

pp result

pp result.sum(["col4"]) 
result = df.filter(["date", "col5","col2"]) do |value|
  true
end
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
#pp matrix 

result = df.filter(["col4", "col5"]) do |hash|
  hash["col5"].val == "c"
end

mult_filter = result.transform(["col4"]) do |val|
  val.as(Float64) * 0.001
end

#pp mult_filter



pp sorted

pp df.head

pp df.first(50)

pp df.first(3)


pp df.tail

pp df.last(50)

pp df.last(3)

arrays = [] of Array(Float64)

col3 = [] of Float64
col4 = [] of Float64

df.strip_fields(["col3", "col4"]) do |key, val|
  if key == "col3" 
    col3 << val.as(Float64)
  else
    col4 << val.as(Float64)
  end
end
arrays << col3
arrays << col4

pp arrays.to_tensor

t3 = col3.to_tensor
t4 = col4.to_tensor

puts  t3 + t4

a = [1, 2, 3, 4].to_tensor
b = [[3, 4, 5, 6], [5, 6, 7, 8]].to_tensor

puts a + b

pp df[["col3", "col4"]]


sorted = df.sort_by("col1") do |item2|
  
end

pp sorted