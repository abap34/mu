module MuInterpreter

import ..MuBuiltins
import ..MuAST
import ..MuIR


function run_expr(expr::MuAST.Expr, env::Dict{String, Any})
    if expr.head == MuAST.CALL
        f, args... = expr.args

        builtin_args = run_expr.(args, Ref(env))

        return MuBuiltins.run_builtin!(f.name, builtin_args, env)
    else
        throw("Unkonwn expr type: $expr")
    end
end

function run_expr(expr::MuAST.Literal, env::Dict{String, Any})
    return expr
end

function run_expr(ident::MuAST.Ident, env::Dict{String, Any})
    return env[ident.name]
end

function interpret!(instr::MuIR.Instr, env::Dict{String, Any}, pc::Int, label_to_pc::Dict{Int, Int})
    if instr.irtype == MuIR.CALL
        f, args... = instr.expr.args

        run_builtin!(f, args, env)

        return pc + 1

    elseif instr.irtype == MuIR.ASSIGN
        ident, rhs = instr.expr.args

        env[ident.name] = run_expr(rhs, env)

        return pc + 1


    elseif instr.irtype == MuIR.GOTO
        return label_to_pc[instr.expr.args[1]]
    
    elseif instr.irtype == MuIR.GOTOIFNOT
        label, cond = instr.expr.args

        if !run_expr(cond, env)
            return label_to_pc[label]
        else
            return pc + 1
        end
    elseif instr.irtype == MuIR.LABEL
        return pc + 1
    end
end


function interpret(ir::MuIR.IR)
    label_to_pc = Dict{Int, Int}()
    for (pc, instr) in enumerate(ir)
        if instr.irtype == MuIR.LABEL
            label_to_pc[instr.expr.args[1]] = pc
        end
    end

    env = Dict{String, Any}()
    
    pc = 1
    
    while pc <= length(ir)
        instr = ir[pc]
        try 
            pc = interpret!(instr, env, pc, label_to_pc)
        catch e
            println("Failed to interpret: $instr")
            throw(e)
        end
    end
    
    return env
end


end # module MuInterpreter