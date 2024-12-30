using ..MuTypes

# Exists an `i` s.t t1[i] <: t2[i]
# and no `j` s.t t2[j] <: t1[j], t1 is more specific than t2.

# check no `j` s.t t2[j] <: t1[j]
function specificity(t1::Vector{<: MuType}, t2::Vector{<: MuType})
    @assert length(t1) == length(t2) "Expected two vectors of the same length. Got $(length(t1)) and $(length(t2))"

    for j in eachindex(t1)
        if issubtype(t2[j], t1[j])
            return false
        end
    end

    # check exists an `i` s.t t1[i] <: t2[i]
    for i in eachindex(t1)
        if issubtype(t1[i], t2[i])
            return true
        end
    end

    return false
end


# Determine `actual_args` is a valid for `actual_args` ?
function ismatch(signature::Vector{MuType}, actual_args::Vector{MuType})
    @assert all(arg -> isa(arg, MuAST.Ident), signature) "All arguments must be Idents. Got $signature"
    @assert length(signature) == length(actual_args) "Signature and actual arguments must have the same length. Got $(length(signature)) and $(length(actual_args))"

    for (sig, actual) in zip(signature, actual_args)
        if !issubtype(actual, sig)
            return false
        end
    end

    return true
end

# Wrapper for a dictionary of method tables
struct MethodTable
    # Function name -> Vector of (signature, IR, id) tuples
    table::Dict{MuAST.Ident, Vector{Tuple{Vector{MuType}, MuIR.IR, Int}}}
    id_to_body::Dict{Int, MuIR.IR}
    function MethodTable()
        new(Dict{MuAST.Ident,Vector{Tuple{MuAST.Expr, MuIR.IR}}}(), Dict{Int, MuIR.IR}())
    end
end

function method_names(methodtable::MethodTable)
    return keys(methodtable.table)
end

function formalarg_to_signature(formalargs::MuAST.Expr)
    @assert formalargs.head == MuAST.FORMALARGS "Expected FORMALARGS. Got $(formalargs.head)"
    return (arg -> MuTypes.astype(arg) for arg in formalargs.args)
end

function add_method!(methodtable::MethodTable, codeinfo::MuIR.CodeInfo)
    add_method!(methodtable, codeinfo.name, codeinfo.args, codeinfo.ir, codeinfo.id)
end

function add_method!(methodtable::MethodTable, name::MuAST.Ident, formalargs::MuAST.Expr, body::MuIR.IR, id::Int)
    @assert args.head == MuAST.FORMALARGS "Expected FORMALARGS. Got $(formalargs.head)"
    @assert body.head == MuAST.BLOCK "Expected BLOCK. Got $(body.head)"
    @assert !haskey(methodtable.id_to_body, id) "Method with id $id already exists in method table."

    if haskey(methodtable.table, name)
        push!(methodtable.table[name], (formalargs, body, id))
    else
        signature = collect(formalarg_to_signature(formalargs))
        methodtable.table[name] = [(signature, body, id)]
    end


    methodtable.id_to_body[id] = body
end

# Lookup a method in the method table by name and signature and return the method id
function lookup(methodtable::MethodTable, name::MuAST.Ident, signature::Vector{MuType})::Int
    @assert all(arg -> isa(arg, MuAST.Ident), signature) "All arguments must be Idents. Got $signature"

    if !haskey(methodtable.table, name)
        throw(ArgumentError("Method $name not found in method table. Available methods: $(method_names(methodtable))"))
    end 

    # Vector of (signature, IR) tuples
    candidates::Vector{Tuple{Vector{MuType}, MuIR.IR}} = methodtable.table[name]

    # Remove methods which don't match argument count
    arg_count = length(signature)
    candidates = filter(candidate -> length(candidate[1]) == arg_count, candidates)

    # Sort by signatures "specificity"
    candidates = sort(candidates, lt=(a, b) -> specificity(a, b))

    # Find the first method which matches the signature
    for (i, (sig, body, id)) in enumerate(candidates)
        if ismatch(sig, signature)
            # Check next candidate is same specificity and matches. 
            # If so, throw and `AmbiguousMethodError`
            if i < length(candidates) && specificity(candidates[i+1][1], sig)
                throw(AmbiguousMethodError("Ambiguous method call. Multiple methods match the signature."))
            end
            return id
        end
    end
endend
