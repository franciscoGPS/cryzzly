require "spec"
require "./multitype_defs"

abstract class AbstractCell
  abstract def eval_value
end

class Cell < AbstractCell
  include Multitype
  def eval_value
    @value
  end
  def set_value(@value : StoreTypes)
  end
end

cell_array = [] of Cell

describe AbstractCell do
  
  multitype_array = [5,"string", 3.14, Time.local, false]

  multitype_array.each do |value|
    cell = Cell.new
    cell.set_value(value) 
    cell_array << cell  
  end

  it "The array is of multitype" do
    cell_array.map{|e| e.eval_value }.should eq(multitype_array)
  end
end