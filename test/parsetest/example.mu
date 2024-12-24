function scalar_Matrix_mul(coef::Number, A::Matrix{Int, 2}){
    B = coef * A
    print("result:", B)
    return B
}

function prod(a::Vector{Int}, b::Vector{Int}){
    sum = 0
    n = length(a)
    i = 1
    while (i <= n){
        sum = sum + a[i] * b[i]
        i = i + 1
    }

    return sum
}


coef = 1.0

A = [1, 2, 3;
     4, 5, 6;
     7, 8, 9]


B = scalar_Matrix_mul(coef, A)

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