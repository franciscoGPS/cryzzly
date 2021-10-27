require "num"

require "./../utils/*"
require "aquaplot"

class Matrix
  include Calculations


  def self.resolve_matrix_type
    [] of Array(StoreTypes)
  end

  getter headers : Array(String)
  getter col_types : Array(String)
  getter index_col : Int32
  getter data : Array(Array(StoreTypes))

 def initialize(data, headers = [] of String, index_col = -1, col_types = [] of String)
    @headers = headers
    @data = data
    @col_types = col_types
    @index_col = index_col
    begin
      Tensor.from_array(data)
    rescue ex
      pp ex.message
      return
    end
  end

  def self.parse_index?(index_type, col_type, index_col)
    index_col > 0 && index_type == "datetime" && col_type != nil
  end
  
  def self.load_csv(filename, index_col = -1, index_type="datetime", index_format="%Y-%m-%d %H:%M:%S", headers = true, cols_types = [] of String )
    pp "Loading CSV File"
    pp "Filename: " + filename
    pp "Index column: " + index_col.to_s
    pp "Index type: " + index_type.to_s
    pp "Index format: " + index_format.to_s
  
    data = resolve_matrix_type
    headers_array = [] of String
    headers = true
    headers_array = each_csv_row(filename, headers: headers) do |parser|
      temp_row = [] of StoreTypes
      consider_index = parse_index?(index_type, cols_types, index_col)
      parser.row.to_a.each_with_index do  |val, index|
  
        if consider_index && index == index_col
          parsed =  parse_index_column(val, cols_types[index], index_format)
        else
          parsed = parse_col(val, cols_types[index])
        end
        temp_row.push(parsed)
      end
      data.push(temp_row) 
    end
    if headers_array.empty? 
      size = data[0].size || 1
      headers_array = gen_col_names(size)
    end 
  
    Matrix.new(data, headers_array, index_col, cols_types)
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
    begin    
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
      when "String"
        val.to_s
      else
        val
      end
    rescue
      val.to_s
    end
  end

  def get_type_from_string(value_type)
    begin    
      case value_type
      when "Int8"
        Int8
      when "Int16"
        Int16
      when "Int32"
        Int32
      when "Int64"
        Int64
      when "Float32"
        Float32
      when "Float64"
        Float64
      when "String"
        String
      else
        String
      end
    rescue
      String
    end
  end
  
  private def each_row
    @data.as(Array).each_with_index do |row, index|
      yield row, index
    end
  end

  def find_indexes(*columns : String)
    indexes = [{} of String => Int32] 
    
    columns.each do |column|
      @headers.each_with_index do |header, i|   
        indexes.push(Hash{column => i}) if header.compare(column) == 0  
      end
    end
    indexes.delete_at(0) ## Cleaning empty objects when initializing
    indexes
  end

  # def select(*columns, &block)
  #   to_array(*columns).each_with_index do |array_tuple, index|
  #     yield array_tuple, index
  #   end
  # end

  def select(*columns : String, &block)
    arrays = {} of String => Array(NamedTuple(i: Int32, v: StoreTypes))
    indexes = find_indexes(*columns)
    indexes.each_with_index do |col, index|
      series = [] of NamedTuple(i: Int32, v: StoreTypes)
      #pp col
      #pp index

      each_row do |row, row_index|
        #pp row
        value = row.as(Array)[col.first_value]
        #pp value
        value_type = col_types[col.first_value]
        begin
          series << ({i: row_index + 1 , v: value}) if yield Matrix.parse_col(value, col.first_value), col, col.first_value
        rescue ex
          pp ex
          pp "Not a float: " + @headers[col.first_value] + " row: "  + index.to_s
        end
        arrays[col.first_key] = series
      end
    end
    arrays
  end

  private def to_array(*columns : String)
    arrays = {} of String => Array(StoreTypes)
    indexes = find_indexes(*columns)
    indexes.each_with_index do |col, index|
      series = [] of StoreTypes
      each_row do |row, row_index|
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

  def self.gen_col_names(num)
    (1..num).map { |i| "col_#{i}" }
  end
end