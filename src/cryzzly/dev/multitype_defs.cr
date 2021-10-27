module Multitype
  STORE_MAPPINGS = [Int8, Int16, Int32, Int64, Float32, Float64, Time, Bool]

  macro define_datatype
    alias StoreTypes = Union({{*STORE_MAPPINGS}})
  end

  macro add_store_types(type)
    {{STORE_MAPPINGS.push(type)}}
  end

  add_store_types(String)
  define_datatype

end