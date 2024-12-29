module MuBuiltins

function get_builtin(f::String)
    if haskey(builtins, f)
        return builtins[f]
    else
        Base.throw("Unknown builtin: $f")
    end
end

function builtinnames()
    return keys(builtins)
end


builtins = Dict{String,Function}()

macro builtin(ex)
    f = string(ex.args[1].args[1])
    quote
        builtins[$f] = eval($ex)
    end |> esc
end


@builtin typeof(args::AbstractArray, env::Dict{String, Any}) = Base.typeof(args[1])
@builtin throw(args::AbstractArray, env::Dict{String, Any}) = Base.throw(args[1])

@builtin add_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] + args[2]
@builtin add_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] + args[2]
@builtin add_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] + args[2]
@builtin add_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] + args[2]
@builtin sub_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] - args[2]
@builtin sub_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] - args[2]
@builtin sub_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] - args[2]
@builtin sub_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] - args[2]
@builtin mul_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] * args[2]
@builtin mul_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] * args[2]
@builtin mul_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] * args[2]
@builtin mul_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] * args[2]
@builtin div_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] / args[2]
@builtin div_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] / args[2]
@builtin div_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] / args[2]
@builtin div_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] / args[2]
@builtin mod_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] % args[2]
@builtin mod_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] % args[2]
@builtin mod_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] % args[2]
@builtin mod_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] % args[2]
@builtin eq_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] == args[2]
@builtin eq_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] == args[2]
@builtin eq_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] == args[2]
@builtin eq_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] == args[2]
@builtin neq_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] != args[2]
@builtin neq_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] != args[2]
@builtin neq_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] != args[2]
@builtin neq_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] != args[2]
@builtin lt_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] < args[2]
@builtin lt_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] < args[2]
@builtin lt_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] < args[2]
@builtin lt_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] < args[2]
@builtin gt_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] > args[2]
@builtin gt_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] > args[2]
@builtin gt_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] > args[2]
@builtin gt_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] > args[2]
@builtin le_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] <= args[2]
@builtin le_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] <= args[2]
@builtin le_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] <= args[2]
@builtin le_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] <= args[2]
@builtin ge_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] >= args[2]
@builtin ge_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] >= args[2]
@builtin ge_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] >= args[2]
@builtin ge_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] >= args[2]
@builtin and_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] && args[2]
@builtin and_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] && args[2]
@builtin and_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] && args[2]
@builtin and_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] && args[2]
@builtin or_int_int(args::AbstractArray, env::Dict{String, Any}) = args[1] || args[2]
@builtin or_int_float(args::AbstractArray, env::Dict{String, Any}) = args[1] || args[2]
@builtin or_float_int(args::AbstractArray, env::Dict{String, Any}) = args[1] || args[2]
@builtin or_float_float(args::AbstractArray, env::Dict{String, Any}) = args[1] || args[2]


@builtin parse_int(args::AbstractArray, env::Dict{String,Any}) = Base.parse(Int, args[1])
@builtin parse_float(args::AbstractArray, env::Dict{String,Any}) = Base.parse(Float64, args[1])

@builtin print(args::AbstractArray, env::Dict{String,Any}) = Base.println(args...)
@builtin readline(args::AbstractArray, env::Dict{String,Any}) = Base.readline()




end # module MuBuiltins