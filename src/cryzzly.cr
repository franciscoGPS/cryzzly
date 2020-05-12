# TODO: Write documentation for `Cryzzly`
module Cryzzly
  VERSION = "0.0.1"

    def self.lib_version
      v = Lib.version
      {v.major, v.minor, v.patch}
    end

    def self.version
      "Cryzzly v#{VERSION} ( v#{lib_version.join('.')})"
    end

end

require "./cryzzly/*"

  
