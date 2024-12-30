using ..MuTypes

# Exists an `i` s.t t1[i] <: t2[i]
# and no `j` s.t t2[j] <: t1[j], t1 is more specific than t2.

# check no `j` s.t t2[j] <: t1[j]
function specificity(t1::AbstractArray, t2::AbstractArray)
    @assert length(t1) == length(t2) "Expected two vectors of the same length. Got $(length(t1)) and $(length(t2))"

    for j in eachindex(t1)
        if MuTypes.issubtype(t2[j], t1[j])
            return false
        end
    end

    # check exists an `i` s.t t1[i] <: t2[i]
    for i in eachindex(t1)
        if MuTypes.issubtype(t1[i], t2[i])
            return true
        end
    end

    return false
end


# Is is allowed to call a function with the given signature with the given actual arguments?
function ismatch(signature::AbstractArray, actual_args::AbstractArray)
    @assert all(arg -> arg <: MuTypes.MuType, signature) "All signature must be MuTypes. Got $signature"
    @assert all(arg -> arg <: MuTypes.MuType, actual_args) "All actual_args must be MuTypes. Got $signature"

    @assert length(signature) == length(actual_args) "Signature and actual arguments must have the same length. Got $(length(signature)) and $(length(actual_args))"
    for (sig, actual) in zip(signature, actual_args)
        if !MuTypes.issubtype(actual, sig)
            return false
        end
    end

    return true
end

# Wrapper for a dictionary of method tables
struct MethodTable
    # Function name -> Vector of (signature, IR, id) tuples
    table::Dict{MuAST.Ident, Vector{Tuple{Vector{DataType}, MuIR.IR, Int}}}
    id_to_codeinfo::Dict{Int, MuIR.CodeInfo}
    function MethodTable()
        new(Dict{MuAST.Ident,Vector{Tuple{MuAST.Expr, MuIR.IR}}}(), Dict{Int, MuIR.IR}())
    end
end

function method_names(methodtable::MethodTable)
    return keys(methodtable.table)
end

function formalarg_to_signature(formalargs::MuAST.Expr)
    @assert formalargs.head == MuAST.FORMALARGS "Expected FORMALARGS. Got $(formalargs.head)"
    return [MuTypes.astype(arg.args[2]) for arg in formalargs.args]
end

function add_method!(methodtable::MethodTable, codeinfo::MuIR.CodeInfo)
    add_method!(methodtable, codeinfo.name, codeinfo.args, codeinfo.ir, codeinfo.id)

    methodtable.id_to_codeinfo[codeinfo.id] = codeinfo
end

function add_method!(methodtable::MethodTable, name::MuAST.Ident, formalargs::MuAST.Expr, body::MuIR.IR, id::Int)
    @assert formalargs.head == MuAST.FORMALARGS "Expected FORMALARGS. Got $(formalargs.head)"
    @assert !haskey(methodtable.id_to_codeinfo, id) "Method with id $id already exists in method table."

    if haskey(methodtable.table, name)
        signature = formalarg_to_signature(formalargs)
        push!(methodtable.table[name], (signature, body, id))
    else
        signature = formalarg_to_signature(formalargs)
        methodtable.table[name] = [(signature, body, id)]
    end
end


# Lookup a method in the method table by name and signature and return the method id
function lookup(methodtable::MethodTable, name::MuAST.Ident, signature::AbstractArray)::Int
    @assert all(sig -> sig <: MuTypes.MuType, signature) "All arguments must be MuType. Got $signature"

    if !haskey(methodtable.table, name)
        throw(ArgumentError("Method $name not found in method table. Available methods: $(method_names(methodtable))"))
    end     

    # Vector of (signature, IR) tuples
    candidates = methodtable.table[name]

    # Remove methods which don't match argument count
    arg_count = length(signature)
    candidates = filter(candidate -> length(candidate[1]) == arg_count, candidates)

    # Sort by signatures "specificity"
    candidates = sort(candidates, lt=(a, b) -> specificity(a[1], b[1]))

    # Find the first method which matches the signature
    for (i, (cand_sig, _, id)) in enumerate(candidates)
        if ismatch(cand_sig, signature)
            # Check next candidate is same specificity and matches. 
            # If so, throw and `AmbiguousMethodError`
            if i < length(candidates) && specificity(candidates[i+1][1], cand_sig)
                throw(AmbiguousMethodError("Ambiguous method call. Multiple methods match the signature."))
            end
            return id
        end
    end

    throw(ArgumentError("No method found matching the signature. Given signature: $signature for method $name. Available signatures: $(map(x -> x[1], candidates))"))
end

function codeinfo_by_id(methodtable::MethodTable, id::Int)
    if !haskey(methodtable.id_to_codeinfo, id)
        throw(ArgumentError("Method with id $id not found in method table."))
    end

    return methodtable.id_to_codeinfo[id]
end

