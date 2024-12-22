import Base

module MuAST

abstract type AbstractSyntaxNode end

struct Ident <: AbstractSyntaxNode
    name::String
end

Base.show(io::IO, ident::Ident) = print(io, "`", ident.name, "`")


struct Expr <: AbstractSyntaxNode
    head::Symbol
    args::Vector{Any} # It is not avoidable to use Any here
end

Base.show(io::IO, expr::Expr) = begin
    print(io, "(", expr.head)
    for arg in expr.args
        print(io, " ", arg)
    end
    print(io, ")")
end

end # module MuAST