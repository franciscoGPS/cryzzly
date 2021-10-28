module Calculations

  SUMMABLE_TYPES = [Int8, Int16, Int32, Int64, Float32, Float64]
  STORE_MAPPINGS = [Int8, Int16, Int32, Int64, Float32, Float64]

  macro define_datatypes
    alias StoreTypes = Union({{*STORE_MAPPINGS}})
    alias SummableTypes = Union({{*SUMMABLE_TYPES}})
  end

  macro add_store_types(type)
    {{STORE_MAPPINGS.push(type)}}
  end

  add_store_types(String)
  
  define_datatypes

  def shape
    #[columns number, size of each column
    [length, @data.size]
  end

  def length
    #columns number
    
    @data[0].size#.this.as(Array).size
  end


  def mean(*columns : String)
    avgs = {} of String => StoreTypes
    column_size = shape[1]
    sum(*columns).data[0].each_with_index do |sum_item, index|
      avgs[columns[index]] = sum_item.as(SummableTypes) / column_size if column_size > 0
    end
    Matrix.new([avgs.values], avgs.keys )
  end

  def summable_type(col_type)
    SUMMABLE_TYPES.includes?(col_type)
  end

  def sum(*columns : String )
    sums = {} of String =>  StoreTypes
    to_array(*columns).each_with_index do |array_tuple, index|
      sum = 0
      array_tuple[1].map{ |e| sum += e.as(SummableTypes) }
      sums[columns[index]] = sum.as(SummableTypes)
    end
    Matrix.new([sums.values], sums.keys)
  end

  def min(*columns : String)
    mins = {} of String => StoreTypes
    to_array(*columns).each_with_index do |array_tuple, index|
      mins[columns[index]] =  array_tuple[1].map{ |e| e.as(SummableTypes) }.min 
    end
    Matrix.new([mins.values], mins.keys)
  end

  def max(*columns : String)
    maxs = {} of String => StoreTypes
    to_array(*columns).each_with_index do |array_tuple, index|
      maxs[columns[index]] = array_tuple[1].map{ |e| e.as(SummableTypes)}.max       
    end
    Matrix.new([maxs.values], maxs.keys)
  end
  
end