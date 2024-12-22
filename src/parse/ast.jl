module MuAST

abstract type AbstractSyntaxNode end

struct Ident <: AbstractSyntaxNode
    name::String
end


struct Expr <: AbstractSyntaxNode
    head::Symbol
    args::Vector{Any} # It is not avoidable to use Any here
end

end # module MuAST