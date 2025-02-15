using mu.MuCore
using mu.MuBase

using mu.MuCore.MuTypes
using mu.MuCore.MuTypeInf

# Simple Tests

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
            return @set_arr([1.2, 2.3, 3.4], 1, 1)
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

MULTI_FUNCSTOPN = [
    (
        """
        function g(x::Int){
            return x
        }

        function f(){
            return g(1)
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function h(x::Float){
            return x
        }

        function g(x::Float){
            return h(x)
        }

        function f(){
            return g(1.0)
        }
        """,
        MuTypes.Float,
    ),
]

ABSTRACT_FORMALARGS = [
    (
        """
        function g(x::Number){
            return x
        }

        function f(){
            return g(1)
        }
        """,
        MuTypes.Int,
    ),
    (
        """
        function h(x::Number){
            return x
        }

        function g(x::Number){
            return h(x)
        }

        function f(){
            return g(1.0)
        }
        """,
        MuTypes.Float,
    ),
    (
        """
        function h(x::Number){
            return x
        }

        function g(x::Number){
            return h(x)
        }

        function f(){
            if (true){
                return h(1.0)
            } else {
                return g(1)
            }
        }
        """,
        MuTypes.Union{MuTypes.Int,MuTypes.Float},
    ),
    (
        """
        function h(x::Number){
            return x
        }

        function g(x::Number){
            return h(x)
        }

        function f(){
            if (true){
                return h(1.0)
            } else {
                return g(1.0)
            }
        }
        """,
        MuTypes.Float,
    ),
]

SIMPLE_TESTCASES = Dict(
    "Simple literal" => SIMPLE_LITERAL,
    "Linear calculation" => SIMPLE_ONE_FUNC,
    "Some calculation" => SIMPLE_SOME_FUNC,
    "Some expression" => SIMPLE_SOMEEXPR,
    "If-else same type" => IF_ELSE_SAME_TYPE,
    "If-else different type" => IF_ELSE_DIFF_TYPE,
    "If-else nested same type" => IF_ELSE_NESTED_SAME_TYPE,
    "If-else nested different type" => IF_ELSE_NESTED_DIFF_TYPE,
    "While loop" => WHILE_LOOP,
    "Multiple function stop" => MULTI_FUNCSTOPN,
    "Abstract formal arguments" => ABSTRACT_FORMALARGS,
)


function _infer_return_type(src::String)
    ast = MuCore.parse(src)
    lowerd = MuCore.lowering(ast)
    mt = MuBase.load_base()

    MuCore.MuInterpreter.load!(mt, lowerd)

    return MuTypeInf.return_type(lowerd[end], argtypes=[], mt=mt)
end

function _return_value_type(src::String)
    src *= """
    function main(){
        return f()
    }
    """
    ast = MuCore.parse(src)
    lowerd = MuCore.lowering(ast)
    mt = MuBase.load_base()

    MuCore.MuInterpreter.load!(mt, lowerd)

    interp = MuCore.MuInterpreter.ConcreateInterpreter(methodtable=mt)

    return MuTypes.typeof(MuCore.MuInterpreter.interpret(lowerd, interp))
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
    for (name, testcases) in SIMPLE_TESTCASES
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




# Difficult Tests
function _load_main_mi(src::String)::Tuple{MuCore.MuInterpreter.MethodTable,MuCore.MuIR.MethodInstance}
    preload_ast = MuCore.parse_file("typeinf/preload.mu")
    preload_lowerd = MuCore.lowering(preload_ast)
    mt = MuBase.load_base()
    MuCore.MuInterpreter.load!(mt, preload_lowerd)

    main_ast = MuCore.parse(src)
    main_lowerd = MuCore.lowering(main_ast)
    MuCore.MuInterpreter.load!(mt, main_lowerd)

    main_mi = main_lowerd[end]

    return mt, main_mi
end

function _run_main(src::String)
    mt, main_mi = _load_main_mi(src)
    interp = MuCore.MuInterpreter.ConcreateInterpreter(methodtable=mt)

    return MuCore.MuInterpreter.interpret([main_mi], interp)
end

function _safety_test(actual, infered, src::String)
    safe = MuTypes.issubtype(actual, infered)
    onfail(@test safe) do
        @error "Got dangerous type inference! \n src: $src \n  inferred: $infered \n  actual: $actual"
    end
end

function _exactness_test(infered, expected, src::String)
    exact = infered == expected
    onfail(@test exact) do
        @error "Got inexact type inference! \n src: $src \n  expected: $expected \n  got: $infered"
    end
end

