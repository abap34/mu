# Implementation of built-in functions
# Arithmetic operations
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
@builtin neg_int(args::AbstractArray, env::Dict{String,Any}) = -args[1]
@builtin neg_float(args::AbstractArray, env::Dict{String,Any}) = -args[1]

@builtin floor_float(args::AbstractArray, env::Dict{String,Any}) = Base.floor(Int, args[1])

# I/O operations
@builtin print(args::AbstractArray, env::Dict{String,Any}) = (Base.println(args...); return 0)
@builtin readline(args::AbstractArray, env::Dict{String,Any}) = Base.readline()

# Type conversion
@builtin parse_int(args::AbstractArray, env::Dict{String,Any}) = Base.parse(Int, args[1])
@builtin parse_float(args::AbstractArray, env::Dict{String,Any}) = Base.parse(Float64, args[1])

# String operations
@builtin length_str(args::AbstractArray, env::Dict{String,Any}) = Base.length(args[1])
@builtin get_str(args::AbstractArray, env::Dict{String,Any}) = args[1][args[2]]
@builtin mul_str_str(args::AbstractArray, env::Dict{String,Any}) = args[1] * args[2]

# Array operations
# Attention: 
#  [1] Tuple doesn't exist in Mu, so we use Array instead in some cases. (Any other AbstractArray are not supported yet. So use `Base.Array`
#  [2] Some operations are different from Julia's Base functions. (e.g. `sum` function) 

function mu_sum(arr::AbstractArray, dims::Int)
    s = Base.dropdims(Base.sum(arr, dims=dims), dims=dims)
    if ndims(s) == 0
        return s[1]
    else
        return s
    end
end

@builtin size_arr(args::AbstractArray, env::Dict{String,Any}) = Base.size(args[1]) |> Base.collect |> Base.Array
@builtin length_arr(args::AbstractArray, env::Dict{String,Any}) = Base.length(args[1])
@builtin get_arr(args::AbstractArray, env::Dict{String,Any}) = args[1][args[2]]
@builtin set_arr(args::AbstractArray, env::Dict{String,Any}) = (args[1][args[2]] = args[3]; return 0)
@builtin similar_arr(args::AbstractArray, env::Dict{String,Any}) = Base.similar(args[1])
@builtin expanddims_arr(args::AbstractArray, env::Dict{String,Any}) = Base.reshape(args[1], Base.size(args[1])..., 1)
@builtin sum_arr(args::AbstractArray, env::Dict{String,Any}) = mu_sum(args[1], args[2])
@builtin eachindex_arr(args::AbstractArray, env::Dict{String,Any}) = Base.eachindex(args[1]) |> Base.collect |> Base.Array
