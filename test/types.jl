using mu.MuCore
using mu.MuCore.MuTypes
using mu.MuCore.MuAST


const TARGET_TYPES = [
    MuTypes.Any, MuTypes.Number,
    MuTypes.Real,
    MuTypes.Int,
    MuTypes.Float,
    MuTypes.Bool,
    MuTypes.AbstractString,
    MuTypes.String,
    MuTypes.AbstractArray, MuTypes.Array{MuTypes.Int,1},
    MuTypes.Array{MuTypes.Float,1},
    MuTypes.Array{MuTypes.Int,2},
    MuTypes.Array{MuTypes.Float,2},
    MuTypes.Array{MuTypes.Real,1},
    MuTypes.Array{MuTypes.Real,2},
    MuTypes.Array{MuTypes.Any,3}, MuTypes.Union{MuTypes.Int,MuTypes.Float},
    MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Real}},
    MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Union{MuTypes.Real,MuTypes.Bool}}},
    MuTypes.Union{MuTypes.Bottom,MuTypes.Bottom},
    MuTypes.Union{MuTypes.Bottom,MuTypes.Number},
    MuTypes.Union{MuTypes.Bottom,MuTypes.Union{MuTypes.Bottom,MuTypes.Bottom}},
    MuTypes.Union{MuTypes.Any,MuTypes.Bottom}, MuTypes.Bottom,
]

const TARGET_CONCREATE_TYPES = [
    MuTypes.Int,
    MuTypes.Float,
    MuTypes.Bool,
    MuTypes.String,
    MuTypes.Array{MuTypes.Int,1},
    MuTypes.Array{MuTypes.Float,1},
    MuTypes.Array{MuTypes.Int,2},
    MuTypes.Array{MuTypes.Float,2},
    MuTypes.Array{MuTypes.Real,1},
    MuTypes.Array{MuTypes.Real,2},
    MuTypes.Array{MuTypes.Any,3},
]


@testset "Concreate check" begin
    for t in TARGET_CONCREATE_TYPES
        onfail(@test MuTypes.is_concrete(t)) do
            @error "Failed! $t must be concrete type. But `MuTypes.is_concrete(t)` returns false or error."
        end
    end
end

@testset "`Bottom` always Subtype" begin
    for t in TARGET_TYPES
        onfail(@test MuTypes.issubtype(MuTypes.Bottom, t)) do
            @error "Failed! Bottom must be subtype of $t. But `MuTypes.issubtype(MuTypes.Bottom, t)` returns false or error."
        end
    end
end

@testset "`Any` always Supertype" begin
    for t in TARGET_TYPES
        onfail(@test MuTypes.issubtype(t, MuTypes.Any)) do
            @error "Failed! $t must be subtype of Any. But `MuTypes.issubtype(t, MuTypes.Any)` returns false or error."
        end
    end
end