@testset "Difficult tests" begin

    TESTCASE1 = """
    function main(){
        x = 1
        return double(x)
    }
    """

    mt, main_mi = _load_main_mi(TESTCASE1)

    infered = MuTypeInf.return_type(main_mi, argtypes=[], mt=mt)
    actual = MuTypes.typeof(_run_main(TESTCASE1))
    expected = MuTypes.Int

    @testset "Test 1" begin
        _safety_test(actual, infered, TESTCASE1)
        _exactness_test(infered, expected, TESTCASE1)
    end




    TESTCASE2 = """
    function main(){
        x = 1.0
        return double(x)
    }
    """

    mt, main_mi = _load_main_mi(TESTCASE2)

    infered = MuTypeInf.return_type(main_mi, argtypes=[], mt=mt)
    actual = MuTypes.typeof(_run_main(TESTCASE2))
    expected = MuTypes.Float

    @testset "Test 2" begin
        _safety_test(actual, infered, TESTCASE2)
        _exactness_test(infered, expected, TESTCASE2)
    end



    TESTCASE3 = """
    function main(){
        x = [1, 2, 3; 4, 5, 6]
        return double(x)    
    }
    """

    mt, main_mi = _load_main_mi(TESTCASE3)

    infered = MuTypeInf.return_type(main_mi, argtypes=[], mt=mt)
    actual = MuTypes.typeof(_run_main(TESTCASE3))
    expected = MuTypes.Array{MuTypes.Int,2}

    @testset "Test 3" begin
        _safety_test(actual, infered, TESTCASE3)
        _exactness_test(infered, expected, TESTCASE3)
    end



    TESTCASE4 = """
    function main(){
        if (true) {
            x = [1, 2, 3]
        } else {
            x = 2
        }   
        
        return double(x)
    }
    """

    mt, main_mi = _load_main_mi(TESTCASE4)

    infered = MuTypeInf.return_type(main_mi, argtypes=[], mt=mt)
    actual = MuTypes.typeof(_run_main(TESTCASE4))
    expected = MuTypes.Union{MuTypes.Array{MuTypes.Int,1},MuTypes.Int}


    @testset "Test 4" begin
        _safety_test(actual, infered, TESTCASE4)
        _exactness_test(infered, expected, TESTCASE4)
    end

    TESTCASE5 = """
    function main(){
        if (true) {
            x = [1, 2, 3]
        } else {
            x = 2.0
        }   
        
        return double(x)
    }
    """

    mt, main_mi = _load_main_mi(TESTCASE5)

    infered = MuTypeInf.return_type(main_mi, argtypes=[], mt=mt)
    actual = MuTypes.typeof(_run_main(TESTCASE5))
    expected = MuTypes.Union{MuTypes.Array{MuTypes.Int,1},MuTypes.Float}


    @testset "Test 5" begin
        _safety_test(actual, infered, TESTCASE5)
        _exactness_test(infered, expected, TESTCASE5)
    end


    # Test 6. 
    # Without widening, this test will not terminate.

    TESTCASE6 = """
    function main(){
        x = [1, 2, 3]
        n = 100

        i = 0

        while (i < n){
            x = expanddims(x)
            i = i + 1
        }
        
        return x
    }
    """

    mt, main_mi = _load_main_mi(TESTCASE6)

    # start inf and kill if it takes more than 5 seconds
    infered = @timeout 5 _infer_return_type(TESTCASE6) "Inference takes too long!"
    actual = MuTypes.typeof(_run_main(TESTCASE6))

    expected = MuTypes.AbstractArray

    if infered == "Inference takes too long!"
        @error "Inference takes too long! in TESTCASE6"
        @test false
    else
        _safety_test(actual, infered, TESTCASE6)
        _exactness_test(infered, expected, TESTCASE6)
    end


    TESTCASE7 = """
    function main(){
        if (true){
            x = 1
        } else {
            x = 1.0
        }

         return double(double(x))
    }
       
    """

    mt, main_mi = _load_main_mi(TESTCASE7)


    infered = MuTypeInf.return_type(main_mi, argtypes=[], mt=mt)
    actual = MuTypes.typeof(_run_main(TESTCASE7))
    expected = MuTypes.Union{MuTypes.Int,MuTypes.Float}


    @testset "Test 7" begin
        _safety_test(actual, infered, TESTCASE7)
        _exactness_test(infered, expected, TESTCASE7)
    end



    TESTCASE8 = """
    function main(){
        if (true){
            x = 1
        } else {
            x = 1.0
        }

        if (true){
            y = 2
        } else {
            y = 2.0
        }

        return double(double(x) + double(y))
    }
    """

    mt, main_mi = _load_main_mi(TESTCASE8)

    infered = MuTypeInf.return_type(main_mi, argtypes=[], mt=mt)
    actual = MuTypes.typeof(_run_main(TESTCASE8))
    expected = MuTypes.Union{MuTypes.Int,MuTypes.Float}

    @testset "Test 8" begin
        _safety_test(actual, infered, TESTCASE8)
        _exactness_test(infered, expected, TESTCASE8)
    end





end
