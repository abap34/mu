function get(w::AbstractArray, i::Int, j::Int) {
    m = get(size(w), 2)
    return get(w, (i - 1) * m + j)
}

function set(w::AbstractArray, i::Int, j::Int, value::Float) {
    m = get(size(w), 2)
    return set(w, (i - 1) * m + j, value)
}

function pi() {
    return 3.14159265358979323846
}

function similar(arr::AbstractArray) {
    return reshape(arr, size(arr))
}

function exp(x::Real) {
    return (2.71828182845904523536)^x
}

function sigmoid(x::Real) {
    return 1 / (1 + exp(-x))
}

function sigmoid(x::Array{Float, 1}) {
    result = similar(x)
    i = 1
    while (i <= length(x)) {
        set(result, i, sigmoid(get(x, i)))
        i = i + 1
    }
    return result
}

function sigmoid_derivative(x::Float) {
    return x * (1 - x)
}

function sigmoid_derivative(x::Array{Float, 1}) {
    result = similar(x)
    i = 1
    while (i <= length(x)) {
        set(result, i, sigmoid_derivative(get(x, i)))
        i = i + 1
    }
    return result
}

function sin(x::Float) {
    return x - (x^3) / 6 + (x^5) / 120 - (x^7) / 5040 + (x^9) / 362880 - 
           (x^11) / 39916800 + (x^13) / 6227020800 - (x^15) / 1307674368000 + 
           (x^17) / 355687428096000 - (x^19) / 121645100408832000
}

function get_x() {
    return linspace(0.0, pi(), 10)
}

function get_y(x::Array{Float, 1}) {
    result = similar(x)
    i = 1
    while (i <= length(x)) {
        set(result, i, sin(get(x, i)))
        i = i + 1
    }
    return result
}

function sub(a::Array{Float, 1}, b::Array{Float, 1}) {
    result = similar(a)
    i = 1
    while (i <= length(a)) {
        set(result, i, get(a, i) - get(b, i))
        i = i + 1
    }
    return result
}

function sub(a::AbstractArray, b::Float) {
    result = similar(a)
    i = 1
    while (i <= length(a)) {
        set(result, i, get(a, i) - b)
        i = i + 1
    }
    return result
}

function mul(a::Array{Float, 1}, b::Float) {
    result = similar(a)
    i = 1
    while (i <= length(a)) {
        set(result, i, get(a, i) * b)
        i = i + 1
    }
    return result
}

function mul(a::Array{Float, 1}, b::Array{Float, 1}) {
    result = similar(a)
    i = 1
    while (i <= length(a)) {
        set(result, i, get(a, i) * get(b, i))
        i = i + 1
    }
    return result
}

function mul(a::Float, b::Array{Float, 1}) {
    return mul(b, a)
}

function add(a::Array{Float, 1}, b::Array{Float, 1}) {
    result = similar(a)
    i = 1
    while (i <= length(a)) {
        set(result, i, get(a, i) + get(b, i))
        i = i + 1
    }
    return result
}

function forward(x::Float, w1::Array{Float, 1}, b1::Array{Float, 1}, 
                 w2::Array{Float, 1}, b2::Float) {
    z1 = mul(w1, x) + b1
    a1 = sigmoid(z1)
    z2 = sum(mul(w2, a1)) + b2
    return z2
}

function square_error(y::Float, y_hat::Float) {
    return 0.5 * (y - y_hat)^2
}

function square_error_derivative(y::Float, y_hat::Float) {
    return y_hat - y
}

function test(x::Float, w1::Array{Float, 1}, b1::Array{Float, 1}, 
              w2::Array{Float, 1}, b2::Float) {
    truth = sin(x)
    yhat = forward(x, w1, b1, w2, b2)
    
    print("ŷ = ")
    print(yhat)
    print(" (expected ")
    print(truth)
    println(")")
    
    return 0
}

function log(epoch::Int, loss::Float) {
    print("[epoch ")
    print(epoch)
    print("] loss: ")
    println(loss)
    return 0
}

function train(x::Array{Float, 1}, y::Array{Float, 1}, epochs::Int, learning_rate::Float) {
    # 入力: float
    # 隠れ層: 10ニューロン
    # 出力: float
    w1 = [0.2, -0.2, 0.3, 0.3, -0.5, 0.6, -0.7, 0.8, 0.4, 0.1]
    b1 = [-0.4, 0.2, -0.3, 0.4, 0.1, -0.6, 0.5, 0.8, 0.2, 0.1]
    w2 = [0.3, -0.1, 0.3, 0.4, 0.5, -0.6, 0.7, 0.8, -0.9, 0.1]
    b2 = 0.2
    
    epoch = 1
    while (epoch <= epochs) {
        loss_sum = 0.0
        
        dw1_acc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        db1_acc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        dw2_acc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        db2_acc = 0.0
        
        j = 1
        count = get(size(x), 1)
        while (j <= count) {
            _x = get(x, j)
            _y = get(y, j)
            
            # --- forward ---
            yhat = forward(_x, w1, b1, w2, b2)
            loss = square_error(_y, yhat)
            loss_sum = loss_sum + loss
            
            # --- backprop ---
            dloss = square_error_derivative(_y, yhat)
            dz2 = dloss
            
            dw2_ = mul(dz2, sigmoid(mul(w1, _x) + b1))
            db2_ = dz2
            
            da1 = mul(dz2, w2)
            dz1 = mul(da1, sigmoid_derivative(mul(w1, _x) + b1))
            dw1_ = mul(dz1, _x)
            db1_ = dz1
            
            dw1_acc = add(dw1_acc, dw1_)
            db1_acc = add(db1_acc, db1_)
            dw2_acc = add(dw2_acc, dw2_)
            db2_acc = db2_acc + db2_
            
            j = j + 1
        }
        
        dw1_acc = mul(dw1_acc, 1.0 / count)
        db1_acc = mul(db1_acc, 1.0 / count)
        dw2_acc = mul(dw2_acc, 1.0 / count)
        db2_acc = db2_acc / count
        
        w1 = sub(w1, mul(learning_rate, dw1_acc))
        b1 = sub(b1, mul(learning_rate, db1_acc))
        w2 = sub(w2, mul(learning_rate, dw2_acc))
        b2 = b2 - (learning_rate * db2_acc)
        
        log(epoch, loss_sum / count)
        
        if (epoch % 100 == 0) {
            test(0.0, w1, b1, w2, b2)
            test(pi() / 4, w1, b1, w2, b2)
            test(pi() / 2, w1, b1, w2, b2)
            test(3 * pi() / 4, w1, b1, w2, b2)
            test(pi(), w1, b1, w2, b2)
        }
        
        epoch = epoch + 1
    }
    
    print("w1: ")
    println(w1)
    print("b1: ")
    println(b1)
    print("w2: ")
    println(w2)
    print("b2: ")
    println(b2)
    
    test(0.0, w1, b1, w2, b2)
    test(pi() / 4, w1, b1, w2, b2)
    test(pi() / 2, w1, b1, w2, b2)
    test(3 * pi() / 4, w1, b1, w2, b2)
    test(pi(), w1, b1, w2, b2)
    
    return 0
}

function main() {
    x = get_x()
    y = get_y(x)
    result = train(x, y, 100, 0.25)
    return 0
}
