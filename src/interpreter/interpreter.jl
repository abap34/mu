module MuInterpreter

import ..MuBuiltins
import ..MuAST
import ..MuIR

abstract type AbstractInterpreter end

include("naiveinterpreter.jl")

function interpret(ir::MuIR.IR)
    interpret(ir, NaiveInterpreter())
end


end # module MuInterpreter
