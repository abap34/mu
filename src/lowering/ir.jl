module MuIR

using Printf
import Base

import ..MuAST
import ..MuTypes


@enum InstrType begin
    ASSIGN           # Assignment
    GOTO             # Goto label without condition
    GOTOIFNOT        # Goto label if condition is false.  
    LABEL            # Label for goto
    RETURN           # Return statement
end

ALLOWED_EXPR_HEAED = [
    MuAST.ASSIGN,
    MuAST.GOTO,
    MuAST.GOTOIFNOT,
    MuAST.LABEL,
    MuAST.RETURN
]

EXPR_INSTRTYPE_MAP = Dict(
    MuAST.ASSIGN => ASSIGN,
    MuAST.GOTO => GOTO,
    MuAST.GOTOIFNOT => GOTOIFNOT,
    MuAST.LABEL => LABEL,
    MuAST.RETURN => RETURN
)

function _check_nonested(expr::MuAST.Expr)
    @assert expr.head == MuAST.ASSIGN "Expected ASSIGN. Got $(expr.head) in $expr"
    rhs = expr.args[2]
    ((rhs isa MuAST.Ident) || (rhs isa MuAST.Literal)) && return
    any(arg -> (arg isa MuAST.Expr), rhs.args) && throw(ArgumentError("Nested expression is not allowed in Instr. Got $expr"))
end


struct Instr
    instrtype::InstrType
    expr::MuAST.Expr
    function Instr(instrtype::InstrType, expr::MuAST.Expr)
        (expr.head in ALLOWED_EXPR_HEAED) || throw(ArgumentError("Invalid ExprHead. Got $(expr.head)"))
        (expr.head == MuAST.ASSIGN) && _check_nonested(expr)
        (instrtype != EXPR_INSTRTYPE_MAP[expr.head]) && throw(ArgumentError("Mismatch between InstrType and ExprHead. Got $instrtype and $(expr.head)"))

        new(instrtype, expr)
    end
end


function get_dest(instr::Instr)::Int
    if !(instr.instrtype == GOTO || instr.instrtype == GOTOIFNOT)
        throw(ArgumentError("Expected GOTO or GOTOIFNOT. Got $(instr.instrtype)"))
    end

    return instr.expr.args[1]
end

function get_label(instr::Instr)::Int
    if instr.instrtype != LABEL
        throw(ArgumentError("Expected LABEL. Got $(instr.instrtype)"))
    end

    return instr.expr.args[1]
end

# Get the return expression of the return statement.
# e.g. `RETURN %1` -> `%1`, `RETURN 1` -> `1`, `RETURN 1 + 2` -> Expr(CALL, [add 1 2])
function get_returnbody(instr::Instr)::MuAST.SyntaxNode
    if instr.instrtype != RETURN
        throw(ArgumentError("Expected RETURN. Got $(instr.instrtype)"))
    end

    return instr.expr.args[1]
end

function get_varname(instr::Instr)::MuAST.Ident
    if instr.instrtype != ASSIGN
        throw(ArgumentError("Expected ASSIGN. Got $(instr.instrtype)"))
    end

    return instr.expr.args[1]
end

function Base.show(io::IO, instr::Instr)
    if instr.instrtype == ASSIGN
        print(io, instr.expr.args[1].name, " = ", instr.expr.args[2])
    elseif instr.instrtype == GOTO
        dest = instr.expr.args[1]
        if dest == -1
            print(io, "GOTO RETURN")
        else
            print(io, "GOTO #", dest)
        end
    elseif instr.instrtype == GOTOIFNOT
        dest = instr.expr.args[1]
        if dest == -1
            print(io, "GOTO RETURN IF NOT ", instr.expr.args[2])
        else
            print(io, "GOTO #", dest, " IF NOT ", instr.expr.args[2])
        end

    elseif instr.instrtype == LABEL
        label = get_label(instr)
        if label == -1
            print(io, "LABEL RETURN")
        else
            print(io, "LABEL #", label)
        end

    elseif instr.instrtype == RETURN
        print(io, "RETURN ", instr.expr.args[1])
    else
        print(io, "#### Unknown InstrType ####")
    end
end


# Representation of program after lowering.
struct CodeInfo
    instrs::Vector{Instr}
    typed::Bool
    varnames::Vector{MuAST.Ident}
    vartypes::Vector{Union{DataType,Nothing}}
    function CodeInfo()
        return new(Instr[], false, MuAST.Ident[], Union{DataType,Nothing}[])
    end
