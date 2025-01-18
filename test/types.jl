using mu.MuCore
using mu.MuCore.MuTypes
using mu.MuCore.MuAST


const TARGET_TYPES = [
    MuTypes.Any,
    MuTypes.Number,
    MuTypes.Real,
    MuTypes.Int,
    MuTypes.Float,
    MuTypes.Bool,
    MuTypes.AbstractString,
    MuTypes.String,
    MuTypes.AbstractArray,
    MuTypes.Array{MuTypes.Int, 1},
    MuTypes.Array{MuTypes.Float, 1},
    MuTypes.Array{MuTypes.Int, 2},
    MuTypes.Array{MuTypes.Float, 2},
    MuTypes.Array{MuTypes.Real, 1},
    MuTypes.Array{MuTypes.Real, 2},
    MuTypes.Array{MuTypes.Any, 3},
    MuTypes.Union{MuTypes.Int, MuTypes.Float},
    MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}},
    MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Union{MuTypes.Real, MuTypes.Bool}}},
    MuTypes.Union{MuTypes.Bottom, MuTypes.Bottom},
    MuTypes.Union{MuTypes.Bottom, MuTypes.Number},
    MuTypes.Union{MuTypes.Bottom, MuTypes.Union{MuTypes.Bottom, MuTypes.Bottom}},
    MuTypes.Union{MuTypes.Any, MuTypes.Bottom},
    MuTypes.Bottom,
]

const TARGET_CONCREATE_TYPES =
    [MuTypes.Int, MuTypes.Float, MuTypes.Bool, MuTypes.String, MuTypes.Array{MuTypes.Int, 1}, MuTypes.Array{MuTypes.Float, 1}, MuTypes.Array{MuTypes.Int, 2}, MuTypes.Array{MuTypes.Float, 2}, MuTypes.Array{MuTypes.Real, 1}, MuTypes.Array{MuTypes.Real, 2}, MuTypes.Array{MuTypes.Any, 3}]


@testset "Concreate check" begin
    for t in TARGET_CONCREATE_TYPES
        onfail(@test MuTypes.isconcrete(t)) do
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
    (MuTypes.Array{MuTypes.Int, 1}, MuTypes.Array{MuTypes.Int, 1}),

    # simply subtype case
    (MuTypes.Number, MuTypes.Any),
    (MuTypes.Real, MuTypes.Number),
    (MuTypes.Int, MuTypes.Real),
    (MuTypes.Float, MuTypes.Real),
    (MuTypes.Bool, MuTypes.Number),
    (MuTypes.AbstractString, MuTypes.Any),
    (MuTypes.String, MuTypes.AbstractString),
    (MuTypes.AbstractArray, MuTypes.Any),
    (MuTypes.Array{MuTypes.Int, 1}, MuTypes.AbstractArray),
    (MuTypes.Array{MuTypes.Float, 1}, MuTypes.AbstractArray),
    (MuTypes.Array{MuTypes.Real, 1}, MuTypes.AbstractArray),
    (MuTypes.Bottom, MuTypes.Any),
    (MuTypes.Bottom, MuTypes.Number),
    (MuTypes.Bottom, MuTypes.Int),

    # union type case
    # S \subset T case
    (MuTypes.Union{MuTypes.Int, MuTypes.Float}, MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    (MuTypes.Union{MuTypes.Int, MuTypes.Float}, MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}),
    (MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}, MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}),
    (MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}, MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Union{MuTypes.Real, MuTypes.Bool}}}),

    # right side is union type
    (MuTypes.Int, MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    (MuTypes.Real, MuTypes.Union{MuTypes.Int, MuTypes.Real}),
    (MuTypes.Real, MuTypes.Union{MuTypes.Int, MuTypes.Real}),
    (MuTypes.Int, MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    (MuTypes.Float, MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    (MuTypes.Float, MuTypes.Union{MuTypes.Real, MuTypes.Float}),

    # Super type case
    (MuTypes.Union{MuTypes.Int, MuTypes.Float}, MuTypes.Number),
    (MuTypes.Union{MuTypes.Int, MuTypes.Float}, MuTypes.Real),
    (MuTypes.Union{MuTypes.Int, MuTypes.Float}, MuTypes.Any),
    (MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}, MuTypes.Number),
    (MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}, MuTypes.Real),
    (MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}, MuTypes.Any),

    # Bottom case
    (MuTypes.Union{MuTypes.Bottom, MuTypes.Bottom}, MuTypes.Bottom),
    (MuTypes.Union{MuTypes.Bottom, MuTypes.Bottom}, MuTypes.Any),
    (MuTypes.Union{MuTypes.Bottom, MuTypes.Bottom}, MuTypes.Number),

    # Union type with Bottom case
    (MuTypes.Union{MuTypes.Int, MuTypes.Bottom}, MuTypes.Int),
    (MuTypes.Union{MuTypes.Number, MuTypes.Bottom}, MuTypes.Number),
    (MuTypes.Union{MuTypes.Real, MuTypes.Bottom}, MuTypes.Any),
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
    (MuTypes.AbstractArray, MuTypes.Array{MuTypes.Int, 1}),
    (MuTypes.AbstractArray, MuTypes.Array{MuTypes.Float, 1}),
    (MuTypes.AbstractArray, MuTypes.Array{MuTypes.Real, 1}),
    (MuTypes.Any, MuTypes.Bottom),
    (MuTypes.Number, MuTypes.Bottom),
    (MuTypes.Int, MuTypes.Bottom),
    (MuTypes.Array{MuTypes.Int, 1}, MuTypes.Array{MuTypes.Real, 1}),
    (MuTypes.Array{MuTypes.Float, 1}, MuTypes.Array{MuTypes.Real, 1}),
    (MuTypes.Number, MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    (MuTypes.Any, MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    (MuTypes.Any, MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}),
    (MuTypes.AbstractString, MuTypes.Union{MuTypes.Int, MuTypes.Float}),
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
    ((MuAST.Ident("Array"), [MuAST.Ident("Int"), 1]), MuTypes.Array{MuTypes.Int, 1}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Float"), 1]), MuTypes.Array{MuTypes.Float, 1}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Int"), 2]), MuTypes.Array{MuTypes.Int, 2}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Float"), 2]), MuTypes.Array{MuTypes.Float, 2}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Real"), 1]), MuTypes.Array{MuTypes.Real, 1}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Real"), 2]), MuTypes.Array{MuTypes.Real, 2}),
    ((MuAST.Ident("Array"), [MuAST.Ident("Any"), 3]), MuTypes.Array{MuTypes.Any, 3}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Float")]), MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Bottom"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Bottom, MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Bottom"), MuAST.Ident("Number")]), MuTypes.Union{MuTypes.Bottom, MuTypes.Number}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Any"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Any, MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Int, MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Number"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Number, MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Real"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Real, MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Int, MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Int, MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Number"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Number, MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Real"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Real, MuTypes.Bottom}),
    ((MuAST.Ident("Union"), [MuAST.Ident("Int"), MuAST.Ident("Bottom")]), MuTypes.Union{MuTypes.Int, MuTypes.Bottom}),
]

