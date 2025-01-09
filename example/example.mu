function sort(arr::Array{Int, 1}){
    n = length(arr)
    i = 1
    while (i < n){
        j = i + 1
        while (j <= n){
            if (get(arr, i) > get(arr, j)){
                temp = get(arr, i)
                set(arr, i, get(arr, j))
                set(arr, j, temp)
            }
            j = j + 1
        }
        i = i + 1
    }

    return arr
}

function issorted(arr::Array{Int, 1}){
    n = length(arr)
    i = 1
    while (i < n){
        if (get(arr, i) > get(arr, i + 1)){
            return false
        }
        i = i + 1
    }

    return true
}


function binarysearch(arr::AbstractArray, target::Int){
    low = 1
    high = length(arr)
    while (low <= high){
        mid = floor((low + high) / 2)
        if (get(arr, mid) == target){
            return mid
        } else {
            if (get(arr, mid) < target){
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
    }

    return false
}


function main(){
    arr = [8, 12, 3, 5, 8, 2, 34, 1, 0, 9]

    arr = sort(arr)

    print(arr)

    if (issorted(arr)){
        print("Check sorted")
    } else {
        print("Not sorted")
    }
    
    n_tests = 10

    i = 1
    
    while (i <= n_tests){
        target = i
        idx = binarysearch(arr, target)
        if (idx == -1){
            print("❌ not found")
        } else {
            print("✅ found")
        }

        i = i + 1
    }

    return 0
}