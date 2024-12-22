module MuIR

using Printf

import ..MuAST


@enum IRType begin
    CALL
    ASSIGN
    GOTO
    GOTOIFNOT
    LABEL
end

struct Instr
    irtype::IRType    
    expr::MuAST.Expr
end

function Base.show(io::IO, instr::Instr)
    print(io, instr.irtype, " ", instr.expr)
end


const IR = Vector{Instr}



function Base.show(io::IO, IR::IR)
    println(io, "Untyped IR:")
    idx_width = max(length(string(length(IR))), 6)
    type_width = maximum(x -> length(string(x)), instr.irtype for instr in IR)
    println(io, @sprintf("| %*s | %-*s | %s", idx_width, "idx", type_width, "type", "instr"))
    println(io, "| ", "-"^idx_width, " | ", "-"^type_width, " | ", "-"^20)
    for (idx, instr) in enumerate(IR)
        println(io, @sprintf("| %*d | %-*s | %s", idx_width, idx, type_width, instr.irtype, instr.expr))
    end
end


end # module MuIR