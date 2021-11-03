require "spec"
require "./multitype_interface"

abstract class AbstractCell
  include Multitype

  abstract def val
end

class Cell < AbstractCell
  include Comparable(SortableTypes)

  def initialize(@value : StoreTypes) ; end

  def initialize(@value : SortableTypes) ; end

  def val
    @value
  end

  def set_val(@value) ; end

  def <=>(other : SortableTypes)
    val.as(SortableTypes) <=> other.val.as(SortableTypes)
  end

  def <=> (other : Cell)
    val.to_s.as(String) <=> other.val.to_s.as(String)
  end

  def <=> (other : String)
    val.as(String) <=> other.val.as(String)
  end
  
end

cell_array = [] of Cell

describe AbstractCell do
  
  multitype_array = [5,"string", 3.14, Time.local, false]

  multitype_array.each do |value|
    cell = Cell.new(value)
    #cell.set_value(value) 
    cell_array << cell 
  end

  it "The array is of multitype" do
    cell_array.map{|e| e.val }.should eq(multitype_array)
  end
end