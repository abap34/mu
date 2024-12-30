function double(x::Number){
    return 2 * x
}

function double(x::Vector{Int, 1}){
    n = length(x)
    i = 1
    while (i <= n){
        set(x, i, 2 * get(x, i))
        i = i + 1
    }

    return x
}

function main(){
    a = 5
    b = [1, 2, 3, 4, 5]

    c = double(a)
    d = double(b)

    print("c:", c)
    print("d:", d)
}