# t1 <: t2 case
const SUBTYPES = [
    # t1 = t2 case
    (MuTypes.Any, MuTypes.Any),
    (MuTypes.Bottom, MuTypes.Bottom),
    (MuTypes.Number, MuTypes.Number),
    (MuTypes.Real, MuTypes.Real),
    (MuTypes.Int, MuTypes.Int),
    (MuTypes.Float, MuTypes.Float),
    (MuTypes.Array{MuTypes.Int,1}, MuTypes.Array{MuTypes.Int,1}),

    # simply subtype case
    (MuTypes.Number, MuTypes.Any),
    (MuTypes.Real, MuTypes.Number),
    (MuTypes.Int, MuTypes.Real),
    (MuTypes.Float, MuTypes.Real),
    (MuTypes.Bool, MuTypes.Number),
    (MuTypes.AbstractString, MuTypes.Any),
    (MuTypes.String, MuTypes.AbstractString),
    (MuTypes.AbstractArray, MuTypes.Any),
    (MuTypes.Array{MuTypes.Int,1}, MuTypes.AbstractArray),
    (MuTypes.Array{MuTypes.Float,1}, MuTypes.AbstractArray),
    (MuTypes.Array{MuTypes.Real,1}, MuTypes.AbstractArray),
    (MuTypes.Bottom, MuTypes.Any),
    (MuTypes.Bottom, MuTypes.Number),
    (MuTypes.Bottom, MuTypes.Int),

    # union type case
    # S \subset T case
    (MuTypes.Union{MuTypes.Int,MuTypes.Float}, MuTypes.Union{MuTypes.Int,MuTypes.Float}),
    (MuTypes.Union{MuTypes.Int,MuTypes.Float}, MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Real}}),
    (MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Real}}, MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Real}}),
    (MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Real}}, MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Union{MuTypes.Real,MuTypes.Bool}}}),

    # Super type case
    (MuTypes.Union{MuTypes.Int,MuTypes.Float}, MuTypes.Number),
    (MuTypes.Union{MuTypes.Int,MuTypes.Float}, MuTypes.Real),
    (MuTypes.Union{MuTypes.Int,MuTypes.Float}, MuTypes.Any),
    (MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Real}}, MuTypes.Number),
    (MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Real}}, MuTypes.Real),
    (MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Real}}, MuTypes.Any),

    # Bottom case
    (MuTypes.Union{MuTypes.Bottom,MuTypes.Bottom}, MuTypes.Bottom),
    (MuTypes.Union{MuTypes.Bottom,MuTypes.Bottom}, MuTypes.Any),
    (MuTypes.Union{MuTypes.Bottom,MuTypes.Bottom}, MuTypes.Number),

    # Union type with Bottom case
    (MuTypes.Union{MuTypes.Int,MuTypes.Bottom}, MuTypes.Int),
    (MuTypes.Union{MuTypes.Number,MuTypes.Bottom}, MuTypes.Number),
    (MuTypes.Union{MuTypes.Real,MuTypes.Bottom}, MuTypes.Any),
]

# !(t1 <: t2) case
const NOT_SUBTYPES = [
    (MuTypes.Any, MuTypes.Number),
    (MuTypes.Number, MuTypes.Real),
    (MuTypes.Real, MuTypes.Int),
    (MuTypes.Real, MuTypes.Float),
    (MuTypes.Number, MuTypes.Bool),
    (MuTypes.Any, MuTypes.AbstractString),
    (MuTypes.AbstractString, MuTypes.String),
    (MuTypes.Any, MuTypes.AbstractArray),
    (MuTypes.AbstractArray, MuTypes.Array{MuTypes.Int,1}),
    (MuTypes.AbstractArray, MuTypes.Array{MuTypes.Float,1}),
    (MuTypes.AbstractArray, MuTypes.Array{MuTypes.Real,1}),
    (MuTypes.Any, MuTypes.Bottom),
    (MuTypes.Number, MuTypes.Bottom),
    (MuTypes.Int, MuTypes.Bottom), (MuTypes.Array{MuTypes.Int,1}, MuTypes.Array{MuTypes.Real,1}),
    (MuTypes.Array{MuTypes.Float,1}, MuTypes.Array{MuTypes.Real,1})
]

@testset "Subtype" begin
    for (t1, t2) in SUBTYPES
        onfail(@test MuTypes.issubtype(t1, t2)) do
            @error "Failed! $t1 must be subtype of $t2. But `MuTypes.issubtype(t1, t2)` returns false or error."
        end
    end
end

@testset "Not subtype" begin
    for (t1, t2) in NOT_SUBTYPES
        onfail(@test !MuTypes.issubtype(t1, t2)) do
            @error "Failed! $t1 must not be subtype of $t2. But `MuTypes.issubtype(t1, t2)` returns true or error."
        end
    end
end


