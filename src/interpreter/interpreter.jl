module MuInterpreter

import ..MuBuiltins
import ..MuAST
import ..MuIR

abstract type AbstractInterpreter end

include("nativeinterpreter.jl")

end # module MuInterpreter
