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
    if instr.irtype == CALL
        print(io, instr.expr.args[1].name, "(", join(instr.expr.args[2:end], ", "), ")")
    elseif instr.irtype == ASSIGN
        print(io, instr.expr.args[1].name, " = ", instr.expr.args[2])
    elseif instr.irtype == GOTO
        print(io, "GOTO #", instr.expr.args[1])
    elseif instr.irtype == GOTOIFNOT
        print(io, "GOTO #", instr.expr.args[1], " IF NOT ", instr.expr.args[2])
    elseif instr.irtype == LABEL
        print(io, "LABEL #", instr.expr.args[1])
    else
        print(io, "#### Unknown IRType ####")
    end
end


const IR = Vector{Instr}



function Base.show(io::IO, ir::IR)
    println(io, "Untyped IR:")
    idx_width = max(length(string(length(ir))), 6)
    type_width = maximum(x -> length(string(x)), instr.irtype for instr in ir)
    println(io, @sprintf("| %*s | %-*s | %s", idx_width, "idx", type_width, "type", "instr"))
    println(io, "| ", "-"^idx_width, " | ", "-"^type_width, " | ", "-"^20)
    for (idx, instr) in enumerate(ir)
        println(io, @sprintf("| %*d | %-*s | %s", idx_width, idx, type_width, instr.irtype, instr))
    end
end


end # module MuIR