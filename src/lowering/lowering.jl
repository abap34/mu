include("ir.jl")

using .MuIR
import .MuAST


function id_gen()
    id = 0
    return function ()
        id += 1
        return id
    end
end

label_gen = id_gen()
mi_gen = id_gen()
_varname_gen = id_gen()

RETURN_LABEL_ID = -1

var_gen(arg::MuAST.Ident) = arg
var_gen(arg::MuAST.Literal) = arg
var_gen(arg) = MuAST.Ident("%$(_varname_gen())")

function pushlabel!(ci::MuIR.CodeInfo, label::Int)
    push!(ci, MuIR.Instr(MuIR.LABEL, MuAST.Expr(MuAST.LABEL, [label])))
end

function pushgoto!(ci::MuIR.CodeInfo, label::Int)
    push!(ci, MuIR.Instr(MuIR.GOTO, MuAST.Expr(MuAST.GOTO, [label])))
end

function pushgotoifnot!(ci::MuIR.CodeInfo, label::Int, cond::MuAST.SyntaxNode)
    push!(ci, MuIR.Instr(MuIR.GOTOIFNOT, MuAST.Expr(MuAST.GOTOIFNOT, Any[label, cond])))
end

# Direct embedding in arguments
function add_subexpr!(expr::MuAST.Literal, myname::MuAST.Literal, ci::MuIR.CodeInfo) end
function add_subexpr!(expr::MuAST.Ident, myname::MuAST.Ident, ci::MuIR.CodeInfo)
    if expr != myname
        push!(ci, MuIR.Instr(MuIR.ASSIGN, MuAST.Expr(MuAST.ASSIGN, [myname, expr])))
    end
end

function add_subexpr!(expr::MuAST.Literal, myname::MuAST.Ident, ci::MuIR.CodeInfo)
    push!(
        ci,
        MuIR.Instr(MuIR.ASSIGN, MuAST.Expr(MuAST.ASSIGN, [myname, expr]))
    )
end


function add_subexpr!(expr::MuAST.Expr, myname::MuAST.Ident, ci::MuIR.CodeInfo)
    f, args... = expr.args

    tmpnames = [var_gen(arg) for arg in args]

    for (tmpname, subexpr) in zip(tmpnames, args)
        add_subexpr!(subexpr, tmpname, ci)
    end

    assign_ast = MuAST.Expr(MuAST.ASSIGN, [myname, MuAST.Expr(expr.head, [f, tmpnames...])])

    assign_instr = MuIR.Instr(
        MuIR.ASSIGN,
        assign_ast
    )

    push!(
        ci,
        assign_instr
    )
end

_lowering(x::MuAST.Literal) = x

function _lowering(expr::MuAST.Expr)
    ci = MuIR.CodeInfo()

    if expr.head == MuAST.GCALL || expr.head == MuAST.BCALL
        call_ci = MuIR.CodeInfo()

        add_subexpr!(expr, MuAST.UNUSED_IDENT, call_ci)

        append!(ci, call_ci)

    elseif expr.head == MuAST.ASSIGN
        ident, rhs = expr.args

        rhs_ci = MuIR.CodeInfo()

        add_subexpr!(rhs, ident, rhs_ci)

        append!(ci, rhs_ci)

    elseif expr.head == MuAST.BLOCK
        for arg in expr.args
            append!(ci, _lowering(arg))
        end

    elseif expr.head == MuAST.PROGRAM
        for arg in expr.args
            append!(ci, _lowering(arg))
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
        add_subexpr!(cond, cond_var, ci)

        pushgotoifnot!(ci, cond_label_id, cond_var)
        append!(ci, _lowering(body))
        pushgoto!(ci, end_label_id)
        pushlabel!(ci, cond_label_id)
        append!(ci, _lowering(elsebody))
        pushlabel!(ci, end_label_id)

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
        add_subexpr!(cond, cond_var, ci)

        pushgotoifnot!(ci, cond_label_id, cond_var)
        append!(ci, _lowering(body))
        pushlabel!(ci, cond_label_id)

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

        pushlabel!(ci, cond_label_id)

        add_subexpr!(cond, cond_var, ci)
        pushgotoifnot!(ci, end_label_id, cond_var)
        append!(ci, _lowering(body))
        pushgoto!(ci, cond_label_id)
        pushlabel!(ci, end_label_id)

    elseif expr.head == MuAST.RETURN
        # push!(ci, MuIR.Instr(MuIR.RETURN, expr))

        # 
        # return expr
        # 
        # ↓
        # %ret = expr
        # goto returnlabel
        # ...
        # label returnlabel       # <-- These labels are added by top level lowering. 
        # return %ret             #     So we don't need to add them here.

        returnbody = expr.args[1]
        append!(ci, _lowering(MuAST.Expr(MuAST.ASSIGN, [MuAST.RETURN_IDENT, returnbody])))
        pushgoto!(ci, RETURN_LABEL_ID)

    else
        throw(ArgumentError("Unsupported expression: $expr"))
    end

    return ci
end

function set_return_point!(ci::MuIR.CodeInfo)
    push!(ci, MuIR.Instr(MuIR.LABEL, MuAST.Expr(MuAST.LABEL, [RETURN_LABEL_ID])))
    push!(ci, MuIR.Instr(MuIR.RETURN, MuAST.Expr(MuAST.RETURN, [MuAST.RETURN_IDENT])))
end



# Interface of lowering.
function lowering(expr::MuAST.Expr)::MuIR.ProgramIR
    @assert expr.head == MuAST.PROGRAM "Lowering must be called with a PROGRAM. Got $expr"

    lowerd = MuIR.ProgramIR()

    for _function in expr.args
        name, args, body = _function.args

        ci = _lowering(body)

        set_return_point!(ci)

        mi = MuIR.MethodInfo(name, args, ci, mi_gen())

        push!(lowerd, mi)
    end

    return lowerd
end
