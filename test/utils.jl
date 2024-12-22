using Test

onfail(body, _::Test.Pass) = true
onfail(body, _::Union{Test.Fail,Test.Error}) = body()


function load(filename::AbstractString)
    return join(readlines(filename), "\n")
end

function iserror(; expectederror::Type{<:Exception}=Exception)
    return ((e) -> e isa expectederror)
end