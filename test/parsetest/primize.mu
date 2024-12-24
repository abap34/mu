function is_prime(x::Int){
    if (x <= 1){
        return false
    }
    i = 2
    while (i < x){
        if (x % i == 0){
            return false
        }
        i = i + 1
    }
    return true
}

n = 100

i = 1

while (i < n) {
    if (is_prime(i)){
        print(i, " is prime")
    } else {
        print(i, " is not prime")
    }
    i = i + 1
}