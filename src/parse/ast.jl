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

const Literal = Union{Int,Float64,String,Bool,Array}

@enum ExprHead begin
    CALL       # Function call
    ASSIGN     # Assignment

    IFELSE     # If-else statement
    IF         # If statement
    WHILE      # While statement

    PROGRAM    # Special type to represent the whole program
    BLOCK      # Block to group multiple expressions

    FUNCTION   # For function definition
    FORMALARGS # | Formal arguments for function definition
    TYPEDIDENT # |  TYPEDIDENT for function formal arguments 
    TYPE       # |  Type parameter  e.g. `Array{T, N}`             
    RETURN     # |  Return statement

    GOTO         #  Goto label without condition        |
    GOTOIFNOT    #  Goto label if condition is false    | ==> These are for IR.
    LABEL        #  Label for goto                      |     Result of `parse` function will not have these.
end

struct Expr <: AbstractSyntaxNode
    head::ExprHead
    args::Vector{Any} # It is not avoidable to use Any here
end
const IDENT_WIDTH = 2

function show_expr(io::IO, expr::Expr; indent::Int=0)
    indent_str = repeat(" ", indent * IDENT_WIDTH)
    subindent_str = repeat(" ", (indent + 1) * IDENT_WIDTH)

    print_indent(args...) = print(io, indent_str, args...)
    print_subindent(args...) = print(io, subindent_str, args...)
    newline() = println(io)

    # TYPEDIDENT
    if expr.head == TYPEDIDENT
        print_indent("(TYPEDIDENT ")
        # newline()
        print(expr.args[1], " :: ")

        if isa(expr.args[2], Expr)
            # newline()
            show_expr(io, expr.args[2]; indent=indent + 2)
        else
            print(io, expr.args[2])
        end

        # newline()
        print(")")

    elseif expr.head == TYPE
        print("(TYPE")
        # newline()
        if length(expr.args) == 1
            if isa(expr.args[1], Expr)
                show_expr(io, expr.args[1]; indent=indent + 1)
            else
                print(expr.args[1])
            end
        else
            head_part = expr.args[1]
            tail_part = join(expr.args[2:end], ", ")
            print(head_part, "{", tail_part, "}")
        end
        # newline()
        print(")")
    else
        print_indent("(")
        print(io, expr.head)
        newline()
        for arg in expr.args
            if isa(arg, Expr)
                show_expr(io, arg; indent=indent + 1)
            elseif isa(arg, String)
                print_subindent("\"", arg, "\"")    
            else
                print_subindent(arg)
            end
            newline()
        end
        print_indent(")")
    end
end

function Base.show(io::IO, expr::Expr)
    show_expr(io, expr; indent=0)
end

function Base.show(io::IO, ident::Ident)
    print(io, "`", ident.name, "`")
end


function Base.:(==)(lhs::Ident, rhs::Ident)
    return lhs.name == rhs.name
end

function Base.:(==)(lhs::Expr, rhs::Expr)
    return lhs.head == rhs.head && lhs.args == rhs.args
end

export Expr, ExprHead, Ident

end # module MuAST