module MuIR

using Printf
import Base

import ..MuAST


@enum IRType begin
    CALL
    ASSIGN
    GOTO
    GOTOIFNOT
    LABEL
    RETURN
end

struct Instr
    irtype::IRType    
    expr::MuAST.Expr
    typing::Union{Nothing, MuAST.Expr}
    function Instr(irtype::IRType, expr::MuAST.Expr; typing::Nothing=nothing)
        new(irtype, expr, typing)
    end
end

function Instr(irtype::IRType, expr::MuAST.Expr, typing::MuAST.Expr)
    if typing.head != MuAST.TYPE
        throw(ArgumentError("Typing must be `Expr(TYPE, ...)`. Got $(typing)"))
    end

    return Instr(irtype, expr, typing)
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
    elseif instr.irtype == RETURN
        print(io, "RETURN ", instr.expr.args[1])
    else
        print(io, "#### Unknown IRType ####")
    end
end


const IR = Vector{Instr}
# Representation of program after lowering.
struct IR
    instrs::Vector{Instr}
    typed::Bool
    function IR()
        return new(Instr[], false)
    end
end

struct CodeInfo
    name::MuAST.Ident
    args::MuAST.Expr
    ir::IR
    function CodeInfo(name::MuAST.Ident, args::MuAST.Expr, ir::IR)
        @assert args.head == MuAST.FORMALARGS "args must be FORMALARGS. Got $(args)"
        new(name, args, ir)
    end
end


Base.length(ir::IR) = length(ir.instrs)
Base.push!(ir::IR, instr::Instr) = push!(ir.instrs, instr)
Base.pushfirst!(ir::IR, instr::Instr) = pushfirst!(ir.instrs, instr)
function Base.append!(ir::IR, ir2::IR)
    if ir.typed != ir2.typed
        throw(ArgumentError("Cannot append IR with different typing status"))
    end

    append!(ir.instrs, ir2.instrs)
end

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