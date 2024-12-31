function f(x::Int, y::Int){
    print("-> f(x::Int, y::Int) called")
    return 0
}

function f(x::Number, y::Int){
    print("-> f(x::Number, y::Int) called")
    return 0
}

function f(x::Int, y::Number){
    print("-> f(x::Int, y::Number) called")
    return 0
}

function f(x::Number, y::Number){
    print("-> f(x::Number, y::Number) called")
    return 0
}

function f(c::Number, v::Array{Int, 1}){
    print("-> f(c::Number, v::Array{Int, 1})")
    n = length(v)
    i = 1
    while (i <= n){
        set(v, i, c * get(v, i))
        i = i + 1
    }

    return v
}

function line(){
    print("------------------------------------------------")
    return 0
}

function main(){
    line()
    print("1, 1")
    f(1, 1)
    line()

    print("1, 1.0")
    f(1, 1.0)
    line()

    print("1.0, 1")
    f(1.0, 1)
    line()

    print("1.0, 1.0")
    f(1.0, 1.0)
    line()

    print("1.0, [1, 2, 3]")
    f(1.0, [1, 2, 3])
    line()

    return 0

}