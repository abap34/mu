import Base

module MuAST

abstract type AbstractSyntaxNode end

const KEYWORDS = [
    "if", "else", "elseif", "while"
]


function valid_identifier(name::String)
    return Base.isidentifier(name) && !(name in KEYWORDS)
end

struct Ident <: AbstractSyntaxNode
    name::String
    function Ident(name::String)
        # @assert valid_identifier(name) "Invalid identifier: \"$name\""
        new(name)
    end
end

const UNUSED_IDENT = Ident("_")

const Literal = Union{Int, Float64, String, Bool, Array}

Base.show(io::IO, ident::Ident) = print(io, "`", ident.name, "`")

@enum ExprHead begin
    CALL
    ASSIGN
    BLOCK
    IFELSE
    IF
    WHILE
    PROGRAM
    GOTO         # |
    GOTOIFNOT    # | ==> These types are only used in IR.
    LABEL        # |     Result of `parse` doesn't contain these types.    
end

struct Expr <: AbstractSyntaxNode
    head::ExprHead
    args::Vector{Any} # It is not avoidable to use Any here
end

Base.show(io::IO, expr::Expr) = begin
    print(io, "(", expr.head)
    for arg in expr.args
        print(io, " ", arg)
    end
    print(io, ")")
end

function Base.:(==)(expr1::Expr, expr2::Expr)
    if expr1.head != expr2.head
        return false
    end
    if length(expr1.args) != length(expr2.args)
        return false
    end
    for (arg1, arg2) in zip(expr1.args, expr2.args)
        if arg1 != arg2
            return false
        end
    end
    return true
end

export Expr, ExprHead, Ident

end # module MuAST