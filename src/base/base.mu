function add(a::Int, b::Int){
    @add_int_int(a, b)
}

function add(a::Int, b::Float){
    @add_int_float(a, b)
}

function add(a::Float, b::Int){
    @add_float_int(a, b)
}

function add(a::Float, b::Float){
    @add_float_float(a, b)
}

function div(a::Int, b::Int){
    @div_int_int(a, b)
}

function div(a::Int, b::Float){
    @div_int_float(a, b)
}

function div(a::Float, b::Int){
    @div_float_int(a, b)
}

function div(a::Float, b::Float){
    @div_float_float(a, b)
}

function gt(a::Int, b::Int){
    @gt_int_int(a, b)
}

function gt(a::Int, b::Float){
    @gt_int_float(a, b)
}

function gt(a::Float, b::Int){
    @gt_float_int(a, b)
}

function gt(a::Float, b::Float){
    @gt_float_float(a, b)
}

function le(a::Int, b::Int){
    @le_int_int(a, b)
}

function le(a::Int, b::Float){
    @le_int_float(a, b)
}

function le(a::Float, b::Int){
    @le_float_int(a, b)
}

function le(a::Float, b::Float){
    @le_float_float(a, b)
}

function lt(a::Int, b::Int){
    @lt_int_int(a, b)
}

function lt(a::Int, b::Float){
    @lt_int_float(a, b)
}

function lt(a::Float, b::Int){
    @lt_float_int(a, b)
}

function lt(a::Float, b::Float){
    @lt_float_float(a, b)
}

function mod(a::Int, b::Int){
    @mod_int_int(a, b)
}

function mod(a::Int, b::Float){
    @mod_int_float(a, b)
}

function mod(a::Float, b::Int){
    @mod_float_int(a, b)
}

function mod(a::Float, b::Float){
    @mod_float_float(a, b)
}

function mul(a::Int, b::Int){
    @mul_int_int(a, b)
}

function mul(a::Int, b::Float){
    @mul_int_float(a, b)
}

function mul(a::Float, b::Int){
    @mul_float_int(a, b)
}

function mul(a::Float, b::Float){
    @mul_float_float(a, b)
}

function pow(a::Int, b::Int){
    @pow_int_int(a, b)
}

function pow(a::Int, b::Float){
    @pow_int_float(a, b)
}

function pow(a::Float, b::Int){
    @pow_float_int(a, b)
}

function pow(a::Float, b::Float){
    @pow_float_float(a, b)
}

function sub(a::Int, b::Int){
    @sub_int_int(a, b)
}

function sub(a::Int, b::Float){
    @sub_int_float(a, b)
}

function sub(a::Float, b::Int){
    @sub_float_int(a, b)
}

function sub(a::Float, b::Float){
    @sub_float_float(a, b)
}

