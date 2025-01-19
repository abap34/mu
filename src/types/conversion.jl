
# Conversion of Types between MuType and DataType, String
const NON_PARMETRIC_TYPES_STR = ["Any", "Number", "Real", "Int", "Float", "Bool", "AbstractString", "String", "AbstractArray", "Bottom"]

function _str_to_type(name::Base.String)
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
    elseif name == "Array"
        return Array
    elseif name == "Tuple"
        return Tuple
    elseif name == "Bottom"
        return Bottom
    else
        throw(ArgumentError("Cannot convert \"$name\" to MuType."))
    end
end

function shorten_str(t::DataType)
    if t <: Array
        return "Array{" * shorten_str(t.parameters[1]) * ", " * string(t.parameters[2]) * "}"
    elseif t <: Union
        return "Union{" * join([shorten_str(x) for x in expand_types(t)], ", ") * "}"
    elseif t <: Tuple
        return "Tuple{" * join([shorten_str(x) for x in component_types(t)], ", ") * "}"
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
    elseif t isa Base.Array
        return Array{_type_to_mutype(eltype(t)), ndims(t)}
    elseif t isa Base.Union
        return uniontype(t)
    elseif t isa Base.Tuple
        return tupletype(t)
    else
        throw(ArgumentError("Unknown type: $t"))
    end
end

function expr_to_type(type::MuAST.Ident)
    return _str_to_type(type.name)
end


function expr_to_type(type::MuAST.Expr)::Type{<:MuType}
    @assert type.head == MuAST.TYPE "`expr_to_type` can only be applied to `TYPE` expression. Got $(type.head)"

    name = type.args[1].name
    params = type.args[2:end]

    if name in NON_PARMETRIC_TYPES_STR
        @assert isempty(params) "Type $name does not take any parameters. Got $(length(params))"
        return _str_to_type(name)

    elseif name == "Array"        
        if isempty(params)
            return Array
        end
        
        if length(params) == 1
            return Array{expr_to_type(params[1])}
        end
        
        elemtype = expr_to_type(params[1])
        dim = params[2]

        return Array{elemtype, dim}


    elseif name == "Union"
        if isempty(params)
            return Union
        end

        if length(params) == 1
            return Union{expr_to_type(pop!(params))}
        end

        
        t = Union{expr_to_type(pop!(params)), expr_to_type(pop!(params))}


        while !isempty(params)
            t = Union{expr_to_type(pop!(params)), t}
        end

        return t

    elseif name == "Tuple"
        if isempty(params)
            return Tuple
        end

        if length(params) == 1
            return Tuple{expr_to_type(pop!(params))}
        end

        t = Tuple{expr_to_type(pop!(params)), expr_to_type(pop!(params))}

        while !isempty(params)
            t = Tuple{expr_to_type(pop!(params)), t}
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
    elseif isa(v, Base.Tuple)
        return tupletype([typeof(_v) for _v in v])
    else
        throw(ArgumentError("Unknown Value!: $v $(Base.typeof(v)). Only Int, Float64, String, Bool, Array are supported."))
    end
end


