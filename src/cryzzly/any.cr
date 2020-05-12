# https://github.com/crystal-lang/crystal/issues/4572

abstract struct Any; end

record A(T) < Any, this : T