module MuBuiltins

using ..MuTypes

const BUILTINS = Dict{String,Function}()
const TFUNCS = Dict{String,Function}()


function get_builtin(f::String)
    if haskey(BUILTINS, f)
        return BUILTINS[f]
    else
        Base.throw("Unknown builtin: $f")
    end
end

function builtinnames()
    return keys(BUILTINS)
end


macro builtin(ex)
    f = string(ex.args[1].args[1])
    quote
        BUILTINS[$f] = eval($ex)
    end |> esc
end

function set_constant!(name::String, type::DataType)
    @assert type <: MuType
    @assert !haskey(TFUNCS, name)
    @assert haskey(BUILTINS, name)
    TFUNCS[name] = (_...) -> type
end

include("impl.jl")
include("tfuncs.jl")


end # module MuBuiltins