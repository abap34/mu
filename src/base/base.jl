using ..MuCore

BASE = """
function add(a::Int, b::Int){
    return @add_int_int(a, b)
}

function add(a::Int, b::Float){
    return @add_int_float(a, b)
}

function add(a::Float, b::Int){
    return @add_float_int(a, b)
}

function add(a::Float, b::Float){
    return @add_float_float(a, b)
}

function div(a::Int, b::Int){
    return @div_int_int(a, b)
}

function div(a::Int, b::Float){
    return @div_int_float(a, b)
}

function div(a::Float, b::Int){
    return @div_float_int(a, b)
}

function div(a::Float, b::Float){
    return @div_float_float(a, b)
}

function eq(a::Int, b::Int){
    return @eq_int_int(a, b)
}


function eq(a::Float, b::Float){
    return @eq_float_float(a, b)
}

function gt(a::Int, b::Int){
    return @gt_int_int(a, b)
}


function gt(a::Float, b::Float){
    return @gt_float_float(a, b)
}

function le(a::Int, b::Int){
    return @le_int_int(a, b)
}


function le(a::Float, b::Float){
    return @le_float_float(a, b)
}

function lt(a::Int, b::Int){
    return @lt_int_int(a, b)
}


function lt(a::Float, b::Float){
    return @lt_float_float(a, b)
}

function mod(a::Int, b::Int){
    return @mod_int_int(a, b)
}

function mod(a::Int, b::Float){
    return @mod_int_float(a, b)
}

function mod(a::Float, b::Int){
    return @mod_float_int(a, b)
}

function mod(a::Float, b::Float){
    return @mod_float_float(a, b)
}

function mul(a::Int, b::Int){
    return @mul_int_int(a, b)
}

function mul(a::Int, b::Float){
    return @mul_int_float(a, b)
}

function mul(a::Float, b::Int){
    return @mul_float_int(a, b)
}

function mul(a::Float, b::Float){
    return @mul_float_float(a, b)
}

function pow(a::Int, b::Int){
    return @pow_int_int(a, b)
}

function pow(a::Int, b::Float){
    return @pow_int_float(a, b)
}

function pow(a::Float, b::Int){
    return @pow_float_int(a, b)
}

function pow(a::Float, b::Float){
    return @pow_float_float(a, b)
}

function sub(a::Int, b::Int){
    return @sub_int_int(a, b)
}

function sub(a::Int, b::Float){
    return @sub_int_float(a, b)
}

function sub(a::Float, b::Int){
    return @sub_float_int(a, b)
}

function sub(a::Float, b::Float){
    return @sub_float_float(a, b)
}

function sub(x::Int){
    return @neg_int(x)
}

function sub(x::Float){
    return @neg_float(x)
}

function floor(x::Float){
    return @floor_float(x)    
}

function print(s::Any){
    return @print(s)
}

function length(arr::AbstractArray){
    return @length_arr(arr)
}

function length(S::String){
    return @length_str(S)
}

function get(arr::AbstractArray, idx::Int){
    return @get_arr(arr, idx)    
}

function get(S::String, idx::Int){
    return @get_str(arr, idx)    
}

function set(arr::AbstractArray, idx::Int, value::Any){
    return @set_arr(arr, idx, value)
}

function mul(s1::String, s2::String){
    return @mul_str_str(s1, s2)    
}


"""

const _BASE_AST = MuCore.parse(BASE)

const _BASE_LOADED_MT = MuCore.MuInterpreter.MethodTable()

for mi in MuCore.lowering(_BASE_AST)
    MuCore.MuInterpreter.add_method!(_BASE_LOADED_MT, mi)
end

function load_base()::MuCore.MuInterpreter.MethodTable
    return copy(_BASE_LOADED_MT)
end




