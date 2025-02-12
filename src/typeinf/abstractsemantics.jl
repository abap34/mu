function _abstract_builtincall(f, arg_abstractvalues)::DataType
    return MuBuiltins.get_tfuncs(f.name)(MuTypes.normalize.(arg_abstractvalues))
end

function _abstract_genericscall(f, arg_abstractvalues, astate::AbstractState)::DataType
    mt = astate.mt

    macthed_methods = MuInterpreter.lookup(mt, f, MuTypes.Signature(arg_abstractvalues), matching=:possible)

    inferred = MuTypes.Bottom

    for methodid in macthed_methods
        mi = MuInterpreter.mi_by_id(mt, methodid)
        sig = mi.signature

        _inferred = return_type(
            mi,
            argtypes=MuTypes.meettype.(sig, arg_abstractvalues),
            mt=mt
        )

        inferred = MuTypes.jointype(inferred, _inferred)
    end

    return inferred
end

function _abstract_execute(expr::MuAST.Ident, astate::AbstractState)::DataType
    if haskey(astate, expr)
        return lookup(astate, expr)
    else
        throw(ArgumentError("Variable $(expr.name) not found in the abstract state"))
    end
end

function _abstract_execute(expr::MuAST.Literal, astate::AbstractState)::DataType
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

    if expr.head == MuAST.BCALL || expr.head == MuAST.GCALL
        try
            if expr.head == MuAST.BCALL
                return _abstract_builtincall(f, arg_abstractvalues)
            else
                return _abstract_genericscall(f, arg_abstractvalues, astate)
            end
        catch e
            @error "Failed to call $(expr.head) function $(f.name) with arguments:\n$(arg_abstractvalues) with state:\n$(astate)"
            rethrow(e)
        end
    else
        throw(ArgumentError("Unknown expression type: $(expr.head). Expected `IDENT`, `LITERAL`, `BCALL`, or `GCALL`"))
    end
end


function abstract_semantics(instr::MuIR.Instr)::Function
    if instr.instrtype == MuIR.ASSIGN
        lhs, rhs = instr.expr.args
        return function (astate)
            astate_new = copy(astate)
            bind!(astate_new, lhs, _abstract_execute(rhs, astate))
            return astate_new
        end

    elseif instr.instrtype == MuIR.GOTO || instr.instrtype == MuIR.GOTOIFNOT || instr.instrtype == MuIR.LABEL
        return identity

    elseif instr.instrtype == MuIR.RETURN
        return identity

    else
        throw(ArgumentError("Unknown InstrType: $(instr.instrtype)"))
    end
end

