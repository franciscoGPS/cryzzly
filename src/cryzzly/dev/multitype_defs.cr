module Multitype
  SUMMABLE_TYPES = [Int8, Int16, Int32, Int64, Float32, Float64]
  STORE_MAPPINGS = [Int8, Int16, Int32, Int64, Float32, Float64]

  macro define_datatypes
    alias Cell = Union({{*STORE_MAPPINGS}})
    alias SummableTypes = Union({{*SUMMABLE_TYPES}})
  end

  macro add_store_types(type)
    {{STORE_MAPPINGS.push(type)}}
  end

  add_store_types(String)
  define_datatypes

end