module MuInterpreter

import ..MuBuiltins
import ..MuAST
import ..MuIR

abstract type AbstractInterpreter end


function injection!(interp::ConcreateInterpreter, codeinfo::MuIR.CodeInfo)
    add_method!(interp.methodtable, codeinfo)
 end

include("concreate_interpreter.jl")

function interpret(ir::MuIR.IR)
    interpret(ir, ConcreateInterpreter())
end

end # module MuInterpreter
