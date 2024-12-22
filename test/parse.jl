using .MuCore

parseerror() = iserror(expectederror=Base.Meta.ParseError)

function is_ident(ident::String)
    return (ast) -> (ast == MuCore.MuAST.Ident(ident))
end 

testcases = [
    ("\"hello\"", MuCore.str) => (isequal("hello")),
    ("1", MuCore.int) => (isequal(1)),
    ("10", MuCore.int) => (isequal(10)),
    ("10.0", MuCore.float) => (isequal(10.0)),
    (".0", MuCore.float) => (iserror()),
    ("0.", MuCore.float) => (iserror()),

    ("true", MuCore.bool) => (isequal(true)),
    ("false", MuCore.bool) => (isequal(false)),

    ("123.45", MuCore.num) => (isequal(123.45)),
    ("123", MuCore.num) => (isequal(123)),

    ("abc", MuCore.ident) => (is_ident("abc")),
    ("abc_123", MuCore.ident) => (is_ident("abc_123")),
    ("123abc", MuCore.ident) => (parseerror()),

    ("if", MuCore.ident) => (iserror()),
    ("true", MuCore.ident) => (iserror()),

    ("1.0", MuCore.unary) => (isequal(1.0)),
    ("-1.0", MuCore.unary) => (isequal(MuCore.MuAST.Expr(:call, Any[MuCore.MuAST.Ident("-"), 1.0]))),
    ("-1", MuCore.unary) => (isequal(MuCore.MuAST.Expr(:call, Any[MuCore.MuAST.Ident("-"), 1]))),
    ("1", MuCore.unary) => (isequal(1)),

    ("\"hello\"", MuCore.unary) => (isequal("hello")),
    ("true", MuCore.unary) => (isequal(true)),
    ("false", MuCore.unary) => (isequal(false)),

    ("abc", MuCore.unary) => is_ident("abc"),
    ("abc_123", MuCore.unary) => is_ident("abc_123"),
    ("123abc", MuCore.unary) => (parseerror()),

    ("if", MuCore.unary) => (iserror()),
    ("true", MuCore.unary) => (isequal(true)),

    ("[1, 2, 3]", MuCore.array) => (isequal([1, 2, 3])),
    ("[1, 2, [3, 4]]", MuCore.array) => (isequal([1, 2, [3, 4]])),
    ("[1, 2, 3; 4, 5, 6]", MuCore.matrix) => (isequal([1 2 3; 4 5 6])),
    ("[1, 2, 3; 4, 5, 6, 7]", MuCore.matrix) => (parseerror()),
]


function check(src::String, rule::Function, checker::Function)
    try
        ast = MuCore.parse(src, rule=rule)
        success = checker(ast)

        onfail(@test success) do
            @info "Failed. checker: $checker, got: $ast"
        end
    catch e
        success = checker(e)
        onfail(@test success) do
            @info "Failed. checker: $checker, got error: $e"
        end
    end

end


@testset "parse" begin
    for ((src, rule), checker) in testcases
        check(src, rule, checker)
    end
end