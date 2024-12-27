function main() {
    n = 100
    i = 1
    
    while (i < n) {
        if (i % 15 == 0){
            print("FizzBuzz")
        } else {
            if (i % 3 == 0){
                print("Fizz")
            } else {
                if (i % 5 == 0){
                    print("Buzz")
                } else {
                    print(i)
                }
            }
        }

        i = i + 1
    }
}