# Arithmetic operations
set_constant!("add_int_int",    [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Int  )
set_constant!("add_int_float",  [MuTypes.Int,   MuTypes.Float],   MuTypes.Float)
set_constant!("add_float_int",  [MuTypes.Float, MuTypes.Int  ],   MuTypes.Float)
set_constant!("add_float_float",[MuTypes.Float, MuTypes.Float],   MuTypes.Float)
set_constant!("sub_int_int",    [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Int  )
set_constant!("sub_int_float",  [MuTypes.Int,   MuTypes.Float],   MuTypes.Float)
set_constant!("sub_float_int",  [MuTypes.Float, MuTypes.Int  ],   MuTypes.Float)
set_constant!("sub_float_float",[MuTypes.Float, MuTypes.Float],   MuTypes.Float)
set_constant!("mul_int_int",    [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Int  )
set_constant!("mul_int_float",  [MuTypes.Int,   MuTypes.Float],   MuTypes.Float)
set_constant!("mul_float_int",  [MuTypes.Float, MuTypes.Int  ],   MuTypes.Float)
set_constant!("mul_float_float",[MuTypes.Float, MuTypes.Float],   MuTypes.Float)
set_constant!("div_int_int",    [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Float)
set_constant!("div_int_float",  [MuTypes.Int,   MuTypes.Float],   MuTypes.Float)
set_constant!("div_float_int",  [MuTypes.Float, MuTypes.Int  ],   MuTypes.Float)
set_constant!("div_float_float",[MuTypes.Float, MuTypes.Float],   MuTypes.Float)
set_constant!("mod_int_int",    [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Int  )
set_constant!("eq_int_int",     [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Bool )
set_constant!("eq_float_float", [MuTypes.Float, MuTypes.Float],   MuTypes.Bool )
set_constant!("neq_int_int",    [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Bool )
set_constant!("neq_float_float",[MuTypes.Float, MuTypes.Float],   MuTypes.Bool )
set_constant!("lt_int_int",     [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Bool )
set_constant!("lt_float_float", [MuTypes.Float, MuTypes.Float],   MuTypes.Bool )
set_constant!("gt_int_int",     [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Bool )
set_constant!("gt_float_float", [MuTypes.Float, MuTypes.Float],   MuTypes.Bool )
set_constant!("le_int_int",     [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Bool )
set_constant!("le_float_float", [MuTypes.Float, MuTypes.Float],   MuTypes.Bool )
set_constant!("ge_int_int",     [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Bool )
set_constant!("ge_float_float", [MuTypes.Float, MuTypes.Float],   MuTypes.Bool )
set_constant!("and_int_int",    [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Bool )
set_constant!("and_float_float",[MuTypes.Float, MuTypes.Float],   MuTypes.Bool )
set_constant!("or_int_int",     [MuTypes.Int,   MuTypes.Int  ],   MuTypes.Bool )
set_constant!("or_float_float", [MuTypes.Float, MuTypes.Float],   MuTypes.Bool )
set_constant!("neg_int",        [MuTypes.Int  ],                  MuTypes.Int  )
set_constant!("neg_float",      [MuTypes.Float],                  MuTypes.Float)
set_constant!("floor_float",          [MuTypes.Float],                  MuTypes.Int  )

# I/O operations
set_constant!("print",          [MuTypes.String],                 MuTypes.Int)
set_constant!("readline",       [],                               MuTypes.String)

# Type conversion
set_constant!("parse_int",      [MuTypes.String],                 MuTypes.Int)
set_constant!("parse_float",    [MuTypes.String],                 MuTypes.Float)

# String operations
set_constant!("length_str",     [MuTypes.String],                 MuTypes.Int)
set_constant!("get_str",        [MuTypes.String, MuTypes.Int],    MuTypes.String)
set_constant!("mul_str_str",    [MuTypes.String, MuTypes.Int],    MuTypes.String)


# Array operations
set_constant!("size_arr",       [MuTypes.AbstractArray],          MuTypes.Array{MuTypes.Int, 1})
set_constant!("length_arr",     [MuTypes.AbstractArray],          MuTypes.Int)
set_constant!("eachindex_arr",  [MuTypes.AbstractArray],          MuTypes.AbstractArray)

TFUNCS["get_arr"] = function (argtypes::Vector{DataType})
    if !(MuTypes.issubtype(argtypes[1], MuTypes.AbstractArray))
        @warn "Try to get from $(argtypes[1])"
        return MuTypes.Bottom
    end
    return argtypes[1].parameters[1]
end

# Set always return 0 in Mu.
TFUNCS["set_arr"] = function (argtypes::AbstractArray)
    arrtype = argtypes[1]
    idxtype = argtypes[2]       

    if !(MuTypes.issubtype(arrtype, MuTypes.AbstractArray))
        @warn "Try to set value to $(arrtype). Expecting an array type."
        return MuTypes.Bottom
    end

    if !(idxtype <: MuTypes.Int)
        @warn "Try to set value to $(arrtype) with index $(idxtype). Expecting an integer index."
        return MuTypes.Bottom
    end

    return MuTypes.Int
end

TFUNCS["similar_arr"] = function (argtypes::AbstractArray)
    if !(MuTypes.issubtype(argtypes[1], MuTypes.AbstractArray))
        @warn "Try to get similar array of $(argtypes[1]). Expecting an array type."
        return MuTypes.Bottom
    end

    return argtypes[1]
end

TFUNCS["expanddims_arr"] = function (argtypes::AbstractArray)
    if !(MuTypes.issubtype(argtypes[1], MuTypes.AbstractArray))
        @warn "Try to expanddims on $(argtypes[1]). Expecting an array type."
        return MuTypes.Bottom
    end

    eltype = argtypes[1].parameters[1]
    dim = argtypes[1].parameters[2] 

    return MuTypes.Array{eltype, dim + 1}
end

TFUNCS["sum_arr"] = function (argtypes::AbstractArray)
    if !(MuTypes.issubtype(argtypes[1], MuTypes.AbstractArray))
        @warn "Try to sum on $(argtypes[1]). Expecting an array type."
        return MuTypes.Bottom
    end

    eltype = argtypes[1].parameters[1]
    dim = argtypes[1].parameters[2]

    (dim == 1) && return eltype

    return MuTypes.Array{eltype, dim - 1}
    
end


function get_tfuncs(name::String)::Function
    if haskey(TFUNCS, name)
        return TFUNCS[name]
    else
        Base.throw(ArgumentError("tfunc of $name is not defined. Available tfuncs are $(keys(TFUNCS))"))
    end
end




