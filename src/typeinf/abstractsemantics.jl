function _abstract_builtincall(f, arg_abstractvalues)
    return MuBuiltins.get_tfuncs(f.name)(arg_abstractvalues)
end
function _abstract_genericscall(f, arg_abstractvalues)
    # TODO
    throw(ArgumentError("Generics call not implemented yet"))
end

function _abstract_execute(expr::MuAST.Ident, astate::AbstractState)
    if haskey(astate, expr)
        return lookup(astate, expr)
    else
        throw(ArgumentError("Variable $(expr.name) not found in the abstract state"))
    end
end

function _abstract_execute(expr::MuAST.Literal, astate::AbstractState)
    return MuTypes.typeof(expr)
end

function _check_argpureness(args)
    if !all(arg -> arg isa MuAST.Ident || arg isa MuAST.Literal, args)
        throw(ArgumentError("Arguments must be LITERAL or IDENT. Got $(args)"))
    end
    return true
end

function fix_args(args, astate::AbstractState)
    _check_argpureness(args)
    return [_abstract_execute(arg, astate) for arg in args]
end

function _abstract_execute(expr::MuAST.Expr, astate::AbstractState)
    f, args... = expr.args
    arg_abstractvalues = fix_args(args, astate)

    if expr.head == MuAST.BCALL
        return _abstract_builtincall(f, arg_abstractvalues)
    elseif expr.head == MuAST.GCALL
        return _abstract_genericscall(f, arg_abstractvalues)
    else
        throw(ArgumentError("Unknown expression type: $(expr.head). Expected `IDENT`, `LITERAL`, `BCALL`, or `GCALL`"))
    end
end


function abstract_semantics(instr::MuIR.Instr)
    if instr.irtype == MuIR.ASSIGN
        lhs, rhs = instr.expr.args
        return function (astate)
            astate_new = copy(astate)
            bind!(astate_new, lhs, _abstract_execute(rhs, astate))
            return astate_new
        end

    elseif instr.irtype == MuIR.GOTO || instr.irtype == MuIR.GOTOIFNOT || instr.irtype == MuIR.LABEL
        return identity

    elseif instr.irtype == MuIR.RETURN
        return identity

    else
        throw(ArgumentError("Unknown IRType: $(instr.irtype)"))
    end
end

