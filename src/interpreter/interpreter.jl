module MuInterpreter

import ..MuBuiltins
import ..MuAST
import ..MuIR

abstract type AbstractInterpreter end

include("concreateinterpreter.jl")

end # module MuInterpreter
