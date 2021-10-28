require "json"
require "./../*"

module Moo(T)
  def t
    T
  end
end

class Foo(U)
  include Moo(U)

  def initialize(@value : U)
  end
end
 
foo = Foo.new(1)
#pp foo.t

bar = Foo.new("1")
#pp bar.t

JSON.parse(%(["1", 1])).as_a

row = %({
    "line": ["1", 1, 1.0, "one"]
  }
)

#pull = JSON::PullParser.new(row)
#pp pull.read_begin_object 
#pp pull.read_object_key # => "line" 
#pp pull.read_begin_array
#pp pull.read_string # => "three"
#pp pull.read_int    # => 1
#pp pull.read_float  # => 1.0
#pp pull.read_string # => "three"
#pp pull.read_end_array

#pp pull.read_string # => "values"
#pp pull.read_begin_array

# Array(Foo(Int32) | Foo(String)).new' with type 
# Array(Foo(Int32) | Foo(String))

#filename = "./src/cryzzly/dev/sample.csv"
#
#df = Dataframe(Any).load_csv(filename, index_col: 0, index_type: "datetime")
#pp df.sum("col1", "col2", "col3", "col4")
#
#pp df.mean("col1", "col2", "col3", "col4")
#
#df = Matrixframe.load_csv(filename, index_col: 0, index_type: "datetime", col_type: Float64)
#
#pp df.sum("col1", "col2", "col3", "col4")
#
#pp df.mean("col1", "col2", "col3", "col4")


#def parse_index_column(value, index_type, index_format)
#  def_tz = Time::Location.load("America/Chihuahua")
#  begin
#    if index_type == "datetime"
#      parsed = Time.parse(value, index_format, def_tz).to_unix_ms.to_f
#    elsif 
#      parsed = value.to_f
#    end
#  rescue ex
#    pp "error" 
#    print ex.message
#    parsed = 0.0
#  ensure
#    #report_value_error(value, index_type)
#  end
#  parsed
#end
#
#def parse_col(val, col_type)
#  case col_type
#  when "Int8"
#    Int8.new(val)
#  when "Int16"
#    Int16.new(val)
#  when "Int32"
#    Int32.new(val)
#  when "Int64"
#    Int64.new(val)
#  when "Float32"
#    Float32.new(val)
#  when "Float64"
#    Float64.new(val)
#  else
#    Float64.new(val)
#  end
#end
#
#def resolve_row_type(col_type)
#  [] of Int8 | Int16 | Int32 | Int64 | Float32 | Float64
#  #case col_type
#  #when "Int8"
#  #  [] of Int8
#  #when "Int16"
#  #  [] of Int16
#  #when "Int32"
#  #  [] of Int32
#  #when "Int64"
#  #  [] of Int64
#  #when "Float32"
#  #  [] of Float32
#  #when "Float64"
#  #  [] of Float64
#  #else
#  #  [] of Float64
#  #end
#end
###
#def resolve_matrix_type
  #[] of Array( Int8 | Int16 | Int32 | Int64 | Float32 | Float64 )
#end
#
#def parse_index?(index_type, col_type)
#  index_type == "datetime" && col_type != nil
#end
#
#def load_csv(filename, index_col = -1, index_type="datetime", index_format="%Y-%m-%d %H:%M:%S", headers = true, col_type = nil )
#  pp "Loading CSV File"
#  pp "Filename: " + filename
#  pp "Index column: " + index_col.to_s
#  pp "Index type: " + index_type.to_s
#  pp "Index format: " + index_format.to_s
#
#  data = resolve_matrix_type
#  headers_array = [] of String
#  headers = true
#  headers_array = each_csv_row(filename, headers: headers) do |parser|
#    temp_row = resolve_row_type(col_type)
#    consider_index = parse_index?(index_type, col_type)
#    parser.row.to_a.each_with_index do  |val, index|
#
#      if consider_index && index == index_col
#        parsed =  parse_index_column(val, index_type, index_format)
#      else
#        parsed = parse_col(val, col_type)
#      end
#      temp_row.push(parsed)
#    end    
#    data.push(temp_row)
#  end
#  if headers_array.empty? 
#    size = data[0].size || 1
#    headers_array = gen_col_names(size)
#  end 
#
#  Matrixframe.new(data, headers_array, index_col, col_type)
#end

#def gen_col_names(num)
#  (1..num).map { |i| "col_#{i}" }
#end 