module MuInterpreter

import ..MuBuiltins
import ..MuAST
import ..MuIR

abstract type AbstractInterpreter end

include("nativeinterpreter.jl")

function interpret(ir::MuIR.IR)
    interpret(ir, NativeInterpreter())
end

end # module MuInterpreter
