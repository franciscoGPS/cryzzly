require "num"
require "./../utils/*"
require "aquaplot"

class Matrix
  include Calculations

  def self.resolve_matrix_type
    [] of Array(Cell)
  end

  getter headers : Array(String)
  getter col_types : Array(String)
  getter index_col : Int32
  getter data : Array(Array(Cell))
  getter index_type : String
  getter index_format : String


 def initialize(@data, @headers = [] of String, @index_col = -1, @col_types = [] of String, @index_type = "", @index_format="%Y-%m-%d %H:%M:%S")
    resolve_col_types(col_types)
    begin
    rescue ex
      pp ex.message
      return
    end
  end

  def shape
    #[columns number, size of each column
    [length, @data.as(Array).size]
  end

  def length
    #columns number
    @data[0].as(Array).size
  end

  

  def [](*args)
    filter(["vl1_n"]) do |e|
      
    end


  end
  

  def resolve_col_types(types)
    if types.empty?
      @data.each do |col|
        @col_types << col.first.val.class.to_s
      end
    else 
      @col_types = types
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
      temp_row = [] of Cell
      consider_index = parse_index?(index_type, col_types, index_col)
      parser.row.to_a.each_with_index do  |val, index|
  
        if consider_index && index == index_col
          parsed =  parse_index_column(val, col_types[index], index_format)
        else
          parsed = parse_col(val, col_types[index])
        end
        temp_row.push(Cell.new(parsed))
      end
      data.push(temp_row) 
    end
    if headers_array.empty? 
      size = data[0].size || 1
      headers_array = gen_col_names(size)
    end
  
    Matrix.new(data, headers: headers_array, index_col: index_col, col_types: col_types, index_type: index_type, index_format: index_format)
  end

  def self.parse_index_column(value, index_type, index_format)
    def_tz = Time::Location.load("America/Monterrey")
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

  def find_indexes(columns : Array(String))
    indexes = [{} of String => Int32] 
    
    columns.each do |column|
      @headers.each_with_index do |header, i|   
        indexes.push(Hash{column => i}) if header.compare(column) == 0  
      end
    end
    indexes.delete_at(0) ## Cleaning empty objects when initializing
    indexes
  end

  def filter(columns : Array(String), &block)
    result_hash = {} of String => Array(Array(Cell))
    indexes = find_indexes(@headers)
    series = [] of {pk: Cell, i: Int32, v: Cell}
    full_rows = [] of Array(Cell)
    
    column_types = {} of String => String
    
    each_row do |row, row_index|
      value_type = ""
      temp_row = [] of Cell
      hash_row = converto_to_hash(row.as(Array), indexes) 
      begin
        if yield hash_row
          indexes.each do |col|
            if columns.includes?(col.first_key)
              temp_row << row.as(Array)[col.first_value] 
              column_types[col.first_key] = col_types[col.first_value]
            end
          end
        end
        full_rows << temp_row if temp_row.any?
      rescue ex
        pp ex
        #pp "Not a float: " + @headers[col.first_value] + " row: "  + index.to_s
      end
    end
    Matrix.new(full_rows, headers: columns, index_col: 0, col_types: column_types.values, index_type: "String")
  end

  def transform(columns : Array(String), &block)
    transforms = {} of String =>  Array(Cell)
    to_array(columns).each_with_index do |array_tuple, index|
      transforms[columns[index]] = array_tuple[1].map{ |e| Cell.new(yield e.val) }
    end
      
    Matrix.new(transforms.values, transforms.keys)
  end

  def sort(columns : Array(String), asc : Bool = true, &block)
    sorts = {} of String =>  Array(Cell)
    to_array(columns).each_with_index do |array_tuple, index|
      if asc
        sorts[columns[index]] = array_tuple[1].sort 
      else
        sorts[columns[index]] = array_tuple[1].sort {|a,b| b <=> a}
      end

      yield sorts[columns[index]]
      
    end
    Matrix.new(sorts.values, sorts.keys)
  end

  def sort_by(column : String, asc : Bool = true, &block)
    arrays = {} of String => Array(Cell)
    result_hash = {} of String =>  Hash(String, Cell)
    result_array = [] of Hash(String, Cell)
    indexes = find_indexes(@headers)
    series = [] of {pk: Cell, i: Int32, v: Cell}
    full_rows = [] of Array(Cell)
    
    column_types = {} of String => String
    
    each_row do |row, row_index|
      value_type = ""
      temp_row = [] of Cell
      hash_row = converto_to_hash(row.as(Array), indexes) 
      result_hash[row_index.to_s] = hash_row
      result_array << hash_row
    end
    ordered = result_array.sort do |e1, e2|
      e1[column].val.as(Int32) <=> e2[column].val.as(Int32)
    end
    indexes.each_with_index do |col, index|
      series = [] of Cell
      ordered.each do |row|
        value = row.map{|e| e[1].val}[col.first_value]  
        begin
          series.push(Cell.new(value))
        rescue ex
          pp ex
          pp "Not a float: " + @headers[col.first_value] + " row: "  + index.to_s
        end
        arrays[col.first_key] = series
      end
    end
    Matrix.new(arrays.values, headers: @headers, index_col: 0, col_types: column_types.values, index_type: "String")
    
  end

  def converto_to_hash(array, columns)
    hash = {} of String => Cell
    columns.each do |col|
      hash[col.first_key] = array[col.first_value]
    end
    hash
  end

  ##UNUSED. KEEP FOR EXAMPLES
  def build_matrixes_from_hash(hash)
    matrices = [] of Matrix
    header = ""
    
    hash.keys.each do |feature|
      data = Matrix.resolve_matrix_type
      col_types = [] of String
      headers_array = [] of String
      tuples = hash[feature]
      
      tuples.each do |tuple|
        
        next if tuple.size == 0 
        if tuple.size > 0 && !headers_array.includes?(feature)
          headers_array << "date"
          headers_array << "row_id"
          headers_array << feature
        end

        temp_row = [] of Cell
        temp_row << tuple[:pk]
        temp_row << tuple[:i]
        temp_row << tuple[:v]
        col_types = [tuple[:pk].class.to_s, tuple[:i].class.to_s, tuple[:v].class.to_s] if col_types.empty?
        
        data.push(temp_row) 
      end
      if data.any?
        matrices << Matrix.new(data, headers: headers_array, index_col: 0, col_types: col_types, index_type: "String")
      end
    end
    matrices
  end


  # Used to extract raw arrays 
  def strip_fields(columns : Array(String), &block)
    arrays = {} of String => Array(Cell)
    indexes = find_indexes(columns)
    indexes.each_with_index do |col, index|
      each_row do |row, row_index|
        cell = row.as(Array)[col.first_value]
        begin
          yield col.first_key,  cell.val
        rescue ex
          pp ex
          pp "Not a float: " + @headers[col.first_value] + " row: "  + index.to_s
        end
      end
    end
  end

  private def to_array(columns : Array(String))
    arrays = {} of String => Array(Cell)
    indexes = find_indexes(columns)
    indexes.each_with_index do |col, index|
      series = [] of Cell
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