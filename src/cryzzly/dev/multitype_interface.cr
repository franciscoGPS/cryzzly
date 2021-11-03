module Multitype
  STORE_TYPES = [Int8, Int16, Int32, Int64, Float32, Float64]
  SUMMABLE_TYPES = [Int8, Int16, Int32, Int64, Float32, Float64]
  SORTABLE_TYPES = [Int8, Int16, Int32, Int64, Float32, Float64]

  macro define_datatypes
    alias StoreTypes = Union({{*STORE_TYPES}})
    alias SummableTypes = Union({{*SUMMABLE_TYPES}})
    alias SortableTypes = Union({{*SORTABLE_TYPES}})
    alias AnyType = Union({{*SORTABLE_TYPES}} | {{*SUMMABLE_TYPES}} | {{*STORE_TYPES}})
  end

  macro add_store_type(type)
    {{STORE_TYPES.push(type)}}
  end

  macro add_sortable_type(type)
    {{SORTABLE_TYPES.push(type)}}
  end

  add_store_type(String)
  add_store_type(Bool)
  add_store_type(Time)
  add_sortable_type(String)
  add_sortable_type(Time)
  define_datatypes
  

end