const VALID_TYPES_NESTED = [
    ("Union{Int,Float}", MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    ("Union{Int,Union{Float,Real}}", MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}),
    ("Union{Int,Union{Float,Union{Real,Bool}}}", MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Union{MuTypes.Real, MuTypes.Bool}}}),
    ("Union{Bottom,Bottom}", MuTypes.Union{MuTypes.Bottom, MuTypes.Bottom}),
    ("Union{Bottom,Number}", MuTypes.Union{MuTypes.Bottom, MuTypes.Number}),
    ("Union{Bottom,Union{Bottom,Bottom}}", MuTypes.Union{MuTypes.Bottom, MuTypes.Union{MuTypes.Bottom, MuTypes.Bottom}}),
    ("Union{Any,Bottom}", MuTypes.Union{MuTypes.Any, MuTypes.Bottom}),
    ("Union{Int,Bottom}", MuTypes.Union{MuTypes.Int, MuTypes.Bottom}),
    ("Union{Number,Bottom}", MuTypes.Union{MuTypes.Number, MuTypes.Bottom}),
    ("Union{Real,Bottom}", MuTypes.Union{MuTypes.Real, MuTypes.Bottom}),
    ("Union{Int,Bottom}", MuTypes.Union{MuTypes.Int, MuTypes.Bottom}),
    ("Union{Int,Bottom}", MuTypes.Union{MuTypes.Int, MuTypes.Bottom}),
    ("Union{Number,Bottom}", MuTypes.Union{MuTypes.Number, MuTypes.Bottom}),
    ("Union{Real,Bottom}", MuTypes.Union{MuTypes.Real, MuTypes.Bottom}),
    ("Union{Int,Bottom}", MuTypes.Union{MuTypes.Int, MuTypes.Bottom}),
]


@testset "Type conversion" begin
    @testset "No Nested Case" begin
        for ((name, param), expected) in VALID_TYPES_NONESTED
            type_expr = MuAST.Expr(MuAST.TYPE, [name, param...])

            onfail(@test MuTypes.expr_to_type(type_expr) == expected) do
                @error "Failed! `MuTypes.expr_to_type(type_expr)` must return $expected. But got $(MuTypes.expr_to_type(type_expr))."
            end
        end
    end



    @testset "Nested Case" begin
        for (src, expected) in VALID_TYPES_NESTED
            ast = MuCore.parse(src, rule=MuCore.MuParse.type)
            onfail(@test MuTypes.expr_to_type(ast) == expected) do
                @error "Failed! `MuTypes.expr_to_type(ast)` must return $expected. But got $(MuTypes.expr_to_type(ast))."
            end
        end
    end


