set_constant!("throw",          MuTypes.Bottom)

set_constant!("add_int_int",    MuTypes.Int)

set_constant!("add_int_float",  MuTypes.Float)
set_constant!("add_float_int",  MuTypes.Float)
set_constant!("add_float_float",MuTypes.Float)
set_constant!("sub_int_int",    MuTypes.Int)
set_constant!("sub_int_float",  MuTypes.Float)
set_constant!("sub_float_int",  MuTypes.Float)
set_constant!("sub_float_float",MuTypes.Float)
set_constant!("mul_int_int",    MuTypes.Int)
set_constant!("mul_int_float",  MuTypes.Float)
set_constant!("mul_float_int",  MuTypes.Float)
set_constant!("mul_float_float",MuTypes.Float)
set_constant!("div_int_int",    MuTypes.Float)
set_constant!("div_int_float",  MuTypes.Float)
set_constant!("div_float_int",  MuTypes.Float)
set_constant!("div_float_float",MuTypes.Float)
set_constant!("mod_int_int",    MuTypes.Int)
set_constant!("eq_int_int",     MuTypes.Bool)
set_constant!("eq_int_float",   MuTypes.Bool)
set_constant!("eq_float_int",   MuTypes.Bool)
set_constant!("eq_float_float", MuTypes.Bool)
set_constant!("neq_int_int",    MuTypes.Bool)
set_constant!("neq_int_float",  MuTypes.Bool)
set_constant!("neq_float_int",  MuTypes.Bool)
set_constant!("neq_float_float",MuTypes.Bool)
set_constant!("lt_int_int",     MuTypes.Bool)
set_constant!("lt_int_float",   MuTypes.Bool)
set_constant!("lt_float_int",   MuTypes.Bool)
set_constant!("lt_float_float", MuTypes.Bool)
set_constant!("gt_int_int",     MuTypes.Bool)
set_constant!("gt_int_float",   MuTypes.Bool)
set_constant!("gt_float_int",   MuTypes.Bool)
set_constant!("gt_float_float", MuTypes.Bool)
set_constant!("le_int_int",     MuTypes.Bool)
set_constant!("le_int_float",   MuTypes.Bool)
set_constant!("le_float_int",   MuTypes.Bool)
set_constant!("le_float_float", MuTypes.Bool)
set_constant!("ge_int_int",     MuTypes.Bool)
set_constant!("ge_int_float",   MuTypes.Bool)
set_constant!("ge_float_int",   MuTypes.Bool)
set_constant!("ge_float_float", MuTypes.Bool)
set_constant!("and_int_int",    MuTypes.Bool)
set_constant!("and_int_float",  MuTypes.Bool)
set_constant!("and_float_int",  MuTypes.Bool)
set_constant!("and_float_float",MuTypes.Bool)
set_constant!("or_int_int",     MuTypes.Bool)
set_constant!("or_int_float",   MuTypes.Bool)
set_constant!("or_float_int",   MuTypes.Bool)
set_constant!("or_float_float", MuTypes.Bool)
set_constant!("neg_int",        MuTypes.Int)
set_constant!("neg_float",      MuTypes.Float)
set_constant!("floor",          MuTypes.Int)
set_constant!("parse_int",      MuTypes.Int)
set_constant!("parse_float",    MuTypes.Float)

# `print` always return 0.
set_constant!("print",          MuTypes.Int)
set_constant!("readline",       MuTypes.String)
set_constant!("length",         MuTypes.Int)
# `set` always return 0.
set_constant!("set",            MuTypes.Int)

function arrget_tfunc(argtypes::Vector{MuTypes.MuType})::MuTypes.MuType
    return argtypes[1].parameters[1]
end

TFUNCS["get"] = arrget_tfunc

function get_tfuncs(name::String)::Function
    if haskey(TFUNCS, name)
        return TFUNCS[name]
    else
        throw(ArgumentError("tfunc of $name is not defined. Available tfuncs are $(keys(TFUNCS))"))
    end
end



