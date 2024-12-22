module mu

module MuCore

include("parse/parse.jl")
include("lowering/lowering.jl")
include("builtin/builtin.jl")
include("interpreter/interpreter.jl")

end # module MuCore


end