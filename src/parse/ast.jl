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
    GCALL # Generic function call
    BCALL # Builtin function call
    ASSIGN     # Assignment

    IFELSE     # If-else statement
    IF         # If statement
    WHILE      # While statement

    PROGRAM    # Special type to represent the whole program
    BLOCK      # Block to group multiple expressions

    FUNCTION   # For function definition
    FORMALARGS # |  Formal arguments for function definition
    TYPEDIDENT # |  Typed identifier. e.g. `a::Array{Int, 2}`
    TYPE       # |  Type. e.g. `Array{Int, 2}`
    RETURN     # |  Return statement

    GOTO         #  Goto label without condition        |
    GOTOIFNOT    #  Goto label if condition is false    | ==> These are for IR.
    LABEL        #  Label for goto                      |     Result of `parse` function will not have these.
end

struct Expr <: AbstractSyntaxNode
    head::ExprHead
    args::Vector{Any} # It is not avoidable to use `Any` here.
end

const IDENT_WIDTH = 4

const KEYWORDS_COLOR = :magenta
const DEFAULT_COLOR = :light_green
const COMMENT_COLOR = :light_black
const IDENT_COLOR = :white
const STRING_COLOR = :light_yellow
const BRACKET_COLORS = [:blue, :cyan, :light_blue, :light_green, :light_yellow]

gen_bracket_color(indent) = BRACKET_COLORS[(indent÷IDENT_WIDTH)%length(BRACKET_COLORS)+1]


# The difference in the interfaces of `Ident` and `Expr` is purely due to historical reasons.
# In the future, these should be unified, and all output, including color control,
# should be handled by `show_expr` (also it should be renamed).
# For now, let's leave a working version here for the time being.
function show_expr(io::IO, expr::Expr; indent::Int=0)
    indent_str = repeat(" ", indent * IDENT_WIDTH)
    subindent_str = repeat(" ", (indent + 1) * IDENT_WIDTH)

    print_noindent(args...; color=DEFAULT_COLOR)  = printstyled(io, args...; color=color)
    print_indent(args...; color=DEFAULT_COLOR)    = printstyled(io, indent_str, args...; color=color)
    print_subindent(args...; color=DEFAULT_COLOR) = printstyled(io, subindent_str, args...; color=color)
    newline() = println(io)
    space() = print_noindent(" ")

    if expr.head == FORMALARGS
        bracket_color = gen_bracket_color(indent)
        print_indent("(", color=bracket_color)
        if isempty(expr.args)
            print_noindent("#= No arguments =#", color=COMMENT_COLOR)
        else
            print_noindent(expr.args[1], color=IDENT_COLOR)
            for arg in expr.args[2:end]
                space()
                show_expr(io, arg, indent=indent + 1)
            end
        end
        print_noindent(")", color=bracket_color)
    elseif expr.head == TYPEDIDENT
        print_noindent(expr.args[1], "::", color=KEYWORDS_COLOR)
        show_expr(io, expr.args[2], indent=indent + 1)
    elseif expr.head == TYPE
        if length(expr.args) == 1  # No type parameter
            if isa(expr.args[1], Expr)
                show_expr(io, expr.args[1], indent=indent + 1) # e.g. random_type()
            else
                print_noindent(expr.args[1], color=IDENT_COLOR) # e.g. Int
            end
        else   # Type parameter exists
            head_part = expr.args[1] # e.g. Array
            tail_part = join(expr.args[2:end], ", ") # e.g. {Int, 2}
            print_noindent(head_part, "{", tail_part, "}"; color=IDENT_COLOR)
        end
    elseif expr.head == ASSIGN || expr.head == GCALL || expr.head == BCALL || expr.head == RETURN
        bracket_color = gen_bracket_color(indent)
        print_indent("(", color=bracket_color)
        print_noindent(expr.head, " ", color=KEYWORDS_COLOR)
        print_noindent(expr.args[1])
        for arg in expr.args[2:end]
            if isa(arg, Expr)
                space()
                show_expr(io, arg, indent=0)
            elseif isa(arg, String)
                print_noindent(" ", "\"", arg, "\"", color=STRING_COLOR)
            else
                print_noindent(" ", arg, color=DEFAULT_COLOR)
            end
        end
        print_noindent(")", color=bracket_color)
    elseif expr.head == FUNCTION
        bracket_color = gen_bracket_color(indent)
        print_indent("(", color=bracket_color)
        print_noindent("FUNCTION", color=KEYWORDS_COLOR)
        newline()
        print_subindent(expr.args[1], color=KEYWORDS_COLOR)# Function name
        newline()
        show_expr(io, expr.args[2], indent=indent + 1) # Formal arguments
        newline()
        show_expr(io, expr.args[3], indent=indent + 1) # Body
        newline()
        print_indent(")", color=bracket_color)
    else
        bracket_color = gen_bracket_color(indent)
        print_indent("(", color=bracket_color)
        print_noindent(expr.head, color=KEYWORDS_COLOR)
        newline()
        for arg in expr.args
            (expr.head == PROGRAM) && (newline())
            if isa(arg, Expr)
                show_expr(io, arg, indent=indent + 1)
            elseif isa(arg, String)
                print_subindent("\"", arg, "\"", color=STRING_COLOR)
            else
                print_subindent(arg, color=DEFAULT_COLOR)
            end
            newline()
        end
        print_indent(")", color=bracket_color)
    end
end

function Base.show(io::IO, expr::Expr)
    show_expr(io, expr, indent=0)
end

function Base.show(io::IO, ident::Ident)
    printstyled(io, ident.name, color=IDENT_COLOR)
end


function Base.:(==)(lhs::Ident, rhs::Ident)
    return lhs.name == rhs.name
end

function Base.:(==)(lhs::Expr, rhs::Expr)
    return lhs.head == rhs.head && lhs.args == rhs.args
end

export Expr, ExprHead, Ident

end # module MuAST