function prod(a::Int, B::Matrix{Int, 2}) {
    n = size(B, 1)
    m = size(B, 2)
    C = zeros(Int, n, m)

    i = 1
    while (i <= n) {
        j = 1
        while (j <= m) {
            v = a * get(B, i, j)
            set(C, i, j, v)
            j = j + 1
        }
        i = i + 1
    }

    return C
}

function prod(a::Vector{Int, 1}, b::Vector{Int, 1}){
    sum = 0
    n = length(a)
    i = 1
    while (i <= n){
        sum = sum + get(a, i) * get(b, i)
        i = i + 1
    }

    return sum
}

function exit_success(){
    exit(0)
}

function main(){
    coef = 5

    A = [1, 2, 3;
        4, 5, 6;
        7, 8, 9]


    B = prod(coef, A)

    sum_row = sum_dim1(A)
    sum_col = sum_dim2(A)

    print("sum_row:", sum_row)
    print("sum_col:", sum_col)

    s = prod(sum_row, sum_col)

    if (s >= 100){
        print("s is greater than 100!")
        if (s >= 200){
            print("s is also greater than 200!")
        }
    } else {
        print("s is less than 100")
    }


    print("done.")

    exit_success()
}