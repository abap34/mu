# Arithmetic operations
set_constant!("add_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Int)
set_constant!("add_int_float", [MuTypes.Int, MuTypes.Float], MuTypes.Float)
set_constant!("add_float_int", [MuTypes.Float, MuTypes.Int], MuTypes.Float)
set_constant!("add_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Float)
set_constant!("sub_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Int)
set_constant!("sub_int_float", [MuTypes.Int, MuTypes.Float], MuTypes.Float)
set_constant!("sub_float_int", [MuTypes.Float, MuTypes.Int], MuTypes.Float)
set_constant!("sub_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Float)
set_constant!("mul_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Int)
set_constant!("mul_int_float", [MuTypes.Int, MuTypes.Float], MuTypes.Float)
set_constant!("mul_float_int", [MuTypes.Float, MuTypes.Int], MuTypes.Float)
set_constant!("mul_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Float)
set_constant!("div_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Float)
set_constant!("div_int_float", [MuTypes.Int, MuTypes.Float], MuTypes.Float)
set_constant!("div_float_int", [MuTypes.Float, MuTypes.Int], MuTypes.Float)
set_constant!("div_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Float)
set_constant!("pow_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Int)
set_constant!("pow_int_float", [MuTypes.Int, MuTypes.Float], MuTypes.Float)
set_constant!("pow_float_int", [MuTypes.Float, MuTypes.Int], MuTypes.Float)
set_constant!("pow_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Float)
set_constant!("mod_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Int)
set_constant!("eq_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Bool)
set_constant!("eq_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Bool)
set_constant!("neq_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Bool)
set_constant!("neq_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Bool)
set_constant!("lt_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Bool)
set_constant!("lt_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Bool)
set_constant!("gt_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Bool)
set_constant!("gt_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Bool)
set_constant!("le_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Bool)
set_constant!("le_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Bool)
set_constant!("ge_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Bool)
set_constant!("ge_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Bool)
set_constant!("and_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Bool)
set_constant!("and_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Bool)
set_constant!("or_int_int", [MuTypes.Int, MuTypes.Int], MuTypes.Bool)
set_constant!("or_float_float", [MuTypes.Float, MuTypes.Float], MuTypes.Bool)
set_constant!("neg_int", [MuTypes.Int], MuTypes.Int)
set_constant!("neg_float", [MuTypes.Float], MuTypes.Float)
set_constant!("floor_float", [MuTypes.Float], MuTypes.Int)

# I/O operations
set_constant!("print", [MuTypes.String], MuTypes.Int)
set_constant!("println", [MuTypes.String], MuTypes.Int)
set_constant!("readline", [], MuTypes.String)

# Type conversion
set_constant!("parse_int", [MuTypes.String], MuTypes.Int)
set_constant!("parse_float", [MuTypes.String], MuTypes.Float)

# String operations
set_constant!("length_str", [MuTypes.String], MuTypes.Int)
set_constant!("get_str", [MuTypes.String, MuTypes.Int], MuTypes.String)
set_constant!("mul_str_str", [MuTypes.String, MuTypes.Int], MuTypes.String)

# Tuple operations
function get_tuple_tfunc(argtypes::AbstractArray)
    if argtypes[2] != MuTypes.Int
        @warn "Second argument of get_tuple should be Int. Got $(argtypes[2])"
        return MuTypes.Bottom
    end

    if argtypes[1] == MuTypes.AbstractTuple
        return MuTypes.AbstractTuple
    end

    return MuTypes.uniontype(MuTypes.component_types(argtypes[1]))
end

TFUNCS["get_tuple"] = get_tuple_tfunc

set_constant!("eachindex_tuple", [MuTypes.AbstractTuple], MuTypes.Array{MuTypes.Int, 1})

function pop_tuple_tfunc(argtypes::AbstractArray)
    return MuTypes.tupletype(MuTypes.component_types(argtypes[1])[1:end-1])
end

TFUNCS["pop_tuple"] = pop_tuple_tfunc

function append_tuple(argtypes::AbstractArray)
    tp = MuTypes.component_types(argtypes[1])
    return MuTypes.tupletype(append!(tp, [argtypes[2]]))
end

TFUNCS["append_tuple"] = append_tuple

# Array Operations

function _get_array_eltype(t::DataType)
    @assert MuTypes.issubtype(t, MuTypes.AbstractArray)

    return t.parameters[1]
end

function _get_array_dim(t::DataType)
    @assert MuTypes.issubtype(t, MuTypes.AbstractArray)

    return t.parameters[2]
end

function _expand_union(argtypes::AbstractArray)    
    expanded = map(MuTypes.expand_types, argtypes)
    candidates = [collect(t) for t in Iterators.product(expanded...)]
    return candidates
end

function arr_union_unwrap(tfunc::Function)::Function
    function (argtypes::AbstractArray)
        cands = _expand_union(argtypes)
        (length(cands) == 1) && (return tfunc(cands[1]))

        return MuTypes.uniontype([tfunc(cand) for cand in cands])
    end
end


function get_arr_tfunc(argtypes::AbstractArray)
    arr_type, idx_type = argtypes
    (arr_type == MuTypes.AbstractArray) && (return MuTypes.AbstractArray)
    return _get_array_eltype(arr_type)
end

TFUNCS["get_arr"] = arr_union_unwrap(get_arr_tfunc)

set_constant!("set_arr", [MuTypes.AbstractArray, MuTypes.Int, MuTypes.Any], MuTypes.Int)

set_constant!("eachindex_arr", [MuTypes.AbstractArray], MuTypes.Array{MuTypes.Int, 1})

function size_arr_tfunc(argtypes::AbstractArray)
    (argtypes[1] == MuTypes.AbstractArray) && (return MuTypes.Any)

    dim = _get_array_dim(argtypes[1])
    
    component = fill(MuTypes.Int, dim)

    return MuTypes.tupletype(component)
end

TFUNCS["size_arr"] = arr_union_unwrap(size_arr_tfunc)

function reshape_arr_tfunc(argtypes::AbstractArray)
    arr_type, size_type = argtypes

    (arr_type == MuTypes.AbstractArray) && (return MuTypes.AbstractArray)
    (size_type == MuTypes.AbstractTuple) && (return MuTypes.AbstractArray)

    elem = _get_array_eltype(arr_type)
    dim = length(MuTypes.component_types(size_type))

    return MuTypes.Array{elem, dim}
end

TFUNCS["reshape_arr"] = arr_union_unwrap(reshape_arr_tfunc)

function transpose_arr_tfunc(argtypes::AbstractArray)
    arr_type = argtypes[1]

    (arr_type == MuTypes.AbstractArray) && (return MuTypes.AbstractArray)

    elem = _get_array_eltype(arr_type)
    dim = _get_array_dim(arr_type)

    # Vector becomes a row matrix
    if dim == 1
        return MuTypes.Array{elem, 2}
    else
        return MuTypes.Array{elem, dim}
    end
end

TFUNCS["transpose_arr"] = arr_union_unwrap(transpose_arr_tfunc)

function linspace_arr_tfunc(argtypes::AbstractArray)
    return MuTypes.Array{MuTypes.Float, 1}
end

TFUNCS["linspace_arr"] = linspace_arr_tfunc
