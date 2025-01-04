module MuIR

using Printf
import Base

import ..MuAST
import ..MuTypes


@enum IRType begin
    ASSIGN           # Assignment
    GOTO             # Goto label without condition
    GOTOIFNOT        # Goto label if condition is false.  
    LABEL            # Label for goto
    RETURN           # Return statement
end

struct Instr
    irtype::IRType
    expr::MuAST.Expr
    typing::Union{Nothing,MuAST.Expr}
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

function get_dest(instr::Instr)
    if !(instr.irtype == GOTO || instr.irtype == GOTOIFNOT)
        throw(ArgumentError("Expected GOTO or GOTOIFNOT. Got $(instr.irtype)"))
    end

    return instr.expr.args[1]
end

function get_label(instr::Instr)
    if instr.irtype != LABEL
        throw(ArgumentError("Expected LABEL. Got $(instr.irtype)"))
    end

    return instr.expr.args[1]
end

function get_returnexpr(instr::Instr)
    if instr.irtype != RETURN
        throw(ArgumentError("Expected RETURN. Got $(instr.irtype)"))
    end

    return instr.expr.args[1]
end

function Base.show(io::IO, instr::Instr)
    if instr.irtype == ASSIGN
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

    if !(isnothing(instr.typing))
        printstyled(io, "::", instr.typing, color=:green)
    else
        printstyled(io, "::_", color=:light_black)
    end
end


# Representation of program after lowering.
struct IR
    instrs::Vector{Instr}
    typed::Bool
    function IR()
        return new(Instr[], false)
    end
end

# Information of each **method**.
struct CodeInfo
    name::MuAST.Ident               # Name of the method (not unique) 
    argname::Vector{MuAST.Ident}    # Argument names (e.g. [`a`, `b`, `c`])
    signature::Vector{DataType}     # Signature of the method. All elements must be MuTypes.
    ir::IR                          # IR of the method
    id::Int                         # id of the method (unique)
    function CodeInfo(name::MuAST.Ident, argname::AbstractArray, signature::AbstractArray, ir::IR, id::Int)
        if length(argname) != length(signature)
            throw(ArgumentError("Length of argname and signature must be the same. Got $(length(argname)) and $(length(signature))"))
        end

        if any(sig -> !(sig <: MuTypes.MuType), signature)
            throw(ArgumentError("All signature must be MuTypes. Got $signature"))
        end

        return new(name, argname, signature, ir, id)
    end
end

function get_names(formalargs::MuAST.Expr)
    @assert formalargs.head == MuAST.FORMALARGS "Expected FORMALARGS. Got $(formalargs.head)"
    return [arg.args[1] for arg in formalargs.args]
end

function formalarg_to_signature(formalargs::MuAST.Expr)
    @assert formalargs.head == MuAST.FORMALARGS "Expected FORMALARGS. Got $(formalargs.head)"
    return [MuTypes.astype(arg.args[2]) for arg in formalargs.args]
end

function CodeInfo(name::MuAST.Ident, args::MuAST.Expr, ir::IR, id::Int)
    if args.head != MuAST.FORMALARGS
        throw(ArgumentError("Arguments must be `FORMALARGS`. Got $(args.head)"))
    end
    return CodeInfo(name, get_names(args), formalarg_to_signature(args), ir, id)
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

function Base.iterate(ir::IR)
    return iterate(ir.instrs)
end

function Base.iterate(ir::IR, state)
    return iterate(ir.instrs, state)
end

function Base.getindex(ir::IR, idx::Int)
    return ir.instrs[idx]
end

function Base.show(io::IO, ir::IR)
    if length(ir.instrs) == 0
        println(io, "Empty IR")
        return
    end
    
    instrs = ir.instrs

    idx_width = max(ndigits(length(instrs)), 3)
    irtype_width = max(maximum(x -> length(string(x.irtype)), instr for instr in instrs), 10)

    println(io, "| ", lpad("idx", idx_width), " | ", lpad("irtype", irtype_width), " | instr")
    println(io, "| ", "-"^idx_width, " | ", "-"^irtype_width, " | ", "-"^40)

    for (idx, instr) in enumerate(instrs)
        println(io, "| ", lpad(string(idx), idx_width), " | ", lpad(string(instr.irtype), irtype_width), " | ", instr)
    end
end

function Base.show(io::IO, codeinfo::CodeInfo)
    print(io, "function ", codeinfo.name, "(")
    for i in 1:length(codeinfo.argname)
        print(io, codeinfo.argname[i])
        print(io, "::", codeinfo.signature[i])
        if i < length(codeinfo.argname)
            print(io, ", ")
        end
    end
    println(io, ")")
    println(io)
    println(io, codeinfo.ir)
    println(io, "end")
end

const ProgramIR = Vector{CodeInfo}

function Base.show(io::IO, program::ProgramIR)
    for codeinfo in program
        show(io, codeinfo)
    end
end


end # module MuIR
