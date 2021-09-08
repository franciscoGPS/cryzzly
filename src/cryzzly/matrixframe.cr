require "num"
require "./any"
require "./utils/*"
require "aquaplot"



class Matrixframe < Dataframe(Array(Array(Int8 | Int16 | Int32 | Int64 | Float32 | Float64)))

  getter headers : Array(String)
  getter index_col : Int32

  def self.resolve_matrix_type
    [] of Array(  Int8 | Int16 | Int32 | Int64 | Float32 | Float64)
  end

 def initialize(data, headers = [] of String, index_col = -1, col_type = Float64)
    @headers = headers
    @data = data
    @col_type = col_type
    @index_col = index_col
    begin
      Tensor.from_array(data)
    rescue ex
      pp ex.message
      return
    end
  end
  
  def self.load_csv(filename, index_col = -1, index_type="datetime", index_format="%Y-%m-%d %H:%M:%S", headers = true, col_type = Float64 )
    pp "Loading CSV File"
    pp "Filename: " + filename
    pp "Index column: " + index_col.to_s
    pp "Index type: " + index_type.to_s
    pp "Index format: " + index_format.to_s
  
    data = resolve_matrix_type
    headers_array = [] of String
    headers = true
    headers_array = each_csv_row(filename, headers: headers) do |parser|
      temp_row = [] of Int8 | Int16 | Int32 | Int64 | Float32 | Float64
      consider_index = parse_index?(index_type, col_type)
      parser.row.to_a.each_with_index do  |val, index|
  
        if consider_index && index == index_col
          parsed =  parse_index_column(val, index_type, index_format)
        else
          parsed = parse_col(val, col_type)
        end
        temp_row.push(parsed)
      end
      data.push(temp_row)
    end
    if headers_array.empty? 
      size = data[0].size || 1
      headers_array = gen_col_names(size)
    end 
  
    Matrixframe.new(data, headers_array, index_col, col_type)
  end

  def self.parse_index_column(value, index_type, index_format)
    def_tz = Time::Location.load("America/Chihuahua")
    begin
      if index_type == "datetime"
        parsed = Time.parse(value, index_format, def_tz).to_unix_ms.to_f
      elsif 
        parsed = value.to_f
      end
    rescue ex
      pp "error" 
      print ex.message
      parsed = 0.0
    ensure
      #report_value_error(value, index_type)
    end
    parsed
  end

  def self.parse_col(val, col_type)
    case col_type
    when "Int8"
      Int8.new(val)
    when "Int16"
      Int16.new(val)
    when "Int32"
      Int32.new(val)
    when "Int64"
      Int64.new(val)
    when "Float32"
      Float32.new(val)
    when "Float64"
      Float64.new(val)
    else
      Float64.new(val)
    end
  end
  
  private def each_row
    @data.as(Array).each do |row|
      yield row
    end
  end

  def self.parse_index?(index_type, col_type)
    index_type == "datetime" && col_type != nil
  end

  def shape
    #[columns number, size of each column
    [length, @data.size]
  end

  def length
    #columns number
    
    @data[0].size#.this.as(Array).size
  end


  def mean(*columns : String)
    avgs = {} of String => Int8 | Int16 | Int32 | Int64 | Float32 | Float64
    column_size = shape[1]
    sum(*columns).data[0].each_with_index do |sum, index|
      avgs[columns[index]] = sum / column_size if column_size > 0
    end
    Matrixframe.new([avgs.values], avgs.keys )
  end

  def sum(*columns : String )
    sums = {} of String =>  Int8 | Int16 | Int32 | Int64 | Float32 | Float64
    to_array(*columns).each_with_index do |array_tuple, index|
      sums[columns[index]] = array_tuple[1].sum       
    end
    Matrixframe.new([sums.values], sums.keys)
  end

  def min(*columns : String)
    mins = {} of String => Int8 | Int16 | Int32 | Int64 | Float32 | Float64
    to_array(*columns).each_with_index do |array_tuple, index|
      mins[columns[index]] =  array_tuple[1].min 
    end
    Matrixframe.new([mins.values], mins.keys)
  end

  def max(*columns : String)
    maxs = {} of String => Int8 | Int16 | Int32 | Int64 | Float32 | Float64
    to_array(*columns).each_with_index do |array_tuple, index|
      maxs[columns[index]] = array_tuple[1].max       
    end
    Matrixframe.new([maxs.values], maxs.keys)
  end

  private def to_array(*columns : String)
    arrays = {} of String => Array(Float32 | Float64 | Int16 | Int32 | Int64 | Int8)
    indexes = find_indexes(*columns)
    indexes.each_with_index do |col, index|
      series = [] of Float32 | Float64 | Int16 | Int32 | Int64 | Int8
      each_row do |row|
        value = row.as(Array)[col.first_value]
        begin
          series.push(value)
        rescue ex
          pp ex
          pp "Not a float: " + @headers[col.first_value] + " row: "  + index.to_s
        end
        arrays[col.first_key] = series
      end
    end
    arrays
  end
end