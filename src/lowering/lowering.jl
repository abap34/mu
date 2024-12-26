include("ir.jl")

using .MuIR: Instr, IRType, CALL, ASSIGN, GOTO, GOTOIFNOT, LABEL
import .MuAST


function id_gen()
    id = 0
    return function ()
        id += 1
        return id
    end
end

label_gen = id_gen()
_varname_gen = id_gen()

var_gen(arg::MuAST.Ident) = arg
var_gen(arg::MuAST.Literal) = arg
var_gen(arg) = MuAST.Ident("%$(_varname_gen())")

function pushlabel!(ir::MuIR.IR, label::Int)
    push!(ir, Instr(MuIR.LABEL, MuAST.Expr(MuAST.LABEL, [label])))
end

function pushgoto!(ir::MuIR.IR, label::Int)
    push!(ir, Instr(MuIR.GOTO, MuAST.Expr(MuAST.GOTO, [label])))
end

function pushgotoifnot!(ir::MuIR.IR, label::Int, cond::MuAST.AbstractSyntaxNode)
    push!(ir, Instr(MuIR.GOTOIFNOT, MuAST.Expr(MuAST.GOTOIFNOT, [label, cond])))
end

# Direct embedding in arguments
function add_subexpr!(expr::MuAST.Literal, myname::MuAST.Literal, ir::MuIR.IR) end
function add_subexpr!(expr::MuAST.Ident, myname::MuAST.Ident, ir::MuIR.IR) end

function add_subexpr!(expr::MuAST.Literal, myname::MuAST.Ident, ir::MuIR.IR)
    push!(
        ir,
        Instr(ASSIGN, MuAST.Expr(MuAST.ASSIGN, [myname, expr]))
    )
end


function add_subexpr!(expr::MuAST.Expr, myname::MuAST.Ident, ir::MuIR.IR)
    f, args... = expr.args


    tmpnames = [var_gen(arg) for arg in args]

    for (tmpname, subexpr) in zip(tmpnames, args)
        add_subexpr!(subexpr, tmpname, ir)
    end

    assign_ast = MuAST.Expr(MuAST.ASSIGN, [myname, MuAST.Expr(MuAST.CALL, [f, tmpnames...])])

    assign_instr = Instr(
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

    if expr.head == MuAST.CALL
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

        pushgotoifnot!(ir, cond_label_id, cond)
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

        pushgotoifnot!(ir, cond_label_id, cond)
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

        pushlabel!(ir, cond_label_id)
        pushgotoifnot!(ir, end_label_id, cond)
        append!(ir, _lowering(body))
        pushgoto!(ir, cond_label_id)
        pushlabel!(ir, end_label_id)

    elseif expr.head == MuAST.RETURN
        push!(ir, Instr(MuIR.RETURN, expr)) 

    else
        throw(ArgumentError("Unsupported expression: $expr"))
    end

    return ir
end

# Interface of lowering

function lowering(expr::MuAST.Expr)
    if expr.head == MuAST.PROGRAM
        lowerd = MuIR.CodeInfo[]

        for function_def in expr.args
            if function_def.head != MuAST.FUNCTION
                throw(ArgumentError("Top-level expression must be a function definition. Got $function_def"))
            end

            name, typed_args, body = function_def.args

            ir = _lowering(body)

            push!(lowerd, MuIR.CodeInfo(name, typed_args, ir))
        end

        return lowerd

    elseif expr.head == MuAST.FUNCTION
        name, args, body = expr.args

        ir = _lowering(body)

        return MuIR.CodeInfo(name, args, ir)
    else
        throw(ArgumentError("Unsupported expression head. It must be either PROGRAM or FUNCTION. Got $expr"))
    end

end
