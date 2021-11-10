require "./multitype_interface"

module Calculations
  include Multitype
  extend self

  def shape
    #[columns number, size of each column
    [length, @data.size]
  end

  def length
    #columns number
    
    @data[0].size#.this.as(Array).size
  end

  def includes?(column)
    return false if @headers.empty?
    @headers.includes?(column)
  end

  def head
    first(5)
  end

  def first(n : Int32 = 1)
    if n <= shape[1]
      @data[0..n]
    else
      @data
    end
  end

  def tail
    last(5)
  end

  def last(n : Int32 = 1)
    if n <= shape[1]
      @data[n..-1]
    else
      @data
    end
  end

  def mean(columns : Array(String))
    avgs = {} of String => Cell
    column_size = shape[1]
    sum(columns).data[0].each_with_index do |sum_item, index|
      avgs[columns[index]] = Cell.new(sum_item.val.as(SummableTypes) / column_size) if column_size > 0
    end
    Matrix.new([avgs.values], avgs.keys )
  end

  #def summable_type(col_type)
  #  SUMMABLE_TYPES.includes?(col_type)
  #end

  def sum(columns : Array(String))
    sums = {} of String =>  Cell
    to_array(columns).each_with_index do |array_tuple, index|
      sum = 0
      array_tuple[1].map{ |e| sum += e.val.as(SummableTypes) }
      sums[columns[index]] = Cell.new(sum.as(SummableTypes))
    end
    Matrix.new([sums.values], sums.keys)
  end

  def min(columns : Array(String))
    mins = {} of String => Cell
    to_array(columns).each_with_index do |array_tuple, index|
      mins[columns[index]] =  Cell.new(array_tuple[1].map{ |e| e.val.as(SummableTypes) }.min) 
    end
    Matrix.new([mins.values], mins.keys)
  end

  def max(columns : Array(String))
    maxs = {} of String => Cell
    to_array(columns).each_with_index do |array_tuple, index|
      maxs[columns[index]] = Cell.new(array_tuple[1].map{ |e| e.val.as(SummableTypes)}.max)
    end
    Matrix.new([maxs.values], maxs.keys)
  end
  
end