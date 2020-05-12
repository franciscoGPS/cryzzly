require "num"
require "./any"
require "./utils/*"
require "aquaplot"
require "csv"


class Dataframe(Any)

  getter data : Any
  getter headers : Array(String)
  getter index_col : Int32

 def initialize(data, headers = [] of String, index_col = -1)
    @headers = headers
    @data = data
    @index_col = index_col
    begin
      #Valid matrix (complete arrays at least)
      Tensor.from_array data
    rescue ex
      pp ex.message
      return
    end
  end

  def headers
    @headers
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

  def shape
    #[columns number, size of each column
    [length, @data.as(Array).size]
  end

  def length
    #columns number
    @data[0].this.as(Array).size
  end


  def mean(*columns : String) : Dataframe
    avgs = {} of String => Float64
    column_size = shape[1]
    sum(*columns).data.each_with_index do |sum, index|
      avgs[columns[index]] = sum / column_size if column_size > 0
    end
    Dataframe(typeof(avgs.values)).new(avgs.values, avgs.keys)
  end

  def min(*columns : String)
    mins = {} of String => Float64
    to_array(*columns).each_with_index do |array_tuple, index|
      mins[columns[index]] =  array_tuple[1].min 
    end
    Dataframe(typeof(mins.values)).new(mins.values, mins.keys)
  end

  def max(*columns : String)
    maxs = {} of String => Float64
    to_array(*columns).each_with_index do |array_tuple, index|
      maxs[columns[index]] = array_tuple[1].max       
    end
    Dataframe(typeof(maxs.values)).new(maxs.values, maxs.keys)
  end

  def sum(*columns : String )
    sums = {} of String => Float64
    to_array(*columns).each_with_index do |array_tuple, index|
      sums[columns[index]] = array_tuple[1].sum       
    end
    Dataframe(typeof(sums.values)).new(sums.values, sums.keys)
  end

  def std(*columns : String)
    stds = {} of String => Float64
    indexes = find_indexes(*columns)
    means_df = mean(*columns)
    indexes.each_with_index do |col, index|
      std_dev = [] of Float64
      each_row do |row|
        sum = 0.0
        value = row.as(Array)[col.first_value]
        if value.responds_to?(:this)
          begin
            float_val = value.this
            current_mean = means_df.data[index].nil? ? 0.0 : means_df.data[index]
            if current_mean.is_a?(Float64) && float_val.is_a?(Float64)
              substact = (current_mean - float_val )
              sum += substact * substact
            end
          rescue ex
            pp ex
            pp "Not a float: " + @headers[col.first_value] + " row: "  + index.to_s
          end
        end
        stds[col.first_key] = Math.sqrt(sum / (shape[1] - 1)) 
      end
    end
    Dataframe(typeof(stds.values)).new(stds.values, stds.keys)
  end

  def percentile(*columns : String, p : Float64)
    raise Exception if p > 100 || p <= 0
    pp "TODO: Percentiles"
  end

  private def to_array(*columns : String)
    arrays = {} of String => Array(Float64)
    indexes = find_indexes(*columns)
    indexes.each_with_index do |col, index|
      series = [] of Float64

      each_row do |row|
        value = row.as(Array)[col.first_value]
        if value.responds_to?(:this)
          begin
            float_val = value.this
            
            series.push(float_val) if float_val.is_a?(Float64)
          rescue ex
            pp ex
            pp "Not a float: " + @headers[col.first_value] + " row: "  + index.to_s
          end
        end
        arrays[col.first_key] = series
      end
    end
    arrays
  end

  def plot(*columns : String, filename = Time.now.to_s)
    arrays = [] of Array(Float64)
    array_x = [] of Float64
    headers = [] of String
    indexes = find_indexes(*columns)

    #Appending columns
    to_array(*columns).each_with_index do |array_tuple, index|
      arrays.push(array_tuple[1])
    end
    
    #Selecting x axis values
    array_x = [] of Float64
    each_row do |row|
      x_val = row.as(Array)[@index_col] if @index_col > -1
      if x_val.responds_to?(:this)
        begin
          index_x_val = x_val.this
          array_x.push(index_x_val) if index_x_val.is_a?(Float64)
        rescue ex
          pp ex
          pp "Not a float: " + @headers[@index_col] + " row: " + row.to_s
        end
      end
    end
    
    plot_chart(arrays, array_x, headers: columns, filename: filename )
    
  end

  def self.load_csv(filename, index_col = -1, index_type="datetime", index_format="%Y-%m-%d %H:%M:%S", headers = true )
    pp "Loading CSV File"
    pp "Filename: " + filename
    pp "Index column: " + index_col.to_s
    pp "Index type: " + index_type.to_s
    pp "Index format: " + index_format.to_s

    data = [] of Any
    headers_array = [] of String
    headers = true
    headers_array = each_csv_row(filename, headers: headers) do |parser|
      temp_row = [] of Any
      parser.row.to_a.each_with_index do  |val, index|
        begin
          if index_col == index && index_type == "datetime"
            parsed = Time.parse(val, index_format, Time::Location.load("America/Chihuahua")).to_unix_ms.to_f
          else 
            parsed = val.to_f
          end
        rescue ex
          print ex.message
          parsed = 0.0
        ensure
        end
        temp_row.push(A.new(parsed))

      end
      data.push(A.new(temp_row))
    end
    if headers_array.empty? 
      size = data[0].this.as(Array).size || 1
      headers_array = gen_col_names(size)
    end 

    Dataframe(typeof(data)).new(data, headers_array, index_col)
  end

  def self.gen_col_names(num)
    (1..num).map { |i| "col_#{i}" }
  end

  def to_csv(*columns, filename = Time.local.to_s, headers = true)
    indexes = find_indexes(*columns)
    indexes_array = indexes.map{ |i| i.first_value}
    values = [] of String
    result = CSV.build do |csv|
      csv.row(columns) if headers
      each_row do |row|
        row_array = row_to_a(row)
        csv.row(indexes.map{ |i| row_array.values_at( i.first_value ).map{|a| a.responds_to?(:this) ? a.this : "" }.first })
      end
    end
    save_csv(filename, result)
  end  

  private def each_row
    @data.as(Array).each do |row|
      yield row.this
    end
  end

  private def row_to_a(row)
    #Arreglar la iteración del arreglo row y regresar solo los valores requeridos
    #usar values at
    value = row.as(Array)
  end

  private def plot_chart(arraylist, array_x, headers = [] of String, title = "", filename = Time.now.to_s)
    #pp arraylist
    lines = arraylist.map_with_index do |n, i|
      if headers.any?
        AquaPlot::Line.new array_x, n, title: "#{headers[i].to_s}"
      else
        AquaPlot::Line.new array_x, n
      end
    end

    plt = AquaPlot::Plot.new lines    
    plt.set_title(title)
    

    pp "Image stored in: " + filename
    plt.savefig(filename+".png")
    plt.close
  end
  
  private def save_csv(filename, data)
    File.write(filename+".csv", data)
  end
end