using ..MuTypes

# Exists an `i` s.t t1[i] <: t2[i]
# and no `j` s.t t2[j] <: t1[j], t1 is more specific than t2.
# check no `j` s.t t2[j] <: t1[j]
function specificity(t1::AbstractArray{DataType}, t2::AbstractArray{DataType})
    for (t1, t2) in zip(t1, t2)
        if !(t1 <: MuTypes.MuType)
            throw(ArgumentError("All signature must be MuTypes. Got $t1"))
        end

        if !(t2 <: MuTypes.MuType)
            throw(ArgumentError("All signature must be MuTypes. Got $t2"))
        end
    end
    
    
    if length(t1) != length(t2)
        throw(ArgumentError("t1 and t2 must have the same length. Got $t1 (length: $(length(t1))) and $t2 (length: $(length(t2)))"))
    end



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
    if length(signature) != length(actual_args)
        return false
    end

    for (sig, actual) in zip(signature, actual_args)
        if !(sig <: MuTypes.MuType)
            throw(ArgumentError("All signature must be MuTypes. Got $signature"))
        end

        if !(actual <: MuTypes.MuType)
            throw(ArgumentError("All actual_args must be MuTypes. Got $signature"))
        end
    end

    for (sig, actual) in zip(signature, actual_args)
        if !MuTypes.issubtype(actual, sig)
            return false
        end
    end

    return true
end

# Wrapper for a dictionary of method tables
struct MethodTable
    # Function name -> Vector of CodeInfo 
    table::Dict{MuAST.Ident, Vector{MuIR.CodeInfo}}
    function MethodTable()
        new(Dict{MuAST.Ident, Vector{MuIR.CodeInfo}}())
    end
end

function Base.show(io::IO, methodtable::MethodTable)
    if isempty(methodtable.table)
        print(io, "MethodTable(Dict{}()) (empty)")
        return
    end

    println(io, "MethodTable:")
   
    name_width = max(10, maximum(length.(string.(keys(methodtable.table)))))

    if isempty(methodtable.table)
        println(io, "Empty method table.")
    else
        println(io, "│ $(rpad("Name", name_width)) │ Signature")
    end
        

    for (name, methods) in methodtable.table
        println(io, "├ $(repeat("─", name_width)) ┼ $(repeat("─", 40)) ")
        print(io, "│ $(lpad(name, name_width)) │ ")

        for method in methods
            if isempty(method.signature)
                print(io,  "#= No arguments =#")
            end
           
            for (j, arg) in enumerate(method.signature)
                print(io, arg)
                if j < length(method.signature)
                    print(io, ", ")
                end
            end
            println(io)
            print(io, "│ $(repeat(" ", name_width)) │ ") # padding
        end
        println(io)
    end
end

function method_names(methodtable::MethodTable)
    return keys(methodtable.table)
end

function add_method!(methodtable::MethodTable, codeinfo::MuIR.CodeInfo)
    if !haskey(methodtable.table, codeinfo.name)
        methodtable.table[codeinfo.name] = Vector{MuIR.CodeInfo}()
    end

    push!(methodtable.table[codeinfo.name], codeinfo)
end

function codeinfo_by_id(methodtable::MethodTable, id::Int)
    for (_, methods) in methodtable.table
        for method in methods
            if method.id == id
                return method
            end
        end
    end

    throw(ArgumentError("Method with id $id not found in method table."))
end


function codeinfo_by_name(methodtable::MethodTable, name::MuAST.Ident)
    if !haskey(methodtable.table, name)
        throw(ArgumentError("Method $name not found in method table. Available methods: $(method_names(methodtable))"))
    end

    return methodtable.table[name]
end


# Lookup a method in the method table by name and signature and return the method id
function lookup(methodtable::MethodTable, name::MuAST.Ident, expect_signature::AbstractArray)::Int
    @assert all(sig -> sig <: MuTypes.MuType, expect_signature) "All arguments must be MuType. Got $expect_signature"

    if !haskey(methodtable.table, name)
        throw(ArgumentError("Method $name not found in method table. Available methods: $(method_names(methodtable))"))
    end     

    candidates = codeinfo_by_name(methodtable, name)

    # Sort by signatures "specificity"
    candidates = sort(candidates, lt=(a, b) -> specificity(a.signature, b.signature))

    # Find the first method which matches the signature
    for (i, codeinfo) in enumerate(candidates)
        if ismatch(codeinfo.signature, expect_signature)
            # Check next candidate is same specificity and matches. 
            # If so, throw and `AmbiguousMethodError`
            if i < length(candidates) && specificity(candidates[i+1].signature, codeinfo.signature)
                throw(AmbiguousMethodError("Ambiguous method call. Multiple methods match the signature."))
            end
            return codeinfo.id
        end
    end

    throw(ArgumentError("No method found matching the signature. Given signature: $expect_signature for method $name. Available signatures: $(map(x -> x[1], candidates))"))
end


