module MuTypes

using ..MuAST
import Base

# [Type hierarchy]
#                      Any
#           ------------|--------------
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
struct Array{T <: MuType, N} <: MuType end
struct Union{S <: MuType, T <: MuType} <: MuType end
struct Tuple{S <: MuType, T <: MuType} <: MuType end
struct Bottom <: MuType end


isconcrete(::Type{Any}) = false
isconcrete(::Type{Number}) = false
isconcrete(::Type{Real}) = false
isconcrete(::Type{AbstractString}) = false
isconcrete(::Type{AbstractArray}) = false
isconcrete(::Type{<:Union}) = false
isconcrete(::Type{Bottom}) = false

isconcrete(::Type{Int}) = true
isconcrete(::Type{Float}) = true
isconcrete(::Type{Bool}) = true
isconcrete(::Type{String}) = true
isconcrete(::Type{<:Array}) = true
isconcrete(::Type{<:Tuple}) = true


supertype(::Type{Any}) = throw(ArgumentError("`Any` has no supertype"))
supertype(::Type{Number}) = Any
supertype(::Type{Real}) = Number
supertype(::Type{Int}) = Real
supertype(::Type{Float}) = Real
supertype(::Type{Bool}) = Number
supertype(::Type{AbstractString}) = Any
supertype(::Type{String}) = AbstractString
supertype(::Type{AbstractArray}) = Any
supertype(::Type{Array{T, N}}) where {T, N} = AbstractArray
supertype(::Type{Union{S, T}}) where {S, T} = Any
supertype(::Type{Tuple{S, T}}) where {S, T} = Any

# Supertype of Bottom is all of concrete types, makes implementation complex. For now, throw an error.
supertype(::Type{Bottom}) = throw(DomainError("Cannot get supertype of `Bottom`` because of infinite types are there."))



isunion(::Type{Union{S, T}}) where {S, T} = true
isunion(::Type{T}) where {T <: MuType} = false

function uniontype(types::Base.AbstractArray)
    if isempty(types)
        return Union
    end

    if length(types) == 1
        return Union{types[1]}
    end

    t = Union{types[1], types[2]}

    for i in eachindex(types)[3:end]
        t = Union{t, types[i]}
    end

    return t
end

uniontype(t::Base.Union) = Union{_type_to_mutype(t.a), uniontype(t.b)}
uniontype(t::DataType) = _type_to_mutype(t)

function tupletype(types::Base.AbstractArray, T)
    if isempty(types)
        return Tuple
    end

    if length(types) == 1
        return Tuple{types[1]}
    end

    t = Tuple{types[1], types[2]}

    for i in eachindex(types)[3:end]
        t = Tuple{t, types[i]}
    end

    return t
end

tupletype(t::Base.Tuple) = Tuple{_type_to_mutype(t.a), tupletype(t.b)}
tupletype(t::DataType) = _type_to_mutype(t)


# Expand Union type.
# e.g. expand_types(Union{Int, Union{Float, Bool}}) => [Int, Float, Bool]
expand_types(::Type{Union{S, T}}) where {S, T} = [expand_types(S); expand_types(T)]
expand_types(::Type{Union{S}}) where {S} = [expand_types(S)]
expand_types(::Type{Union}) = []

expand_types(::Type{T}) where {T <: MuType} = [T]

# Get component types of Tuple type.
# e.g. component_types(Tuple{Int, Float}) => [Int, Float]
#
# Note: separate function from `expand_types` because of avoid this behavior: 
# expand_types(Union{Tuple{Int, Float}, Tuple{Bool, String}}) => [Int, Float, Bool, String]
component_types(::Type{Tuple{S, T}}) where {S, T} = [S, T]
component_types(::Type{Tuple{S}}) where {S} = [S]
component_types(::Type{Tuple}) = []
component_types(::Type{T}) where {T <: MuType} = [T]

# Normalize Union type.
# In normalized form, `Union` is only appear at the top level.
_normalize(::Type{T}) where {T <: MuType} = T


