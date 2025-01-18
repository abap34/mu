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
    return MuTypes.component_types(argtypes[1])[argtypes[2]]
end

TFUNCS["get_tuple"] = get_tuple_tfunc

set_constant!("eachindex_tuple", [MuTypes.Tuple], MuTypes.Array{MuTypes.Int, 1})

function pop_tuple_tfunc(argtypes::AbstractArray)
    return MuTypes.tupletype(MuTypes.component_types(argtypes[1])[1:end-1])
end

TFUNCS["pop_tuple"] = pop_tuple_tfunc

function append_tuple(argtypes::AbstractArray)
    tp = MuTypes.component_types(argtypes[1])
    return MuTypes.tupletype(append!(tp, [argtypes[2]]))
end

# Array Operations

function _get_array_eltype(t::DataType)
    @assert MuTypes.issubtype(t, MuTypes.AbstractArray)

    return t.parameters[1]
end

function _get_array_dim(t::DataType)
    @assert MuTypes.issubtype(t, MuTypes.AbstractArray)

    return t.parameters[2]
end

function arr_union_unwrap(tfunc::Function)::Function
    function (argtypes::AbstractArray)
        if MuTypes.isunion(argtypes)
            result = Any[]
            for t in MuTypes.expand_types(argtypes)
                push!(result, tfunc(t))
            end

            return MuTypes.uniontypes(result)
        else
            tfunc(argtypes)
        end
    end
end



function reshape_arr_tfunc(argtypes::AbstractArray)
    arr, reshaped_size = argtypes

    (arr == MuTypes.AbstractArray) && (return MuTypes.AbstractArray)

    elem = _get_array_eltype(arr)
    dim = length(MuTypes.component_types(reshaped_size))

    return Array{elem, dim}
end    

TFUNCS["reshape_arr"] = arr_union_unwrap(reshape_arr_tfunc)

function get_arr_tfunc(argtypes::AbstractArray)
    (arr == MuTypes.AbstractArray) && (return MuTypes.AbstractArray)
    return _get_array_eltype(arr)
end

set_constant!("set_arr", [MuTypes.AbstractArray, MuTypes.Int, MuTypes.Any], MuTypes.Int)

set_constant!("eachindex_arr", [MuTypes.AbstractArray], MuTypes.Int)

function size_arr_tfunc(argtypes::AbstractArray)
    (argtypes[1] == MuTypes.AbstractArray) && (return MuTypes.Any)
    
    component = [MuTypes.Int for _ in 1:_get_array_dim(argtypes[1])]
     
    return MuTypes.uniontype(component)
end

TFUNCS["size_arr"] = size_arr_tfunc


function similar_arr_tfunc(argtypes::AbstractArray)
    arr_type = first(argtypes)
    (arr_type == MuTypes.AbstractArray) && (return MuTypes.AbstractArray)

    return Array{_get_array_eltype(arr_type), _get_array_dim(arr_type)}
end
