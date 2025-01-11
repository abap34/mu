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

function set_constant!(name::String, input::AbstractArray, output::DataType)
    @assert all(x -> x isa DataType, input)
    @assert output <: MuTypes.MuType
    @assert !haskey(TFUNCS, name) "TFunc $name already exists"
    @assert haskey(BUILTINS, name) "Builtin $name does not exist"
    TFUNCS[name] = function (argtypes::AbstractArray)
        for (i, (argtype, expected)) in enumerate(zip(argtypes, input))
            if !(MuTypes.issubtype(argtype, expected))
                @warn "Argument $i of $name expects subtype of $expected. Got $argtype"
                return MuTypes.Bottom
            end
        end

        return output
    end
end

include("impl.jl")
include("tfuncs.jl")


end # module MuBuiltins