end

# Information of each **method**.
struct MethodInfo
    name::MuAST.Ident               # Name of the method (not unique) 
    argname::Vector{MuAST.Ident}    # Argument names (e.g. [`a`, `b`, `c`])
    signature::MuTypes.Signature    # Signature of the method. All elements must be MuTypes.
    ci::CodeInfo                    # IR of the method
    id::Int                         # id of the method (unique)
    function MethodInfo(name::MuAST.Ident, argname::AbstractArray, signature::MuTypes.Signature, ci::CodeInfo, id::Int)
        if length(argname) != length(signature)
            throw(ArgumentError("Length of argname and signature must be the same. Got $(length(argname)) and $(length(signature))"))
        end

        all(arg -> arg isa MuAST.Ident, argname) || throw(ArgumentError("argname must be Vector{MuAST.Ident}. Got $(argname)"))


        return new(name, argname, signature, ci, id)
    end
end

function get_names(formalargs::MuAST.Expr)
    @assert formalargs.head == MuAST.FORMALARGS "Expected FORMALARGS. Got $(formalargs.head)"
    return [arg.args[1] for arg in formalargs.args]
end

function MethodInfo(name::MuAST.Ident, args::MuAST.Expr, ir::CodeInfo, id::Int)
    if args.head != MuAST.FORMALARGS
        throw(ArgumentError("Arguments must be `FORMALARGS`. Got $(args.head)"))
    end
    return MethodInfo(name, get_names(args), MuTypes.formalargs_to_signature(args), ir, id)
end


Base.length(ci::CodeInfo) = length(ci.instrs)

function newvar!(ci::CodeInfo, name::MuAST.Ident, dtype::Union{DataType,Nothing})
    if !(name in ci.varnames)
        push!(ci.varnames, name)
        push!(ci.vartypes, nothing)
    end
end

function Base.push!(ci::CodeInfo, instr::Instr)
    push!(ci.instrs, instr)

    if instr.instrtype == ASSIGN
        newvar!(ci, get_varname(instr), nothing)
    end
end
function Base.pushfirst!(ci::CodeInfo, instr::Instr)
    pushfirst!(ci.instrs, instr)

    if instr.instrtype == ASSIGN
        newvar!(ci, get_varname(instr), nothing)
    end
end


function Base.append!(ci1::CodeInfo, ci2::CodeInfo)
    if ci1.typed != ci2.typed
        throw(ArgumentError("Cannot append IR with different typing status"))
    end

    for instr in ci2.instrs
        push!(ci1, instr)
    end
end

function Base.iterate(ci::CodeInfo)
    return iterate(ci.instrs)
end

function Base.iterate(ci::CodeInfo, state)
    return iterate(ci.instrs, state)
end

function Base.getindex(ci::CodeInfo, idx::Int)
    return ci.instrs[idx]
end

function Base.show(io::IO, ci::CodeInfo)
    if length(ci.instrs) == 0
        println(io, "Empty IR")
        return
    end

    instrs = ci.instrs

    idx_width = max(ndigits(length(instrs)), 3)
    instrtype_width = max(maximum(x -> length(string(x.instrtype)), instr for instr in instrs), 10)

    println(io, "| ", lpad("idx", idx_width), " | ", lpad("instrtype", instrtype_width), " | instr")
    println(io, "| ", "-"^idx_width, " | ", "-"^instrtype_width, " | ", "-"^40)

    for (idx, instr) in enumerate(instrs)
        println(io, "| ", lpad(string(idx), idx_width), " | ", lpad(string(instr.instrtype), instrtype_width), " | ", instr)
    end
end

function Base.show(io::IO, mi::MethodInfo)
    print(io, "function ", mi.name, "(")
    for i in 1:length(mi.argname)
        print(io, mi.argname[i])
        print(io, "::", mi.signature[i])
        if i < length(mi.argname)
            print(io, ", ")
        end
    end
    println(io, ")")
    println(io)
    println(io, mi.ci)
    println(io, "end")
end

const ProgramIR = Vector{MethodInfo}

function Base.show(io::IO, program::ProgramIR)
    for mi in program
        println(io, mi)
    end
end


end # module MuIR
