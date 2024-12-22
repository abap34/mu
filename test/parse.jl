using mu.MuCore
using mu.MuCore.MuAST: ASSIGN, BLOCK, CALL, IF, IFELSE, WHILE

parseerror() = iserror(expectederror=Base.Meta.ParseError)

function is_ident(ident::String)
    return (ast) -> (ast == MuCore.MuAST.Ident(ident))
end


testcases = Dict(
    "literal" => [
        #
        # リテラル
        #
        ("\"hello\"", MuCore.str) => (isequal("hello")),
        ("\"foo bar baz\"", MuCore.str) => (isequal("foo bar baz")),
        ("\"\"", MuCore.str) => (isequal("")),
        ("1", MuCore.int) => (isequal(1)),
        ("10", MuCore.int) => (isequal(10)),
        ("0123", MuCore.int) => (parseerror()),
        ("0", MuCore.int) => (isequal(0)),
        ("10.0", MuCore.float) => (isequal(10.0)),
        (".0", MuCore.float) => (iserror()),
        ("0.", MuCore.float) => (iserror()),
        ("1.2.3", MuCore.float) => (iserror()),           # ピリオド2つ
        ("123.", MuCore.float) => (iserror()),
        ("true", MuCore.bool) => (isequal(true)),
        ("false", MuCore.bool) => (isequal(false)),
        ("123.45", MuCore.num) => (isequal(123.45)),
        ("123", MuCore.num) => (isequal(123)),
        ("[1, 2, 3]", MuCore.array) => (isequal([1, 2, 3])),
        ("[1, 2, [3, 4]]", MuCore.array) => (isequal([1, 2, [3, 4]])),
        ("[1, 2, 3; 4, 5, 6]", MuCore.matrix) => (isequal([1 2 3; 4 5 6])),
        ("[1, 2, 3; 4, 5, 6, 7]", MuCore.matrix) => (iserror()), # 2行目の要素数が違う
        ("[]", MuCore.array) => (iserror()),              # 空配列は今回は NG (要素の型指定の構文がないので. 型が定まらない)
        ("[1,]", MuCore.array) => (iserror()),            # カンマ直後に要素なしもパースが面倒なのでなし
        ("[\"abc\"]", MuCore.array) => (isequal(["abc"])),
        ("[true, false]", MuCore.array) => (isequal([true, false])),
        ("[1, 2, 3]", MuCore.array) => (isequal([1, 2, 3]))
    ], 
    
    "ident" => [
        #
        # 識別子
        #
        ("abc", MuCore.ident) => (is_ident("abc")),
        ("abc_123", MuCore.ident) => (is_ident("abc_123")),
        ("123abc", MuCore.ident) => (parseerror()),
        ("if", MuCore.ident) => (iserror()),       # キーワード
        ("true", MuCore.ident) => (iserror()),     # キーワード
        ("false", MuCore.ident) => (iserror()),    # キーワード
        ("_leading_underscore", MuCore.ident) => is_ident("_leading_underscore"),
        ("if_else", MuCore.ident) => is_ident("if_else"),  # 部分的にキーワード含むがOK
        ("ifelse", MuCore.ident) => is_ident("ifelse"),    # 同上
    ], 
    
    "unary" => [
        #
        # 単項演算
        #
        ("1.0", MuCore.unary) => (isequal(1.0)),
        ("-1.234", MuCore.unary) => (isequal(MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("sub"), 1.234]))),
        ("-1234", MuCore.unary) => (isequal(MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("sub"), 1234]))),
        ("1", MuCore.unary) => (isequal(1)),
        ("\"hello\"", MuCore.unary) => (isequal("hello")),
        ("true", MuCore.unary) => (isequal(true)),
        ("false", MuCore.unary) => (isequal(false)),
        ("abc", MuCore.unary) => is_ident("abc"),
        ("abc_123", MuCore.unary) => is_ident("abc_123"),
        ("123abc", MuCore.unary) => (parseerror()),
        ("if", MuCore.unary) => (iserror()),
        ("true", MuCore.unary) => (isequal(true)),
        ("1 + 2", MuCore.add) => (isequal(
            MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("add"), 1, 2])
        )),
        ("-read_as_int()", MuCore.unary) => (isequal(
            MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("sub"), MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("read_as_int")])])
        )),
    ], 
    
    "binop" => [
        #
        # add (連続演算)
        #
        ("1 + 2 + 3", MuCore.add) => begin
            # 1 + 2 + 3 は (1 + 2) + 3 という左結合
            lhs = MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("add"), 1, 2])
            rhs = 3
            isequal(MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("add"), lhs, rhs]))
        end,
        ("a - b - c", MuCore.add) => begin
            # (a - b) - c
            lhs = MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("sub"),
                MuCore.MuAST.Ident("a"), MuCore.MuAST.Ident("b")])
            rhs = MuCore.MuAST.Ident("c")
            isequal(MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("sub"), lhs, rhs]))
        end,

        #
        # mul
        #
        ("2 * 3", MuCore.mul) => (isequal(
            MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("mul"), 2, 3])
        )),
        ("a * b / c", MuCore.mul) => begin
            # a * b / c は左結合: (a*b)/c
            lhs = MuCore.MuAST.Expr(CALL, [
                MuCore.MuAST.Ident("mul"),
                MuCore.MuAST.Ident("a"),
                MuCore.MuAST.Ident("b")
            ])
            rhs = MuCore.MuAST.Ident("c")
            isequal(MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("div"), lhs, rhs]))
        end,

        #
        # relational
        #
        ("1 < 2", MuCore.relational) => (isequal(
            MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("lt"), 1, 2])
        )),
        ("x == y", MuCore.relational) => (isequal(
            MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("eq"),
                MuCore.MuAST.Ident("x"), MuCore.MuAST.Ident("y")])
        )),
        ("10 != 20", MuCore.relational) => (isequal(
            MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("neq"), 10, 20])
        )),

        #
        # assign
        #
        ("x = 123", MuCore.assign) => (isequal(
            MuCore.MuAST.Expr(ASSIGN, [MuCore.MuAST.Ident("x"), 123])
        )),
        ("x+1 = y", MuCore.assign) => (parseerror()),
        ("foo_bar = read_as_int()", MuCore.assign) => (isequal(
            MuCore.MuAST.Expr(ASSIGN, [MuCore.MuAST.Ident("foo_bar"), MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("read_as_int")])])
        )),
    ], 
    
    "call" => [
        #
        # call (引数あり・なし)
        #
        ("foo()", MuCore.call) => (isequal(
            # 引数なし
            MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("foo")])
        )),
        ("bar(1, 2)", MuCore.call) => (isequal(
            MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("bar"), 1, 2])
        )),
        ("foo(bar())", MuCore.call) => (isequal(
            MuCore.MuAST.Expr(CALL, [
                MuCore.MuAST.Ident("foo"),
                MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("bar")])
            ])
        ))
    ], 
    
    "seq" => [
        #
        # seq (複数 expr)
        #
        ("{ 1 2 3 }", MuCore.seq) => (isequal(
            MuCore.MuAST.Expr(BLOCK, [1, 2, 3])
        )),
        ("{ }", MuCore.seq) => (isequal(
            MuCore.MuAST.Expr(BLOCK, [])
        )),], "if" => [
        #
        # if 文
        #
        ("if(1){2}", MuCore._if) => (isequal(
            MuCore.MuAST.Expr(IF, [
                1,
                MuCore.MuAST.Expr(BLOCK, [2]),
            ])
        )),
        ("if(x){ y=1 } else { y=3 }", MuCore._if) => isequal(
            MuCore.MuAST.Expr(IFELSE, [
                MuCore.MuAST.Ident("x"),
                MuCore.MuAST.Expr(BLOCK, [
                    MuCore.MuAST.Expr(ASSIGN, [MuCore.MuAST.Ident("y"), 1])
                ]),
                MuCore.MuAST.Expr(BLOCK, [
                    MuCore.MuAST.Expr(ASSIGN, [MuCore.MuAST.Ident("y"), 3])
                ])
            ]
            )
        ),
    ], 
    
    "while"=> [

        #
        # while 文
        #
        ("while(x){ x = x - 1 }", MuCore._while) => (isequal(
            MuCore.MuAST.Expr(WHILE, [
                MuCore.MuAST.Ident("x"),
                MuCore.MuAST.Expr(BLOCK, [
                    MuCore.MuAST.Expr(ASSIGN, [MuCore.MuAST.Ident("x"), MuCore.MuAST.Expr(CALL, [MuCore.MuAST.Ident("sub"), MuCore.MuAST.Ident("x"), 1])])
                ])
            ])
        )),
        ("{ a=1 b=2 }", MuCore.seq) => (isequal(
            MuCore.MuAST.Expr(BLOCK, [
                MuCore.MuAST.Expr(ASSIGN, [MuCore.MuAST.Ident("a"), 1]),
                MuCore.MuAST.Expr(ASSIGN, [MuCore.MuAST.Ident("b"), 2])
            ])
        )),
    ], 
    
    "program" => [

        #
        # program (ソース全体). 例として少し複雑なサンプル
        #
        (
            """
            x = read_as_int()
            y = x + 10

            a = [1, 2, 3]
            b = [4, 5, 6]

            c = stack(a, b)

            print(c)


            if (x == 34){ 
                print("Bonus!")
                z = z + 3.4
            } else { 
                print("Penalty!")
                z = z - 34
            }


            while (y > 0){
                y = y - read_as_int()
                
                if (y % 2 == 0){
                    x = x / 2
                } else {
                    x = x + 1
                }
            }

            """,
            MuCore.program
        ) =>
            begin
                # 一旦パースエラーにならないことだけをチェック
                ast -> !isa(ast, Exception)
            end,
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

@testset "parse" begin
    for (testset_name, testcases) in testcases
        @testset "$testset_name" begin
            for ((src, rule), checker) in testcases
                check(src, rule, checker)
            end
        end
    end
end