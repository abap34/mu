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
    # Function name -> Vector of MethodInstance
    table::Dict{MuAST.Ident,Vector{MuIR.MethodInstance}}
    function MethodTable()
        new(Dict{MuAST.Ident,Vector{MuIR.MethodInstance}}())
    end
end

function Base.show(io::IO, methodtable::MethodTable)
    if isempty(methodtable.table)
        print(io, "MethodTable(Dict{}()) (empty)")
        return
    end

    println(io, typeof(methodtable), " with $(length(methodtable.table)) entries")


    name_width = max(10, maximum(length.(string.(keys(methodtable.table)))))

    if isempty(methodtable.table)
        println(io, "Empty method table.")
    else
        println(io, "│ $(lpad("Name", name_width)) │ Signature")
    end


    for (name, methods) in methodtable.table
        println(io, "├ $(repeat("─", name_width)) ┼ $(repeat("─", 40)) ")
        print(io, "│ $(lpad(name, name_width)) │ ")

        for method in methods
            if isempty(method.signature)
                print(io, "#= No arguments =#")
            end

            print(io, "(")
            for (j, arg) in enumerate(method.signature)
                print(io, MuTypes.shorten_str(arg))
                if j < length(method.signature)
                    print(io, ", ")
                end
            end
            println(io, ")")
            println(io, ") (id: $(method.id))")
            

            print(io, "│ $(repeat(" ", name_width)) │ ") # padding
        end
        println(io)
    end
end

function method_names(methodtable::MethodTable)
    return keys(methodtable.table)
end

function load!(methodtable::MethodTable, lowered::MuIR.ProgramIR)
    for mi in lowered
        add_method!(methodtable, mi)
    end
end

function add_method!(methodtable::MethodTable, mi::MuIR.MethodInstance)
    if !haskey(methodtable.table, mi.name)
        methodtable.table[mi.name] = Vector{MuIR.MethodInstance}()
    end

    push!(methodtable.table[mi.name], mi)
end

function mi_by_id(methodtable::MethodTable, id::Int)::MuIR.MethodInstance
    for (_, methods) in methodtable.table
        for method in methods
            if method.id == id
                return method
            end
        end
    end

    throw(ArgumentError("Method with id $id not found in method table."))
end


function mis_by_name(methodtable::MethodTable, name::MuAST.Ident)::Vector{MuIR.MethodInstance}
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

    candidates = mis_by_name(methodtable, name)

    # filter by argument count (without filter, we can't sort by specificity)
    candidates = filter(method -> length(method.signature) == length(expect_signature), candidates)

    # Sort by signatures "specificity"
    candidates = sort(candidates, lt=(a, b) -> specificity(a.signature, b.signature))

    # Find the first method which matches the signature
    for (i, mi) in enumerate(candidates)
        if ismatch(mi.signature, expect_signature)
            # Check next candidate is same specificity and matches. 
            # If so, throw and `AmbiguousMethodError`
            if i < length(candidates) && specificity(candidates[i+1].signature, mi.signature)
                throw(AmbiguousMethodError("Ambiguous method call. Multiple methods match the signature."))
            end
            return mi.id
        end
    end

    throw(ArgumentError("""
    No method found matching the signature. 
    Given signature: $expect_signature
    Candidates     : $(join([mi.signature for mi in candidates], "\n"))
    """))

end


