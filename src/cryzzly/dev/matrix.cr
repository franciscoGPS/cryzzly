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
  getter index_type : String

 def initialize(data, headers = [] of String, index_col = -1, col_types = [] of String, index_type = "")
    @headers = headers
    @data = data
    @col_types = col_types
    @index_col = index_col
    @index_type = ""
    begin
      Tensor.from_array(data)
    rescue ex
      pp ex.message
      return
    end
  end

  def self.parse_index?(index_type, col_type, index_col)
    index_col > 0 && index_type == "Time" && col_type != nil
  end
  
  def self.load_csv(filename, index_col = -1, index_type="Time", index_format="%Y-%m-%d %H:%M:%S", headers = true, col_types = [] of String )
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
      consider_index = parse_index?(index_type, col_types, index_col)
      parser.row.to_a.each_with_index do  |val, index|
  
        if consider_index && index == index_col
          parsed =  parse_index_column(val, col_types[index], index_format)
        else
          parsed = parse_col(val, col_types[index])
        end
        temp_row.push(parsed)
      end
      data.push(temp_row) 
    end
    if headers_array.empty? 
      size = data[0].size || 1
      headers_array = gen_col_names(size)
    end
  
    Matrix.new(data, headers: headers_array, index_col: index_col, col_types: col_types, index_type: index_type)
  end

  def self.parse_index_column(value, index_type, index_format)
    pp index_type
    def_tz = Time::Location.load("America/Chihuahua")
    begin
      if index_type == "Time"
        parsed = Time.parse(value, index_format, def_tz).to_unix_ms
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

  def select(*columns : String, &block)
    result_hash = {} of String => Array({pk: StoreTypes, i: Int32, v: StoreTypes})
    indexes = find_indexes(*columns)
    indexes.each_with_index do |col, index|
      series = [] of {pk: StoreTypes, i: Int32, v: StoreTypes}
      each_row do |row, row_index|
        value = row.as(Array)[col.first_value]
        value_type = col_types[col.first_value]
        begin
          series << {i: row_index + 1, pk: row.as(Array)[@index_col], v: value} if yield Matrix.parse_col(value, col.first_value), col, col.first_value
        rescue ex
          pp ex
          pp "Not a float: " + @headers[col.first_value] + " row: "  + index.to_s
        end
        result_hash[col.first_key] = series
      end
    end
    
    
    #Matrix.new(arrays, headers: headers_array, index_col: index_col, col_types: col_types, index_type: index_type)
    build_matrixes_from_hash(result_hash)
  end

  def build_matrixes_from_hash(hash)
    matrices = [] of Matrix
    headers_array = [] of String
    
    hash.keys.each do |feature|
      data = Matrix.resolve_matrix_type
      col_types = [] of String
      tuples = hash[feature]
      
      tuples.each do |tuple|
        temp_row = [] of StoreTypes
        temp_row << tuple[:pk]
        temp_row << tuple[:v]
        temp_row << tuple[:i]
        col_types = [tuple[:pk].class.to_s, tuple[:v].class.to_s, tuple[:i].class.to_s] if col_types.empty?
        data.push(temp_row) 
      end

      matrices << Matrix.new(data, headers: headers_array, index_col: 0, col_types: col_types, index_type: "String")
    end
    matrices
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