function _normalize(::Type{Tuple{Union{S1, S2}, Union{T1, T2}}}) where {S1, S2, T1, T2} 
    return Union{_normalize(Tuple{S1, T1}), _normalize(Tuple{S1, T2}), _normalize(Tuple{S2, T1}), _normalize(Tuple{S2, T2})}
end


_normalize(::Type{Tuple{Union{S, T}, U}}) where {S, T, U} = Union{_normalize(Tuple{S, U}), _normalize(Tuple{T, U})}
_normalize(::Type{Tuple{S, Union{T, U}}}) where {S, T, U} = Union{_normalize(Tuple{S, T}), _normalize(Tuple{S, U})}
                                                                                                                                                                                                                                                                                                                                                                              
_normalize(::Type{Union{S, T}}) where {S <: MuType, T <: MuType} = Union{_normalize(S), _normalize(T)}

normalize(::Type{T}) where {T <: MuType} = _normalize(T)


# t1 <: t2

# Bottom <: t for all t
issubtype(::Type{Bottom}, ::Type{Bottom}) = true
issubtype(::Type{Bottom}, ::Type{<:MuType}) = true
issubtype(::Type{Bottom}, ::Type{<:Union}) = true

# t <: Any for all t
issubtype(::Type{Any}, ::Type{Any}) = true
issubtype(::Type{Any}, ::Type{<:MuType}) = false
issubtype(::Type{Any}, ::Type{<:Union}) = false
issubtype(::Type{<:Union}, ::Type{Any}) = true

# U1 <: U2 ⇔ ∀u ∈ U1, u <: U2
issubtype(::Type{U1}, ::Type{U2}) where {U1 <: Union, U2 <: Union} = all(issubtype(u, U2) for u in expand_types(U1))
# U <: T ⇔ ∀u ∈ U, u <: T
issubtype(::Type{U}, ::Type{T}) where {T <: MuType, U <: Union} = all(issubtype(u, T) for u in expand_types(U))
# T <: U ⇔ ∃u ∈ U, T <: u
issubtype(::Type{T}, ::Type{U}) where {T <: MuType, U <: Union} = any(issubtype(T, u) for u in expand_types(U))
# S <: T, if there is a chain of subtypes from S to T.
issubtype(::Type{S}, ::Type{T}) where {S <: MuType, T <: MuType} = issubtype(supertype(S), T) || S == T


# Tuple{S} <: Tuple{T} ⇔ 
#  1. #S = #T
#  2. ∀i, Sᵢ <: Tᵢ
function issubtype(S::Type{Tuple{S1, T1}}, T::Type{Tuple{S2, T2}}) where {S1 <: MuType, T1 <: MuType, S2 <: MuType, T2 <: MuType}
    (length(component_types(S)) != length(component_types(T))) && return false

    return all(issubtype(s, t) for (s, t) in zip(component_types(S), component_types(T)))
end

issubtype(::Type{Tuple{S}}, ::Type{T}) where {S <: MuType, T <: MuType} = false
issubtype(::Type{S}, ::Type{Tuple{T}}) where {S <: MuType, T <: MuType} = false




jointype(::Type{S}, ::Type{T}) where {S <: MuType, T <: MuType} = issubtype(S, T) ? T : issubtype(T, S) ? S : Union{S, T}

function meettype(::Type{T}, ::Type{U}) where {T <: MuType, U <: MuType}
    if issubtype(T, U)
        return T
    elseif issubtype(U, T)
        return U
    elseif isunion(T)
        return reduce(jointype, (meettype(t, U) for t in expand_types(T)))
    elseif isunion(U)
        return meettype(U, T)
    else
        return Bottom
    end
end

Base.:(==)(::Type{U1}, ::Type{U2}) where {U1 <: Union, U2 <: Union} = Set(expand_types(U1)) == Set(expand_types(U2))

include("conversion.jl")


export MuType

end # module
