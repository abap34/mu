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

@builtin floor(args::AbstractArray, env::Dict{String,Any}) = Base.floor(Int, args[1])

@builtin parse_int(args::AbstractArray, env::Dict{String,Any}) = Base.parse(Int, args[1])
@builtin parse_float(args::AbstractArray, env::Dict{String,Any}) = Base.parse(Float64, args[1])

@builtin print(args::AbstractArray, env::Dict{String,Any}) = (Base.println(args...); return 0)
@builtin readline(args::AbstractArray, env::Dict{String,Any}) = Base.readline()

@builtin length(args::AbstractArray, env::Dict{String,Any}) = Base.length(args[1])
@builtin get(args::AbstractArray, env::Dict{String,Any}) = args[1][args[2]]
@builtin set(args::AbstractArray, env::Dict{String,Any}) = (args[1][args[2]] = args[3]; return args[0])