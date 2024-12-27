function is_odd(x::Int){
    if (x % 2 == 0){
        return false
    } else {
        return true
    }
}

function main(){
    x = 5
    if (is_odd(x)){
        print("x is odd")
    } else {
        print("x is even")
    }
}