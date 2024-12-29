module mu

module MuCore

include("parse/parse.jl")
include("builtin/builtin.jl")

include("lowering/lowering.jl")
include("interpreter/interpreter.jl")

end # module MuCore


end