using Test
using ArgParse

onfail(body, _::Test.Pass) = true
onfail(body, _::Union{Test.Fail,Test.Error}) = body()

# https://discourse.julialang.org/t/simple-timeout-of-function/99578/5?u=abap34
macro timeout(seconds, expr_to_run, expr_when_fails)
    quote
        tsk = @task $(esc(expr_to_run))
        schedule(tsk)
        Timer($(esc(seconds))) do timer
            istaskdone(tsk) || Base.throwto(tsk, InterruptException())
        end
        try
            fetch(tsk)
        catch _
            $(esc(expr_when_fails))
        end
    end
end

function load(filename::AbstractString)
    return join(readlines(filename), "\n")
end

function iserror(; expectederror::Type{<:Exception}=Exception)
    return ((e) -> e isa expectederror)
end

const TESTS = Dict(
    "parse" => "parse.jl",
    "types" => "types.jl",
    "interpreter" => "interpreter.jl",
    "typeinf" => "typeinf.jl",
)

function main(args)
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--single"
        help = "Specify a test to run (parse/types)"
        arg_type = String
        required = false
    end

    parsed_args = parse_args(args, s)

    if !(isnothing(parsed_args["single"]))
        test = parsed_args["single"]
        if haskey(TESTS, test)
            @info "Run Single Test: $test"
            @testset verbose = true "$test" begin
                include(TESTS[test])
            end
        else
            @error "Unknown test: $test. Available tests: $(keys(TESTS))"
        end
    else
        @info "No test specified. Run all tests."
        @testset verbose = true "All Tests" begin
            for (test, file) in TESTS
                @info "Running test: $test"
                @testset "$test" begin
                    include(file)
                end
            end
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end