end

# Tuple and union types test

# Normalize tests
const NORMALIZE_TESTCASES = [
    # Already normalized
    (MuTypes.Int, MuTypes.Int),
    (MuTypes.Union{MuTypes.Int, MuTypes.Float}, MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    
    # Simple normalization
    (MuTypes.Tuple{MuTypes.Union{MuTypes.Int, MuTypes.Float}, MuTypes.Real}, 
     MuTypes.Union{MuTypes.Tuple{MuTypes.Int, MuTypes.Real}, MuTypes.Tuple{MuTypes.Float, MuTypes.Real}}),
    # Nested unions
    (
        MuTypes.Tuple{MuTypes.Union{MuTypes.Int, MuTypes.Union{MuTypes.Float, MuTypes.Real}}, MuTypes.Real},
        MuTypes.Union{MuTypes.Tuple{MuTypes.Int, MuTypes.Real}, MuTypes.Union{MuTypes.Tuple{MuTypes.Float, MuTypes.Real}, MuTypes.Tuple{MuTypes.Real, MuTypes.Real}}}
    ),
]

@info "Normalization test"

@testset "Normalization" begin
    for (input_type, expected_type) in NORMALIZE_TESTCASES
        onfail(@test MuTypes.normalize(input_type) == expected_type) do
            @error "Failed! `MuTypes.normalize($(MuTypes.shorten_str(input_type)))` must return $(MuTypes.shorten_str(expected_type)). But got $(MuTypes.shorten_str(MuTypes.normalize(input_type)))."
        end
    end
end

const SUBTYPE_NORMALIZED_TESTCASES = [
    # Union subtyping
    (MuTypes.Union{MuTypes.Int, MuTypes.Float}, MuTypes.Number, true),
    (MuTypes.Number, MuTypes.Union{MuTypes.Int, MuTypes.Float}, false),
    # Tuple subtyping
    (MuTypes.Tuple{MuTypes.Int, MuTypes.Float}, MuTypes.Tuple{MuTypes.Number, MuTypes.Number}, true),
    (MuTypes.Tuple{MuTypes.Int, MuTypes.Float}, MuTypes.Tuple{MuTypes.Int, MuTypes.Float}, true),
    (MuTypes.Tuple{MuTypes.Int, MuTypes.Int},   MuTypes.Tuple{MuTypes.Int, MuTypes.Float}, false),
    (MuTypes.Tuple{MuTypes.Int, MuTypes.Tuple{MuTypes.Int, MuTypes.Float}}, MuTypes.Tuple{MuTypes.Int, MuTypes.Tuple{MuTypes.Int, MuTypes.Float}}, true),
    (MuTypes.Tuple{MuTypes.Int, MuTypes.Tuple{MuTypes.Int, MuTypes.Tuple{MuTypes.Int, MuTypes.Int}}}, MuTypes.Tuple{MuTypes.Int, MuTypes.Tuple{MuTypes.Int, MuTypes.Int}}, false),
    # Mixed cases
    (MuTypes.Tuple{MuTypes.Union{MuTypes.Int, MuTypes.Float}, MuTypes.Union{MuTypes.Float, MuTypes.Bool}}, MuTypes.Tuple{MuTypes.Real, MuTypes.Number}, true),
]


@testset "Subtype checks with normalized inputs" begin
    for (t1, t2, expected) in SUBTYPE_NORMALIZED_TESTCASES
        onfail(@test MuTypes.issubtype(t1, t2) == expected) do
            @error "Failed! `MuTypes.issubtype($(MuTypes.shorten_str(t1)), $(MuTypes.shorten_str(t2)))` must return $expected. But got $(MuTypes.issubtype(t1, t2))."
        end
    end
end

# jointype, meettype test
const JOINTYPE_TESTCASES = [
    ((MuTypes.Int, MuTypes.Float), MuTypes.Union{MuTypes.Int, MuTypes.Float}),
    ((MuTypes.Int, MuTypes.Int), MuTypes.Int),
    ((MuTypes.Int, MuTypes.Real), MuTypes.Real),
    ((MuTypes.Int, MuTypes.Number), MuTypes.Number),
    ((MuTypes.Int, MuTypes.Any), MuTypes.Any),
    ((MuTypes.Int, MuTypes.Bottom), MuTypes.Int),
    ((MuTypes.Bottom, MuTypes.Int), MuTypes.Int),
    ((MuTypes.Bottom, MuTypes.Bottom), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Any), MuTypes.Any),
    ((MuTypes.Bottom, MuTypes.Number), MuTypes.Number),
    ((MuTypes.Bottom, MuTypes.Real), MuTypes.Real),
    ((MuTypes.Bottom, MuTypes.Float), MuTypes.Float),
    ((MuTypes.Bottom, MuTypes.Int), MuTypes.Int),
    ((MuTypes.Bottom, MuTypes.Float), MuTypes.Float),
    ((MuTypes.Bottom, MuTypes.Real), MuTypes.Real),
    ((MuTypes.Bottom, MuTypes.Number), MuTypes.Number),
    ((MuTypes.Bottom, MuTypes.Any), MuTypes.Any),
    ((MuTypes.Any, MuTypes.Bottom), MuTypes.Any),
    ((MuTypes.Any, MuTypes.Number), MuTypes.Any),
    ((MuTypes.Any, MuTypes.Real), MuTypes.Any),
    ((MuTypes.Any, MuTypes.Float), MuTypes.Any),
    ((MuTypes.Any, MuTypes.Int), MuTypes.Any),
    ((MuTypes.Any, MuTypes.Float), MuTypes.Any),
    ((MuTypes.Any, MuTypes.Real), MuTypes.Any),
    ((MuTypes.Any, MuTypes.Number), MuTypes.Any),
    ((MuTypes.Any, MuTypes.Any), MuTypes.Any),
    ((MuTypes.Number, MuTypes.Number), MuTypes.Number),
    ((MuTypes.Number, MuTypes.Real), MuTypes.Number),
    ((MuTypes.Number, MuTypes.Float), MuTypes.Number),
    ((MuTypes.Number, MuTypes.Int), MuTypes.Number),
    ((MuTypes.Real, MuTypes.Real), MuTypes.Real),
    ((MuTypes.Real, MuTypes.Float), MuTypes.Real),
    ((MuTypes.Real, MuTypes.Int), MuTypes.Real),
]