const VALID_TYPES_NONESTED = [
    # name, parameter, expected type
    ((MuAST.Ident("Any"), []), MuTypes.Any),
    ((MuAST.Ident("Number"), []), MuTypes.Number),
    ((MuAST.Ident("Real"), []), MuTypes.Real),
    ((MuAST.Ident("Int"), []), MuTypes.Int),
    ((MuAST.Ident("Float"), []), MuTypes.Float),
    ((MuAST.Ident("Bool"), []), MuTypes.Bool),
    ((MuAST.Ident("AbstractString"), []), MuTypes.AbstractString),
    ((MuAST.Ident("String"), []), MuTypes.String),
    ((MuAST.Ident("AbstractArray"), []), MuTypes.AbstractArray),

    ((MuAST.Ident("Array"), [MuAST.Ident("Int"), 1]), MuTypes.Array{MuTypes.Int,1}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Float"), 1]), MuTypes.Array{MuTypes.Float,1}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Int"), 2]), MuTypes.Array{MuTypes.Int,2}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Float"), 2]), MuTypes.Array{MuTypes.Float,2}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Real"), 1]), MuTypes.Array{MuTypes.Real,1}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Real"), 2]), MuTypes.Array{MuTypes.Real,2}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Any"), 3]), MuTypes.Array{MuTypes.Any,3}),


    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Float")]), MuTypes.Union{MuTypes.Int,MuTypes.Float}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Bottom"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Bottom,MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Bottom"), MuAST.Ident("Number")]), MuTypes.Union{MuTypes.Bottom,MuTypes.Number}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Any"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Any,MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Int,MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Number"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Number,MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Real"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Real,MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Int,MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Int,MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Number"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Number,MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Real"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Real,MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Int,MuTypes.Bottom}),
]

const VALID_TYPES_NESTED = [
    ("Union{Int,Float}", MuTypes.Union{MuTypes.Int,MuTypes.Float}),
    ("Union{Int,Union{Float,Real}}", MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Real}}),
    ("Union{Int,Union{Float,Union{Real,Bool}}}", MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Union{MuTypes.Real,MuTypes.Bool}}}),
    ("Union{Bottom,Bottom}", MuTypes.Union{MuTypes.Bottom,MuTypes.Bottom}),
    ("Union{Bottom,Number}", MuTypes.Union{MuTypes.Bottom,MuTypes.Number}),
    ("Union{Bottom,Union{Bottom,Bottom}}", MuTypes.Union{MuTypes.Bottom,MuTypes.Union{MuTypes.Bottom,MuTypes.Bottom}}),
    ("Union{Any,Bottom}", MuTypes.Union{MuTypes.Any,MuTypes.Bottom}),
    ("Union{Int,Bottom}", MuTypes.Union{MuTypes.Int,MuTypes.Bottom}),
    ("Union{Number,Bottom}", MuTypes.Union{MuTypes.Number,MuTypes.Bottom}),
    ("Union{Real,Bottom}", MuTypes.Union{MuTypes.Real,MuTypes.Bottom}),
    ("Union{Int,Bottom}", MuTypes.Union{MuTypes.Int,MuTypes.Bottom}),
    ("Union{Int,Bottom}", MuTypes.Union{MuTypes.Int,MuTypes.Bottom}),
    ("Union{Number,Bottom}", MuTypes.Union{MuTypes.Number,MuTypes.Bottom}),
    ("Union{Real,Bottom}", MuTypes.Union{MuTypes.Real,MuTypes.Bottom}),
    ("Union{Int,Bottom}", MuTypes.Union{MuTypes.Int,MuTypes.Bottom}),

]


@testset "Type conversion" begin
    @testset "No Nested Case" begin
        for ((name, param), expected) in VALID_TYPES_NONESTED
            type_expr = MuAST.Expr(
                MuAST.TYPE,
                [name, param...]
            )
    
            onfail(@test MuTypes.astype(type_expr) == expected) do
                @error "Failed! `MuTypes.astype(type_expr)` must return $expected. But got $(MuTypes.astype(type_expr))."
            end
        end
    end



    @testset "Nested Case" begin
        for (src, expected) in VALID_TYPES_NESTED
            ast = MuCore.parse(src, rule=MuCore.MuParse.type)
            onfail(@test MuTypes.astype(ast) == expected) do
                @error "Failed! `MuTypes.astype(ast)` must return $expected. But got $(MuTypes.astype(ast))."
            end
        end
    end


end


