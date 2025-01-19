import Base

struct Signature
    types::Vector{DataType}
    function Signature(types::Base.AbstractArray)
        if any(sig -> !(sig <: MuTypes.MuType), types)
            throw(ArgumentError("All signature must be MuTypes. Got $types"))
        end
        return new(types)
    end
end

function NoArgSignature()
    return Signature(DataType[])
end

Base.length(sig::Signature) = length(sig.types)
Base.getindex(sig::Signature, i) = sig.types[i]
Base.iterate(sig::Signature, state...) = iterate(sig.types, state...)


function formalargs_to_signature(formalargs::MuAST.Expr)
    @assert formalargs.head == MuAST.FORMALARGS "Expected FORMALARGS. Got $(formalargs.head)"
    return Signature([MuTypes.expr_to_type(arg.args[2]) for arg in formalargs.args])
end

function same_length(sig1::Signature, sig2::Signature)::Base.Bool
    return length(sig1) == length(sig2)
end


# Exists an `i` s.t sig1[i] <: sig2[i]
# and no `j` s.t sig2[j] <: sig1[j], sig1 is more specific than sig2.
# check no `j` s.t sig2[j] <: sig1[j]
function specificity(sig1::Signature, sig2::Signature)::Base.Bool
    (same_length(sig1, sig2)) || throw(ArgumentError("Length of sig1 and sig2 must be the same. Got $(length(sig1)) and $(length(sig2))"))
    
    for (s1, s2) in zip(sig1, sig2)
        if MuTypes.issubtype(s2, s1)
            return false
        end
    end

    for (s1, s2) in zip(sig1, sig2)
        if MuTypes.issubtype(s1, s2)
            return true
        end
    end

    return false
end

# Is is allowed to call a function with the given signature with the given actual arguments?
function ismatch(sig1::Signature, sig2::Signature)::Base.Bool
    (same_length(sig1, sig2)) || return false

    for (sig, actual) in zip(sig1, sig2)
        if !MuTypes.issubtype(actual, sig)
            return false
        end
    end

    return true
end

# Is there a possibility to call a `signature` with subtypes of `actual_args`?
# e.g. ispossible(Signature([Int, Int]), Signature([Real, Real])) => true. 
#      ispossible(Signature([Int, Int]), Signature([Real, Bool])) => false. 
#      ispossible(Signature([Int, Int]), Signature([Union{Int, Float}, Union{Int, Bool}])) => true.
function ispossible(sig1::Signature, sig2::Signature)::Base.Bool
    (same_length(sig1, sig2)) || return false

    for (sig, actual) in zip(sig1, sig2)
        meet = MuTypes.meettype(sig, actual)
        if meet == MuTypes.Bottom
            return false
        end
    end

    return true
end