const MEETTYPE_TESTCASES = [
    ((MuTypes.Int, MuTypes.Float), MuTypes.Bottom),
    ((MuTypes.Int, MuTypes.Int), MuTypes.Int),
    ((MuTypes.Int, MuTypes.Real), MuTypes.Int),
    ((MuTypes.Int, MuTypes.Number), MuTypes.Int),
    ((MuTypes.Int, MuTypes.Any), MuTypes.Int),
    ((MuTypes.Int, MuTypes.Bottom), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Int), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Bottom), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Any), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Number), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Real), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Float), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Int), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Float), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Real), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Number), MuTypes.Bottom),
    ((MuTypes.Bottom, MuTypes.Any), MuTypes.Bottom),
    ((MuTypes.Any, MuTypes.Bottom), MuTypes.Bottom),
    ((MuTypes.Any, MuTypes.Number), MuTypes.Number),
    ((MuTypes.Any, MuTypes.Real), MuTypes.Real),
    ((MuTypes.Any, MuTypes.Float), MuTypes.Float),
    ((MuTypes.Any, MuTypes.Int), MuTypes.Int),
    ((MuTypes.Any, MuTypes.Float), MuTypes.Float),
    ((MuTypes.Any, MuTypes.Real), MuTypes.Real),
    ((MuTypes.Any, MuTypes.Number), MuTypes.Number),
    ((MuTypes.Any, MuTypes.Any), MuTypes.Any),
    ((MuTypes.Number, MuTypes.Number), MuTypes.Number),
    ((MuTypes.Number, MuTypes.Real), MuTypes.Real),
    ((MuTypes.Number, MuTypes.Float), MuTypes.Float),
    ((MuTypes.Number, MuTypes.Int), MuTypes.Int),
    ((MuTypes.Real, MuTypes.Real), MuTypes.Real),
    ((MuTypes.Real, MuTypes.Float), MuTypes.Float),
    ((MuTypes.Real, MuTypes.Int), MuTypes.Int),
    ((MuTypes.Bool, MuTypes.Bool), MuTypes.Bool),
    ((MuTypes.String, MuTypes.String), MuTypes.String),
    ((MuTypes.AbstractString, MuTypes.String), MuTypes.String),
]

@testset "meettype, jointype" begin
    @testset "Jointype" begin
        for ((t1, t2), expected) in JOINTYPE_TESTCASES
            onfail(@test MuTypes.jointype(t1, t2) == expected) do
                @error "Failed! `MuTypes.jointype($t1, $t2)` must return $expected. But got $(MuTypes.jointype(t1, t2))."
            end
        end
    end

    @testset "Meettype" begin
        for ((t1, t2), expected) in MEETTYPE_TESTCASES
            onfail(@test MuTypes.meettype(t1, t2) == expected) do
                @error "Failed! `MuTypes.meettype($t1, $t2)` must return $expected. But got $(MuTypes.meettype(t1, t2))."
            end
        end
    end
end





