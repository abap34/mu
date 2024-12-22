module MuBuiltins

builtins = Dict{String,Function}()

function run_builtin!(f::String, args::AbstractArray, env::Dict{String,Any})
    return get_builtin(f)(args, env)
end

function get_builtin(f::String)
    return builtins[f]
end

macro builtin(ex)
    f = string(ex.args[1].args[1])
    quote
        builtins[$f] = eval($ex)
    end |> esc
end


@builtin function add(args::AbstractArray, env::Dict{String,Any})
    return args[1] + args[2]
end

@builtin function sub(args::AbstractArray, env::Dict{String,Any})
    return args[1] - args[2]
end

@builtin function mul(args::AbstractArray, env::Dict{String,Any})
    return args[1] * args[2]
end

@builtin function div(args::AbstractArray, env::Dict{String,Any})
    return args[1] / args[2]
end

@builtin function mod(args::AbstractArray, env::Dict{String,Any})
    return args[1] % args[2]
end

@builtin function eq(args::AbstractArray, env::Dict{String,Any})
    return args[1] == args[2]
end

@builtin function neq(args::AbstractArray, env::Dict{String,Any})
    return args[1] != args[2]
end

@builtin function lt(args::AbstractArray, env::Dict{String,Any})
    return args[1] < args[2]
end

@builtin function gt(args::AbstractArray, env::Dict{String,Any})
    return args[1] > args[2]
end

@builtin function le(args::AbstractArray, env::Dict{String,Any})
    return args[1] <= args[2]
end

@builtin function ge(args::AbstractArray, env::Dict{String,Any})
    return args[1] >= args[2]
end

@builtin function read_as_int(args::AbstractArray, env::Dict{String,Any})
    Base.print("read_as_int> ")
    result = Base.parse(Int, readline())
    println()
    return result
end

@builtin function stack(args::AbstractArray, env::Dict{String,Any})
    return Base.stack(args)
end

@builtin function print(args::AbstractArray, env::Dict{String,Any})
    Base.println(args...)
end


end # module MuBuiltins
