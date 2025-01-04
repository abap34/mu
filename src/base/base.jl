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

function eq(a::Int, b::Float){
    return @eq_int_float(a, b)
}

function eq(a::Float, b::Int){
    return @eq_float_int(a, b)
}

function eq(a::Float, b::Float){
    return @eq_float_float(a, b)
}



function gt(a::Int, b::Int){
    return @gt_int_int(a, b)
}

function gt(a::Int, b::Float){
    return @gt_int_float(a, b)
}

function gt(a::Float, b::Int){
    return @gt_float_int(a, b)
}

function gt(a::Float, b::Float){
    return @gt_float_float(a, b)
}

function le(a::Int, b::Int){
    return @le_int_int(a, b)
}

function le(a::Int, b::Float){
    return @le_int_float(a, b)
}

function le(a::Float, b::Int){
    return @le_float_int(a, b)
}

function le(a::Float, b::Float){
    return @le_float_float(a, b)
}

function lt(a::Int, b::Int){
    return @lt_int_int(a, b)
}

function lt(a::Int, b::Float){
    return @lt_int_float(a, b)
}

function lt(a::Float, b::Int){
    return @lt_float_int(a, b)
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
function print(s::Any){
    return @print(s)
}

function length(arr::AbstractArray){
    return @length(arr)    
}

function get(arr::AbstractArray, idx::Int){
    return @get(arr, idx)    
}

function set(arr::AbstractArray, idx::Int, value::Any){
    return @set(arr, idx, value)
}
"""


function load_base()::MuCore.MuIR.ProgramIR
    ast = MuCore.parse(BASE)
    ir = MuCore.lowering(ast)
    return ir
end


function injection_base!(interp)
    for f in load_base()
        MuCore.MuInterpreter.injection!(interp, f)
    end
end

