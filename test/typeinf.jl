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
MuTypes.Array{MuTypes.Int, 1},
),
(
"""
function f(){
    return [1.0, 2.0, 3.0]
}
""",
MuTypes.Array{MuTypes.Float, 1},
),
(
"""
function f(){
    return [true, false, true]
}
""",
MuTypes.Array{MuTypes.Bool, 1},
),
(
"""
function f(){
    return ["hello", "world"]
}
""",
MuTypes.Array{MuTypes.String, 1},
),
(
"""
function f(){
    return [1, 2, 3; 4, 5, 6]
}
""",
MuTypes.Array{MuTypes.Int, 2},
),
]


LINEAR_CALC = [
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
MuTypes.Array{MuTypes.Int, 2},
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
MuTypes.Array{MuTypes.Int, 1},
),
(
"""
function f(){
    return @sum([1.0, 2.0, 3.0; 4.0, 5.0, 6.0], 2)
}
""",
MuTypes.Array{MuTypes.Float, 1},
),
(
"""
function f(){
    return @expanddims([1, 2, 3])
}
""",
MuTypes.Array{MuTypes.Int, 2},
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

TESTCASES = Dict(
    "Simple literal" => SIMPLE_LITERAL,
    "Linear calculation" => LINEAR_CALC,
)

EXACT_EXPECTED = Dict(
    "Simple literal" => SIMPLE_LITERAL,
    "Linear calculation" => LINEAR_CALC,
)


function _infer_return_type(src::String)
    ast = MuCore.parse(src)
    lowerd = MuCore.lowering(ast)
    mt = MuBase.load_base()

    MuCore.MuInterpreter.load!(mt, lowerd)

    return MuTypeInf.return_type(lowerd[end], argtypes=[], mt=mt)
end

@testset "Safety of type inference" begin
    for (name, testcases) in TESTCASES
        @testset "Test $name" begin
            for (src, expected) in testcases
                safe = MuTypes.issubtype(_infer_return_type(src), expected)
                onfail(@test safe) do
                    @error "Got dangerous type inference! \n src: $src \n  expected: $expected \n  got: $(_infer_return_type(src))"
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


