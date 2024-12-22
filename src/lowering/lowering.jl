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
var_gen = id_gen()
varname_gen() = "%" * string(var_gen())


function pushlabel!(instrs::MuIR.IR, label::Int)
    push!(instrs, Instr(MuIR.LABEL, MuAST.Expr(MuAST.LABEL, [label])))
end

function pushgoto!(instrs::MuIR.IR, label::Int)
    push!(instrs, Instr(MuIR.GOTO, MuAST.Expr(MuAST.GOTO, [label])))
end

function pushgotoifnot!(instrs::MuIR.IR, label::Int, cond::MuAST.AbstractSyntaxNode)
    push!(instrs, Instr(MuIR.GOTOIFNOT, MuAST.Expr(MuAST.GOTOIFNOT, [label, cond])))
end



function add_subexpr!(expr::MuAST.Literal, myname::String, instrs::MuIR.IR)
    pushfirst!(instrs, Instr(ASSIGN, MuAST.Expr(MuAST.ASSIGN, [MuAST.Ident(myname), expr])))
end

# Nothing to do.
function add_subexpr!(_::MuAST.Ident, myname::String, instrs::MuIR.IR) end

function add_subexpr!(expr::MuAST.Expr, myname::String, instrs::MuIR.IR)
    f, args... = expr.args

    tmpnames = [varname_gen() for _ in eachindex(args)]

    for (tmpname, subexpr) in zip(tmpnames, args)
        add_subexpr!(subexpr, tmpname, instrs)
    end

    push!(instrs,
        Instr(ASSIGN,
            MuAST.Expr(
                MuAST.ASSIGN,
                [MuAST.Ident(myname), MuAST.Expr(MuAST.CALL, [f, tmpnames...])]
            )
        )
    )
end

lowering(x::MuAST.Literal) = x

function lowering(expr::MuAST.Expr)
    instrs = MuIR.IR()

    if expr.head == MuAST.CALL
        call_instrs = MuIR.IR()
        add_subexpr!(expr.args, varname_gen(), call_instrs)
        append!(instrs, call_instrs)

    elseif expr.head == MuAST.ASSIGN
        ident, rhs = expr.args

        rhs_instrs = MuIR.IR()

        add_subexpr!(rhs, ident.name, rhs_instrs)

        append!(instrs, rhs_instrs)


    elseif expr.head == MuAST.BLOCK
        for arg in expr.args
            append!(instrs, lowering(arg))
        end

    elseif expr.head == MuAST.PROGRAM
        for arg in expr.args
            append!(instrs, lowering(arg))
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

        pushgotoifnot!(instrs, cond_label_id, cond)
        append!(instrs, lowering(body))
        pushgoto!(instrs, end_label_id)
        pushlabel!(instrs, cond_label_id)
        append!(instrs, lowering(elsebody))
        pushlabel!(instrs, end_label_id)

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

        pushgotoifnot!(instrs, cond_label_id, cond)
        append!(instrs, lowering(body))
        pushlabel!(instrs, cond_label_id)

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

        pushlabel!(instrs, cond_label_id)
        pushgotoifnot!(instrs, end_label_id, cond)
        append!(instrs, lowering(body))
        pushgoto!(instrs, cond_label_id)
        pushlabel!(instrs, end_label_id)
        
    else
        throw(ArgumentError("Unsupported expression: $expr"))
    end

    return instrs
end

export lowering



