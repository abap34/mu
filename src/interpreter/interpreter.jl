module MuInterpreter

import ..MuBuiltins
import ..MuAST
import ..MuIR

abstract type AbstractInterpreter end

include("concreate_interpreter.jl")

function injection!(interp::AbstractInterpreter, codeinfo::MuIR.CodeInfo)
    add_method!(interp.methodtable, codeinfo)
end

function interpret(ir::MuIR.IR)
    interpret(ir, ConcreateInterpreter())
end

end # module MuInterpreter
