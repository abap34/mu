mutable struct ConcreateInterpreter
    env::Dict{String,Any}
    label_to_pc::Dict{Int,Int}
    function ConcreateInterpreter()
        new(Dict{String,Any}(), Dict{Int,Int}())
    end
end

function run_builtin!(f::String, args::AbstractArray, interp::ConcreateInterpreter)
    return MuBuiltins.get_builtin(f)(args, interp.env)
end

function run_expr(expr::MuAST.Expr, interp::ConcreateInterpreter)
    if expr.head == MuAST.GCALL
        f, args... = expr.args
        builtin_args = run_expr.(args, Ref(interp))
        return run_builtin!(f.name, builtin_args, interp)
    else
        throw("Unkonwn expr type: $expr")
    end
end

function run_expr(expr::MuAST.Literal, interp::ConcreateInterpreter)
    return expr
end

function run_expr(ident::MuAST.Ident, interp::ConcreateInterpreter)
    return interp.env[ident.name]
end

function execute!(instr::MuIR.Instr, interp::ConcreateInterpreter, pc::Int)
    if instr.irtype == MuIR.ASSIGN
        ident, rhs = instr.expr.args

        interp.env[ident.name] = run_expr(rhs, interp)

        return pc + 1

    elseif instr.irtype == MuIR.GOTO
        return interp.label_to_pc[instr.expr.args[1]]

    elseif instr.irtype == MuIR.GOTOIFNOT
        label, cond = instr.expr.args

        if !run_expr(cond, interp)
            return interp.label_to_pc[label]
        else
            return pc + 1
        end
    elseif instr.irtype == MuIR.LABEL
        return pc + 1
    end
end


function interpret(ir::MuIR.IR, interp::ConcreateInterpreter)
    for (pc, instr) in enumerate(ir)
        if instr.irtype == MuIR.LABEL
            interp.label_to_pc[instr.expr.args[1]] = pc
        end
    end

    pc = 1

    while pc <= length(ir)
        instr = ir[pc]
        try
            pc = execute!(instr, interp, pc)
        catch e
            println("Failed to interpret: $instr")
            throw(e)
        end
    end

    return nothing
end

