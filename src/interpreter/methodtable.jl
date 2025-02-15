using ..MuTypes


# Wrapper for a dictionary of method tables
struct MethodTable
    # Function name -> Vector of MethodInfo
    table::Dict{MuAST.Ident,Vector{MuIR.MethodInfo}}
    function MethodTable(; table::Dict{MuAST.Ident,Vector{MuIR.MethodInfo}}=Dict{MuAST.Ident,Vector{MuIR.MethodInfo}}())
        new(table)
    end
end

function Base.copy(methodtable::MethodTable)
    return MethodTable(table=copy(methodtable.table))
end

function methodnames(methodtable::MethodTable)
    return keys(methodtable.table)
end

function methodinstances(methodtable::MethodTable)
    return Iterators.flatten(values(methodtable.table))
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

function add_method!(methodtable::MethodTable, mi::MuIR.MethodInfo)
    if !haskey(methodtable.table, mi.name)
        methodtable.table[mi.name] = Vector{MuIR.MethodInfo}()
    end

    push!(methodtable.table[mi.name], mi)
end

function mi_by_id(methodtable::MethodTable, id::Int)::MuIR.MethodInfo
    for (_, methods) in methodtable.table
        for method in methods
            if method.id == id
                return method
            end
        end
    end

    throw(ArgumentError("Method with id $id not found in method table."))
end


function mis_by_name(methodtable::MethodTable, name::MuAST.Ident)::Vector{MuIR.MethodInfo}
    if !haskey(methodtable.table, name)
        throw(ArgumentError("Method $name not found in method table. Available methods: $(method_names(methodtable))"))
    end

    return methodtable.table[name]
end


# Lookup a method in the method table by name and signature and return the Vector of MethodInfo ids.
# If `matching` is `:exact`, return the first method which matches the signature.
# If `matching` is `:possible`, return all methods which can be called with the given signature.
# If `matching` is `:all`, return all methods which match the signature.
function lookup(methodtable::MethodTable, name::MuAST.Ident, expect_signature::MuTypes.Signature; matching::Symbol=:exact)::Vector{Int}
    (matching in (:exact, :possible, :all)) || throw(ArgumentError("Matching must be one of :exact, :possible, :all. Got $matching"))

    matcher = (matching == :exact || matching == :all) ? MuTypes.ismatch : MuTypes.ispossible
    exact_match = matching == :exact

    if !haskey(methodtable.table, name)
        throw(ArgumentError("Method $name not found in method table. Available methods: $(method_names(methodtable))"))
    end

    candidates = mis_by_name(methodtable, name)

    # filter by argument count (without filter, we can't sort by specificity)
    candidates = filter(method -> length(method.signature) == length(expect_signature), candidates)

    # Sort by signatures "specificity"
    candidates = sort(candidates, lt=(a, b) -> MuTypes.specificity(a.signature, b.signature))

    match_methods = Int[]

    # Find the first method which matches the signature
    for (i, mi) in enumerate(candidates)
        if matcher(mi.signature, expect_signature)
            # Check next candidate is same specificity and matches. 
            # If so, throw and `AmbiguousMethodError`
            if exact_match
                if i < length(candidates) && MuTypes.specificity(candidates[i+1].signature, mi.signature)
                    throw(AmbiguousMethodError("Ambiguous method call. Multiple methods match the signature."))
                end
                return [mi.id,]
            else
                push!(match_methods, mi.id)
            end
        end
    end


    if exact_match && isempty(match_methods)
        throw(ArgumentError("""
            No method found for $name with 
            Given signature: $expect_signature
            Candidates     : $(candidates[1].signature)
                             $(join([mi.signature for mi in candidates[2:end]], "\n"))
            """))
    end

    return match_methods
end


