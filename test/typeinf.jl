using mu.MuCore
using mu.MuBase

using mu.MuCore.MuTypes
using mu.MuCore.MuTypeInf

SIMPLE_LITERAL = [
    (
        """
        function f(){
            return 1
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            return 1.0
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            return true
        }
        """,
        MuTypes.Bool,
    ),
    (
        """
        function f(){
            return \"hello\"
        }
        """,
        MuTypes.String,
    ),
    (
        """
        function f(){
            return [1, 2, 3]
        }
        """,
        MuTypes.Array{MuTypes.Int,1},
    ),
    (
        """
        function f(){
            return [1.0, 2.0, 3.0]
        }
        """,
        MuTypes.Array{MuTypes.Float,1},
    ),
    (
        """
        function f(){
            return [true, false, true]
        }
        """,
        MuTypes.Array{MuTypes.Bool,1},
    ),
    (
        """
        function f(){
            return ["hello", "world"]
        }
        """,
        MuTypes.Array{MuTypes.String,1},
    ),
    (
        """
        function f(){
            return [1, 2, 3; 4, 5, 6]
        }
        """,
        MuTypes.Array{MuTypes.Int,2},
    ),
]


SIMPLE_ONE_FUNC = [
    (
        """
        function f(){
            return 1 + 2
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            return 1.0 + 2.0
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            return 1 - 2
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            return 1.0 - 2.0
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            return 1 * 2
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            return 1.0 * 2.0
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            return 4 / 2
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            return 1 == 2
        }
        """,
        MuTypes.Bool,
    ),
    (
        """
        function f(){
            return @expanddims([1, 2, 3])
        }
        """,
        MuTypes.Array{MuTypes.Int,2},
    ),
    (
        """
        function f(){
            return @sum([1, 2, 3], 1)
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            return @sum([1.0, 2.0, 3.0], 1)
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            return @sum([1, 2, 3; 4, 5, 6], 2)
        }
        """,
        MuTypes.Array{MuTypes.Int,1},
    ),
    (
        """
        function f(){
            return @sum([1.0, 2.0, 3.0; 4.0, 5.0, 6.0], 2)
        }
        """,
        MuTypes.Array{MuTypes.Float,1},
    ),
    (
        """
        function f(){
            return @expanddims([1, 2, 3])
        }
        """,
        MuTypes.Array{MuTypes.Int,2},
    ),
    (
        """
        function f(){
            return @get([1, 2, 3], 1)
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            return @set([1.2, 2.3, 3.4], 1, 1)
        }
        """,
        MuTypes.Int,
    ),
]

SIMPLE_SOME_FUNC = [
    (
        """
        function f(){
            return 1 + 2 * 3
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            return 1.0 + 2.0 * 3.0
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            return 1 - 2 * 3
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            return 1.0 - 2.0 * 3.0
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            return 4 / 2 * 3
        }
        """,
        MuTypes.Float,
    )
]

SIMPLE_SOMEEXPR = [
    (
        """
        function f(){
            y = 1
            return y + 2
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            y = 1.0
            return y + 2.0
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            y = 1
            return y - 2
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            y = 1.0
            return y - 2.0
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            y = 4
            return y / 2
        }
        """,
        MuTypes.Float,
    )
]

IF_ELSE_SAME_TYPE = [
    (
        """
        function f(){
            if (true){
                return 1
            } else {
                return 2
            }
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            if (true){
                return 1.0
            } else {
                return 2.0
            }
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            if (true){
                return true
            } else {
                return false
            }
        }
        """,
        MuTypes.Bool,
    ),
    (
        """
        function f(){
            if (true){
                return \"hello\"
            } else {
                return \"world\"
            }
        }
        """,
        MuTypes.String,
    ),
    (
        """
        function f(){
            if (true){
                return [1, 2, 3]
            } else {
                return [4, 5, 6]
            }
        }
        """,
        MuTypes.Array{MuTypes.Int,1},
    ),
    (
        """
        function f(){
            if (true){
                return [1, 2, 3; 4, 5, 6]
            } else {
                return [7, 8, 9; 10, 11, 12]
            }
        }
        """,
        MuTypes.Array{MuTypes.Int,2},
    ),
]

IF_ELSE_DIFF_TYPE = [
    (
        """
        function f(){
            if (true){
                return 1
            } else {
                return 1.0
            }
        }
        """,
        MuTypes.Union{MuTypes.Int,MuTypes.Float},
    ),
    (
        """
        function f(){
            if (true){
                return 1.0
            } else {
                return 1
            }
        }
        """,
        MuTypes.Union{MuTypes.Int,MuTypes.Float},
    ),
    (
        """
        function f(){
            if (true){
                return true
            } else {
                return 1
            }
        }
        """,
        MuTypes.Union{MuTypes.Bool,MuTypes.Int},
    ),
    (
        """
        function f(){
            if (true){
                return \"hello\"
            } else {
                return 1
            }
        }
        """,
        MuTypes.Union{MuTypes.String,MuTypes.Int},
    ),
    (
        """
        function f(){
            if (true){
                return [1, 2, 3]
            } else {
                return 1
            }
        }
        """,
        MuTypes.Union{MuTypes.Array{MuTypes.Int,1},MuTypes.Int},
    ),
    (
        """
        function f(){
            if (true){
                return [1, 2, 3; 4, 5, 6]
            } else {
                return 1
            }
        }
        """,
        MuTypes.Union{MuTypes.Array{MuTypes.Int,2},MuTypes.Int},
    ),
]

