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
struct Array{T<:MuType,N} <: MuType end
struct Union{S<:MuType,T<:MuType} <: MuType end
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
issubtype(::Type{T}, ::Type{U}) where {T<:MuType,U<:Union} = any(issubtype(T, u) for u in expand_types(U))

issubtype(::Type{S}, ::Type{T}) where {S<:MuType,T<:MuType} = issubtype(supertype(S), T) || S == T

jointype(::Type{S}, ::Type{T}) where {S<:MuType,T<:MuType} = issubtype(S, T) ? T : issubtype(T, S) ? S : Union{S,T}

function meettype(::Type{T}, ::Type{U}) where {T<:MuType,U<:MuType}
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



Base.:(==)(::Type{U1}, ::Type{U2}) where {U1<:Union,U2<:Union} = Set(expand_types(U1)) == Set(expand_types(U2))

const NON_PARMETRIC_TYPES_STR = ["Any", "Number", "Real", "Int", "Float", "Bool", "AbstractString", "String", "AbstractArray", "Bottom"]


function _str_to_type(name::Base.String)
    @assert name in NON_PARMETRIC_TYPES_STR "Type name must be one of $(NON_PARMETRIC_TYPES_STR). Got $name"
    if name == "Any"
        return Any
    elseif name == "Number"
        return Number
    elseif name == "Real"
        return Real
    elseif name == "Int"
        return Int
    elseif name == "Float"
        return Float
    elseif name == "Bool"
        return Bool
    elseif name == "AbstractString"
        return AbstractString
    elseif name == "String"
        return String
    elseif name == "AbstractArray"
        return AbstractArray
    elseif name == "Bottom"
        return Bottom
    else
        throw(ArgumentError("Unknown type: $name"))
    end
end

function shorten_str(t::DataType)
    if t <: Array
        return "Array{" * shorten_str(t.parameters[1]) * ", " * string(t.parameters[2]) * "}"
    elseif t <: Union
        return "Union{" * join([shorten_str(x) for x in expand_types(t)], ", ") * "}"
    elseif t == Any
        return "Any"
    elseif t == Number
        return "Number"
    elseif t == Real
        return "Real"
    elseif t == Int
        return "Int"
    elseif t == Float
        return "Float"
    elseif t == Bool
        return "Bool"
    elseif t == AbstractString
        return "AbstractString"
    elseif t == String
        return "String"
    elseif t == AbstractArray
        return "AbstractArray"
    elseif t == Bottom
        return "Bottom"
    
    else
        return string(t)
    end
end

function _type_to_mutype(t::DataType)
    if t == Base.Any
        return Any
    elseif t == Base.Number
        return Number
    elseif t == Base.Real
        return Real
    elseif t == Base.Int
        return Int
    elseif t == Base.Float64
        return Float
    elseif t == Base.Bool
        return Bool
    elseif t == Base.String
        return String
    elseif t == Base.AbstractString
        return AbstractString
    elseif t == Base.AbstractArray
        return AbstractArray
    elseif t == Base.Bottom
        return Bottom
    elseif t isa Array
        return Array{_type_to_mutype(eltype(t)), ndims(t)}
    else
        throw(ArgumentError("Unknown type: $t"))
    end
end

function astype(type::MuAST.Ident)
    @assert type.name in NON_PARMETRIC_TYPES_STR "Type name must be one of $(NON_PARMETRIC_TYPES_STR). Got $(type.name)"
    return _str_to_type(type.name)
end


function astype(type::MuAST.Expr)
    @assert type.head == MuAST.TYPE "`astype` can only be applied to `TYPE` expression. Got $(type.head)"

    name = type.args[1].name
    params = type.args[2:end]

    if name in NON_PARMETRIC_TYPES_STR
        @assert isempty(params) "Type $name does not take any parameters. Got $(length(params))"
        return _str_to_type(name)

    elseif name == "Array"
        elemtype = astype(params[1])
        dim = type.args[3]

        return Array{elemtype, dim}
    elseif name == "Union"
        @assert length(params) >= 2 "Union type must have at least 2 types. Got $(length(type.args))"

        t = Union{astype(pop!(params)), astype(pop!(params))}

        
        while !isempty(params)
            t = Union{astype(pop!(params)), t}
        end

        return t
    else
        throw(ArgumentError("Unknown type: $name"))
    end
end

function typeof(v)
    if isa(v, Base.Bool)
        return Bool
    elseif isa(v, Base.Int)
        return Int
    elseif isa(v, Base.Float64)
        return Float
    elseif isa(v, Base.String)
        return String
    elseif isa(v, Base.Array)
        return Array{_type_to_mutype(eltype(v)), ndims(v)}
    else
        throw(ArgumentError("Unknown Value!: $v $(Base.typeof(v)). Only Int, Float64, String, Bool, Array are supported."))
    end
end


export MuType

end # module
