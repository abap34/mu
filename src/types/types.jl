module MuTypes

# [Type hierarchy]
#                      Any
#           ------------|-------------
#         /             |              \
#       Number   AbstractString   AbstractArray
#       /    \          |               |
#      /      \         |               |
#    Real     Bool    String          Array
#     / \       |       |            /  |   \
#    /   \      |       |         All Array types,
#  Int   Float  \       |         e.g. Array{Int, 2}, Array{Float, 1},...
#    \      \    \      |         /     /     /
#     \      \    \     |        /     /     /  
#      -------\------ Bottom ---/-----/-----/          [ + Union Type ]
#                   

abstract type MuType end

struct Any <: MuType end
struct Number <: MuType end
struct Real <: MuType end
struct Int <: MuType end
struct Float <: MuType end
struct Bool <: MuType end
struct AbstractString <: MuType end
struct String <: MuType end
struct AbstractArray <: MuType end
struct Array{T<:MuType,N} <: MuType end
struct Union{S<:MuType,T<:MuType} <: MuType end
struct Bottom <: MuType end



is_concrete(::Type{Any}) = false
is_concrete(::Type{Number}) = false
is_concrete(::Type{Real}) = false
is_concrete(::Type{AbstractString}) = false
is_concrete(::Type{AbstractArray}) = false
is_concrete(::Type{<:Union}) = false
is_concrete(::Type{Bottom}) = false

is_concrete(::Type{Int}) = true
is_concrete(::Type{Float}) = true
is_concrete(::Type{Bool}) = true
is_concrete(::Type{String}) = true
is_concrete(::Type{<:Array}) = true


supertype(::Type{Any}) = throw(ArgumentError("`Any` has no supertype"))
supertype(::Type{Number}) = Any
supertype(::Type{Real}) = Number
supertype(::Type{Int}) = Real
supertype(::Type{Float}) = Real
supertype(::Type{Bool}) = Number
supertype(::Type{AbstractString}) = Any
supertype(::Type{String}) = AbstractString
supertype(::Type{AbstractArray}) = Any
supertype(::Type{Array{T,N}}) where {T,N} = AbstractArray
supertype(::Type{Union{S,T}}) where {S,T} = Any

# Supertype of Bottom is all of concrete types, makes implementation complex. For now, throw an error.
supertype(::Type{Bottom}) = throw(DomainError("Cannot get supertype of `Bottom`` because of infinite types are there."))



isunion(::Type{Union{S,T}}) where {S,T} = true
isunion(::Type{T}) where {T<:MuType} = false


# Expand Union type.
# e.g. expand_types(Union{Int, Union{Float, Bool}}) => [Int, Float, Bool]
expand_types(::Type{Union{S,T}}) where {S,T} = [expand_types(S); expand_types(T)]
expand_types(::Type{T}) where {T<:MuType} = [T]



# t1 <: t2
issubtype(::Type{Bottom}, ::Type{Bottom}) = true
issubtype(::Type{Bottom}, ::Type{<:MuType}) = true
issubtype(::Type{Bottom}, ::Type{<:Union}) = true

issubtype(::Type{Any}, ::Type{Any}) = true
issubtype(::Type{Any}, ::Type{<:MuType}) = false
issubtype(::Type{Any}, ::Type{<:Union}) = false
issubtype(::Type{<:Union}, ::Type{Any}) = true

issubtype(::Type{U1}, ::Type{U2}) where {U1<:Union,U2<:Union} = all(issubtype(u, U2) for u in expand_types(U1))
issubtype(::Type{U}, ::Type{T}) where {T<:MuType,U<:Union} = all(issubtype(u, T) for u in expand_types(U))
issubtype(::Type{T}, ::Type{U}) where {T<:MuType,U<:Union} = any(issubtype(u, T) for u in expand_types(U))

issubtype(::Type{S}, ::Type{T}) where {S<:MuType,T<:MuType} = issubtype(supertype(S), T) || S == T

end