IF_ELSE_NESTED_SAME_TYPE = [
    (
        """
        function f(){
            if (true){
                if (true){
                    return 1
                } else {
                    return 2
                }
            } else {
                return 3
            }
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            if (true){
                if (true){
                    return 1.0
                } else {
                    return 2.0
                }
            } else {
                return 3.0
            }
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            if (true){
                if (true){
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        }
        """,
        MuTypes.Bool,
    ),
    (
        """
        function f(){
            if (true){
                if (true){
                    return \"hello\"
                } else {
                    return \"world\"
                }
            } else {
                return \"hello\"
            }
        }
        """,
        MuTypes.String,
    )]


IF_ELSE_NESTED_DIFF_TYPE = [
    (
        """
        function f(){
            if (true){
                if (true){
                    return 1
                } else {
                    return 1.0
                }
            } else {
                return 1
            }
        }
        """,
        MuTypes.Union{MuTypes.Int,MuTypes.Float},
    ),
    (
        """
        function f(){
            if (true){
                if (true){
                    return 1.0
                } else {
                    return 1
                }
            } else {
                return 1.0
            }
        }
        """,
        MuTypes.Union{MuTypes.Int,MuTypes.Float},
    ),
    (
        """
        function f(){
            if (true){
                if (true){
                    return true
                } else {
                    return 1
                }
            } else {
                return true
            }
        }
        """,
        MuTypes.Union{MuTypes.Bool,MuTypes.Int},
    ),
    (
        """
        function f(){
            if (true){
                if (true){
                    return \"hello\"
                } else {
                    return 1
                }
            } else {
                return \"hello\"
            }
        }
        """,
        MuTypes.Union{MuTypes.String,MuTypes.Int},
    ),
    (
        """
        function f(){
            if (true){
                if (true){
                    return 1
                    } else {
                        return 1.0
                    }
                } else {
                    return "hello"
                }
            }
            """,
        MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.String}},
    ),
    ("""
       function f(){
           if (true){
               if (true){
                   if (true){
                       return 1
                   } else {
                       return 1.0
                   }
               } else {
                   return "hello"
               }
           } else {
               return [1, 2, 3]
           }
       }
       """,
        MuTypes.Union{MuTypes.Int,MuTypes.Union{MuTypes.Float,MuTypes.Union{MuTypes.String,MuTypes.Array{MuTypes.Int,1}}}}
    )
]

WHILE_LOOP = [
    (
        """
        function f(){
            x = 0
            while (x < 10){
                x = x + 1
            }
            return x
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            x = 0.0
            while (x < 10.0){
                x = x + 1.0
            }
            return x
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            x = 0
            while (x < 10){
                x = x + 1
            }
            return x
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            x = 0.0
            while (x < 10.0){
                x = x + 1.0
            }
            return x
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            x = 0
            while (x < 10){
                x = x + 1
            }
            return x
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            x = 0.0
            while (x < 10.0){
                x = x + 1.0
            }
            return x
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function f(){
            x = 0
            while (x < 10){
                x = x + 1
            }
            return x
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function f(){
            x = 0.0
            while (x < 10.0){
                x = x + 1.0
            }
            return x
        }
        """,
        MuTypes.Float,
    ),
]


TESTCASES = Dict(
    "Simple literal" => SIMPLE_LITERAL,
    "Linear calculation" => SIMPLE_ONE_FUNC,
    "Some calculation" => SIMPLE_SOME_FUNC,
    "Some expression" => SIMPLE_SOMEEXPR,
    "If-else same type" => IF_ELSE_SAME_TYPE,
    "If-else different type" => IF_ELSE_DIFF_TYPE,
    "If-else nested same type" => IF_ELSE_NESTED_SAME_TYPE,
    "If-else nested different type" => IF_ELSE_NESTED_DIFF_TYPE,
    "While loop" => WHILE_LOOP,
)

EXACT_EXPECTED = Dict(
    "Simple literal" => SIMPLE_LITERAL,
    "Linear calculation" => SIMPLE_ONE_FUNC,
    "Some calculation" => SIMPLE_SOME_FUNC,
    "Some expression" => SIMPLE_SOMEEXPR,
    "If-else same type" => IF_ELSE_SAME_TYPE,
    "If-else different type" => IF_ELSE_DIFF_TYPE,
    "If-else nested same type" => IF_ELSE_NESTED_SAME_TYPE,
    "If-else nested different type" => IF_ELSE_NESTED_DIFF_TYPE,
    "While loop" => WHILE_LOOP,
)


function _infer_return_type(src::String)
    ast = MuCore.parse(src)
    lowerd = MuCore.lowering(ast)
    mt = MuBase.load_base()

    MuCore.MuInterpreter.load!(mt, lowerd)

    return MuTypeInf.return_type(lowerd[end], argtypes=[], mt=mt)
end

@testset "Safety of type inference" begin
    for (name, testcases) in SIMPLE_TESTCASES
        @testset "Test $name" begin
            for (src, _) in testcases
                inferred = _infer_return_type(src)
                actual = _return_value_type(src)

                safe = MuTypes.issubtype(_return_value_type(src), _infer_return_type(src))
                onfail(@test safe) do
                    @error "Got dangerous type inference! \n src: $src \n  inferred: $inferred \n  actual: $actual"
                end
            end
        end
    end
end

@testset "Exactness of type inference" begin
    for (name, testcases) in EXACT_EXPECTED
        @testset "Test $name" begin
            for (src, expected) in testcases
                exact = _infer_return_type(src) == expected
                onfail(@test exact) do
                    @error "Got inexact type inference! \n src: $src \n  expected: $expected \n  got: $(_infer_return_type(src))"
                end
            end
        end
    end
end


