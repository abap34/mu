include("ir.jl")

using .MuIR
using .MuBuiltins
import .MuAST


function id_gen()
    id = 0
    return function ()
        id += 1
        return id
    end
end

label_gen = id_gen()
codeinfo_gen = id_gen()
_varname_gen = id_gen()

var_gen(arg::MuAST.Ident) = arg
var_gen(arg::MuAST.Literal) = arg
var_gen(arg) = MuAST.Ident("%$(_varname_gen())")

function pushlabel!(ir::MuIR.IR, label::Int)
    push!(ir, MuIR.Instr(MuIR.LABEL, MuAST.Expr(MuAST.LABEL, [label])))
end

function pushgoto!(ir::MuIR.IR, label::Int)
    push!(ir, MuIR.Instr(MuIR.GOTO, MuAST.Expr(MuAST.GOTO, [label])))
end

function pushgotoifnot!(ir::MuIR.IR, label::Int, cond::MuAST.AbstractSyntaxNode)
    push!(ir, MuIR.Instr(MuIR.GOTOIFNOT, MuAST.Expr(MuAST.GOTOIFNOT, [label, cond])))
end

# Direct embedding in arguments
function add_subexpr!(expr::MuAST.Literal, myname::MuAST.Literal, ir::MuIR.IR) end
function add_subexpr!(expr::MuAST.Ident, myname::MuAST.Ident, ir::MuIR.IR) end

function add_subexpr!(expr::MuAST.Literal, myname::MuAST.Ident, ir::MuIR.IR)
    push!(
        ir,
        MuIR.Instr(MuIR.ASSIGN, MuAST.Expr(MuAST.ASSIGN, [myname, expr]))
    )
end


function add_subexpr!(expr::MuAST.Expr, myname::MuAST.Ident, ir::MuIR.IR)
    f, args... = expr.args


    tmpnames = [var_gen(arg) for arg in args]

    for (tmpname, subexpr) in zip(tmpnames, args)
        add_subexpr!(subexpr, tmpname, ir)
    end

    assign_ast = MuAST.Expr(MuAST.ASSIGN, [myname, MuAST.Expr(MuAST.GCALL, [f, tmpnames...])])

    assign_instr = MuIR.Instr(
        MuIR.ASSIGN,
        assign_ast
    )

    push!(ir,
        assign_instr
    )
end

_lowering(x::MuAST.Literal) = x

function _lowering(expr::MuAST.Expr)
    ir = MuIR.IR()

    if expr.head == MuAST.GCALL
        call_ir = MuIR.IR()

        add_subexpr!(expr, MuAST.UNUSED_IDENT, call_ir)

        append!(ir, call_ir)

    elseif expr.head == MuAST.ASSIGN
        ident, rhs = expr.args

        rhs_ir = MuIR.IR()

        add_subexpr!(rhs, ident, rhs_ir)

        append!(ir, rhs_ir)

    elseif expr.head == MuAST.BLOCK
        for arg in expr.args
            append!(ir, _lowering(arg))
        end

    elseif expr.head == MuAST.PROGRAM
        for arg in expr.args
            append!(ir, _lowering(arg))
        end

    elseif expr.head == MuAST.IFELSE
        # if cond 
        #     body
        # else
        #     elsebody
        # end
        #
        # ↓
        # goto cond_label if not cond 
        # body
        # goto end_label
        # label cond_label
        # elsebody
        # label end_label

        cond, body, elsebody = expr.args

        cond_label_id = label_gen()
        end_label_id = label_gen()

        cond_var = var_gen(cond)
        add_subexpr!(cond, cond_var, ir)

        pushgotoifnot!(ir, cond_label_id, cond_var)
        append!(ir, _lowering(body))
        pushgoto!(ir, end_label_id)
        pushlabel!(ir, cond_label_id)
        append!(ir, _lowering(elsebody))
        pushlabel!(ir, end_label_id)

    elseif expr.head == MuAST.IF
        # if cond 
        #     body
        # end
        #
        # ↓
        # goto cond_label if not cond 
        # body
        # label cond_label

        cond, body = expr.args

        cond_label_id = label_gen()
        
        cond_var = var_gen(cond)
        add_subexpr!(cond, cond_var, ir)

        pushgotoifnot!(ir, cond_label_id, cond_var)
        append!(ir, _lowering(body))
        pushlabel!(ir, cond_label_id)

    elseif expr.head == MuAST.WHILE
        # while (cond) 
        #     body
        #
        # ↓
        # label cond_label
        # goto end_label if not cond
        # body
        # goto cond_label
        # label end_label

        cond, body = expr.args

        cond_label_id = label_gen()
        end_label_id = label_gen()

        cond_var = var_gen(cond)
        add_subexpr!(cond, cond_var, ir)

        pushlabel!(ir, cond_label_id)
        pushgotoifnot!(ir, end_label_id, cond_var)
        append!(ir, _lowering(body))
        pushgoto!(ir, cond_label_id)
        pushlabel!(ir, end_label_id)

    elseif expr.head == MuAST.RETURN
        push!(ir, MuIR.Instr(MuIR.RETURN, expr))
    else
        throw(ArgumentError("Unsupported expression: $expr"))
    end

    return ir
end


# Interface of lowering.
function lowering(expr::MuAST.Expr)::MuIR.ProgramIR
    @assert expr.head == MuAST.PROGRAM "Lowering must be called with a PROGRAM. Got $expr"

    lowerd = MuIR.ProgramIR()

    for _function in expr.args
        name, args, body = _function.args

        ir = _lowering(body)

        push!(lowerd, MuIR.CodeInfo(name, args, ir, codeinfo_gen()))
    end

    return lowerd
end
