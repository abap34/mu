# preload functions for type inference tests

# String -> String
function repeat(s::String, n::Int){
    while (n > 0){
        s = s * s
        n = n - 1
    }
    return s
}

# T <: Real -> T
function double(x::Real){
    return 2 * x           
}

# T <: AbstractArray -> T
function double(x::AbstractArray) {
    result = similar(x)
    I = eachindex(x)
    i = 1
    while (i <= length(I)){
        idx = get(I, i)
        set(result, idx, 2 * get(x, idx))
        i = i + 1
    }
    return result
}


# String -> String
function double(x::String){
    return repeat(x, 2)
}








