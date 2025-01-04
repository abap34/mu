using mu.MuCore
using mu.MuCore.MuParse
import mu.MuCore.MuAST
using Glob

parseerror() = iserror(expectederror=Base.Meta.ParseError)

function is_ident(ident::String)
    return (ast) -> (ast == MuAST.Ident(ident))
end


testcases = Dict(
    "literal" => [
        #
        # リテラル
        #
        ("\"hello\"", MuParse.str) => (isequal("hello")),
        ("\"foo bar baz\"", MuParse.str) => (isequal("foo bar baz")),
        ("\"\"", MuParse.str) => (isequal("")),
        ("1", MuParse.int) => (isequal(1)),
        ("10", MuParse.int) => (isequal(10)),
        ("0123", MuParse.int) => (parseerror()),
        ("0", MuParse.int) => (isequal(0)),
        ("10.0", MuParse.float) => (isequal(10.0)),
        (".0", MuParse.float) => (iserror()),
        ("0.", MuParse.float) => (iserror()),
        ("1.2.3", MuParse.float) => (iserror()),           # ピリオド2つ
        ("123.", MuParse.float) => (iserror()),
        ("true", MuParse.bool) => (isequal(true)),
        ("false", MuParse.bool) => (isequal(false)),
        ("123.45", MuParse.num) => (isequal(123.45)),
        ("123", MuParse.num) => (isequal(123)),
        ("[1, 2, 3]", MuParse.array) => (isequal([1, 2, 3])),
        ("[1, 2, [3, 4]]", MuParse.array) => (isequal([1, 2, [3, 4]])),
        ("[1, 2, 3; 4, 5, 6]", MuParse.matrix) => (isequal([1 2 3; 4 5 6])),
        ("[1, 2, 3; 4, 5, 6, 7]", MuParse.matrix) => (iserror()), # 2行目の要素数が違う
        ("[]", MuParse.array) => (iserror()),              # 空配列は今回は NG (要素の型指定の構文がないので. 型が定まらない)
        ("[1,]", MuParse.array) => (iserror()),            # カンマ直後に要素なしもパースが面倒なのでなし
        ("[\"abc\"]", MuParse.array) => (isequal(["abc"])),
        ("[true, false]", MuParse.array) => (isequal([true, false])),
        ("[1, 2, 3]", MuParse.array) => (isequal([1, 2, 3]))
    ], "ident" => [
        #
        # 識別子
        #
        ("abc", MuParse.ident) => (is_ident("abc")),
        ("abc_123", MuParse.ident) => (is_ident("abc_123")),
        ("123abc", MuParse.ident) => (parseerror()),
        ("if", MuParse.ident) => (iserror()),       # キーワード
        ("true", MuParse.ident) => (iserror()),     # キーワード
        ("false", MuParse.ident) => (iserror()),    # キーワード
        ("_leading_underscore", MuParse.ident) => is_ident("_leading_underscore"),
        ("if_else", MuParse.ident) => is_ident("if_else"),  # 部分的にキーワード含むがOK
        ("ifelse", MuParse.ident) => is_ident("ifelse"),    # 同上
    ], "unary" => [
        #
        # 単項演算
        #
        ("1.0", MuParse.unary) => (isequal(1.0)),
        ("-1.234", MuParse.unary) => (isequal(MuAST.Expr(MuAST.GCALL, [MuAST.Ident("sub"), 1.234]))),
        ("-1234", MuParse.unary) => (isequal(MuAST.Expr(MuAST.GCALL, [MuAST.Ident("sub"), 1234]))),
        ("1", MuParse.unary) => (isequal(1)),
        ("\"hello\"", MuParse.unary) => (isequal("hello")),
        ("true", MuParse.unary) => (isequal(true)),
        ("false", MuParse.unary) => (isequal(false)),
        ("abc", MuParse.unary) => is_ident("abc"),
        ("abc_123", MuParse.unary) => is_ident("abc_123"),
        ("123abc", MuParse.unary) => (parseerror()),
        ("if", MuParse.unary) => (iserror()),
        ("true", MuParse.unary) => (isequal(true)),
        ("1 + 2", MuParse.add) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("add"), 1, 2])
        )),
        ("-read_as_int()", MuParse.unary) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("sub"), MuAST.Expr(MuAST.GCALL, [MuAST.Ident("read_as_int")])])
        )),
    ], "binop" => [
        #
        # add (連続演算)
        #
        ("1 + 2 + 3", MuParse.add) => begin
            # 1 + 2 + 3 は (1 + 2) + 3 という左結合
            lhs = MuAST.Expr(MuAST.GCALL, [MuAST.Ident("add"), 1, 2])
            rhs = 3
            isequal(MuAST.Expr(MuAST.GCALL, [MuAST.Ident("add"), lhs, rhs]))
        end,
        ("a - b - c", MuParse.add) => begin
            # (a - b) - c
            lhs = MuAST.Expr(MuAST.GCALL, [MuAST.Ident("sub"),
                MuAST.Ident("a"), MuAST.Ident("b")])
            rhs = MuAST.Ident("c")
            isequal(MuAST.Expr(MuAST.GCALL, [MuAST.Ident("sub"), lhs, rhs]))
        end,

        #
        # mul
        #
        ("2 * 3", MuParse.mul) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("mul"), 2, 3])
        )),
        ("a * b / c", MuParse.mul) => begin
            # a * b / c は左結合: (a*b)/c
            lhs = MuAST.Expr(MuAST.GCALL, [
                MuAST.Ident("mul"),
                MuAST.Ident("a"),
                MuAST.Ident("b")
            ])
            rhs = MuAST.Ident("c")
            isequal(MuAST.Expr(MuAST.GCALL, [MuAST.Ident("div"), lhs, rhs]))
        end,

        #
        # relational
        #
        ("1 < 2", MuParse.relational) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("lt"), 1, 2])
        )),
        ("x == y", MuParse.relational) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("eq"),
                MuAST.Ident("x"), MuAST.Ident("y")])
        )),
        ("10 != 20", MuParse.relational) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("neq"), 10, 20])
        )),

        ("double(10) < 20", MuParse.relational) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("lt"),
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("double"), 10]), 20])
        )),
        ("@mul_int_int(2, 3) == 2 * 3", MuParse.relational) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("eq"),
                MuAST.Expr(MuAST.BCALL, [MuAST.Ident("mul_int_int"), 2, 3]),
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("mul"), 2, 3])
            ])
        )),

        #
        # assign
        #
        ("x = 123", MuParse.assign) => (isequal(
            MuAST.Expr(MuAST.ASSIGN, [MuAST.Ident("x"), 123])
        )),
        ("x+1 = y", MuParse.assign) => (parseerror()),
        ("foo_bar = read_as_int()", MuParse.assign) => (isequal(
            MuAST.Expr(MuAST.ASSIGN, [MuAST.Ident("foo_bar"), MuAST.Expr(MuAST.GCALL, [MuAST.Ident("read_as_int")])])
        )), ("(1 + 2) * 3", MuParse.mul) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("mul"),
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("add"), 1, 2]), 3])
        )),
        ("1 + (2 * 3)", MuParse.add) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("add"), 1,
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("mul"), 2, 3])])
        )),
        ("(1 + 2) * (3 + 4)", MuParse.mul) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("mul"),
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("add"), 1, 2]),
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("add"), 3, 4])])
        )),
        ("(1 + 2) * 3", MuParse.mul) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("mul"),
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("add"), 1, 2]), 3])
        )),
        ("1 + (2 * 3)", MuParse.add) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("add"), 1,
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("mul"), 2, 3])])
        ))
    ], "TYPE" => [
        #
        # TYPE
        #
        ("Int", MuParse.type) => (isequal(MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Int")]))),
        ("Array{Int, 2}", MuParse.type) => (isequal(MuAST.Expr(MuAST.TYPE, [
            MuAST.Ident("Array"), MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Int")]), 2
        ]))),
        ("Array{Array{Int, 1}, 2}", MuParse.type) => (isequal(MuAST.Expr(MuAST.TYPE, [
            MuAST.Ident("Array"),
            MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Array"), MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Int")]), 1]), 2
        ]))),
        ("Union{Int, Float}", MuParse.type) => (isequal(MuAST.Expr(MuAST.TYPE, [
            MuAST.Ident("Union"), MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Int")]), MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Float")])
        ]))),
        ("Union{Int, Union{Float, Union{Bool, String}}}", MuParse.type) => (isequal(MuAST.Expr(MuAST.TYPE, [
            MuAST.Ident("Union"), MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Int")]),
            MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Union"),
                MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Float")]),
                MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Union"),
                    MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Bool")]),
                    MuAST.Expr(MuAST.TYPE, [MuAST.Ident("String")])
                ])
            ])
        ]))),
        ("Union{Array{Int, 1}, Array{Int, 2}, Array{Int, 3}}", MuParse.type) => (isequal(MuAST.Expr(MuAST.TYPE, [
            MuAST.Ident("Union"),
            MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Array"), MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Int")]), 1]),
            MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Array"), MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Int")]), 2]),
            MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Array"), MuAST.Expr(MuAST.TYPE, [MuAST.Ident("Int")]), 3])
        ]))),
    ], "GCALL" => [
        #
        # MuAST.GCALL (引数あり・なし)
        #
        ("foo()", MuParse.generics_call) => (isequal(
            # 引数なし
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("foo")])
        )),
        ("bar(1, 2)", MuParse.generics_call) => (isequal(
            MuAST.Expr(MuAST.GCALL, [MuAST.Ident("bar"), 1, 2])
        )),
        ("foo(bar())", MuParse.generics_call) => (isequal(
            MuAST.Expr(MuAST.GCALL, [
                MuAST.Ident("foo"),
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("bar")])
            ])
        ))
    ], "BCALL" => [
        #
        # BCALL (引数あり・なし)
        #
        ("@foo()", MuParse.builtin_call) => (isequal(
            # 引数なし
            MuAST.Expr(MuAST.BCALL, [MuAST.Ident("foo")])
        )),
        ("@bar(1, 2)", MuParse.builtin_call) => (isequal(
            MuAST.Expr(MuAST.BCALL, [MuAST.Ident("bar"), 1, 2])
        )),
        ("@foo(bar())", MuParse.builtin_call) => (isequal(
            MuAST.Expr(MuAST.BCALL, [
                MuAST.Ident("foo"),
                MuAST.Expr(MuAST.GCALL, [MuAST.Ident("bar")])
            ])
        ))
    ], "seq" => [
        #
        # seq (複数 expr)
        #
        ("{ 1 2 3 }", MuParse.seq) => (isequal(
            MuAST.Expr(MuAST.BLOCK, [1, 2, 3])
        )),
        ("{ }", MuParse.seq) => (isequal(
            MuAST.Expr(MuAST.BLOCK, [])
        )),
    ], "if" => [
        #
        # if 文
        #
        ("if(1){2}", MuParse._if) => (isequal(
            MuAST.Expr(MuAST.IF, [
                1,
                MuAST.Expr(MuAST.BLOCK, [2]),
            ])
        )),
        ("if(x){ y=1 } else { y=3 }", MuParse._if) => isequal(
            MuAST.Expr(MuAST.IFELSE, [
                MuAST.Ident("x"),
                MuAST.Expr(MuAST.BLOCK, [
                    MuAST.Expr(MuAST.ASSIGN, [MuAST.Ident("y"), 1])
                ]),
                MuAST.Expr(MuAST.BLOCK, [
                    MuAST.Expr(MuAST.ASSIGN, [MuAST.Ident("y"), 3])
                ])
            ]
            )
        ),
    ], "while" => [

        #
        # while 文
        #
        ("while(x){ x = x - 1 }", MuParse._while) => (isequal(
            MuAST.Expr(MuAST.WHILE, [
                MuAST.Ident("x"),
                MuAST.Expr(MuAST.BLOCK, [
                    MuAST.Expr(MuAST.ASSIGN, [MuAST.Ident("x"), MuAST.Expr(MuAST.GCALL, [MuAST.Ident("sub"), MuAST.Ident("x"), 1])])
                ])
            ])
        )),
        ("{ a=1 b=2 }", MuParse.seq) => (isequal(
            MuAST.Expr(MuAST.BLOCK, [
                MuAST.Expr(MuAST.ASSIGN, [MuAST.Ident("a"), 1]),
                MuAST.Expr(MuAST.ASSIGN, [MuAST.Ident("b"), 2])
            ])
        )),
    ],
)

function check(src::String, rule::Function, checker::Function)
    try
        ast = MuCore.parse(src, rule=rule)
        success = checker(ast)
        onfail(@test success) do
            @info "Failed. src: $src, checker: $checker, got ast: $ast"
            dump(ast)
        end
    catch e
        success = checker(e)
        onfail(@test success) do
            @info "Failed. src: $src checker: $checker, got error: $e"
        end
    end
end


for (testset_name, testcases) in testcases
    @testset "$testset_name" begin
        for ((src, rule), checker) in testcases
            check(src, rule, checker)
        end
    end
end

@testset "Parse parsetest/*.mu" begin
    for file in Glob.glob("parsetest/*.mu")
        @info "Parsing: $file"
        src = read(file, String)
        try
            ast = MuCore.parse(src)
            @test true
        catch e
            @info "Failed to parse: $file"
            @test false
        end
    end
end


