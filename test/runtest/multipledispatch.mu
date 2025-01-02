function f(x::Int, y::Int){
    print("Int, Int")
    return 0
}

function f(x::Number, y::Int){
    print("Number, Int")
    return 0
}

function f(x::Int, y::Number){
    print("Int, Number")
    return 0
}

function f(x::Number, y::Number){
    print("Number, Number")
    return 0
}

function f(c::Number, v::Array{Int, 1}){
    print("Number, Array{Int, 1}")
    n = length(v)
    i = 1
    while (i <= n){
        set(v, i, c * get(v, i))
        i = i + 1
    }

    return v
}

function main(){
    f(1, 1)

    f(1, 1.0)

    f(1.0, 1)

    f(1.0, 1.0)

    f(1.0, [1, 2, 3])

    return 0

}