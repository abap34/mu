using Test
using ArgParse

onfail(body, _::Test.Pass) = true
onfail(body, _::Union{Test.Fail, Test.Error}) = body()


function load(filename::AbstractString)
    return join(readlines(filename), "\n")
end

function iserror(; expectederror::Type{<:Exception}=Exception)
    return ((e) -> e isa expectederror)
end

const TESTS = Dict(
    "parse" => "parse.jl",
    "types" => "types.jl",
    "interpreter" => "interpreter.jl"
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
            include(TESTS[test])
        else
            @error "Unknown test: $test. Available tests: $(keys(TESTS))"
        end
    else
        @info "No test specified. Run all tests."
        for (test, file) in TESTS
            @info "Running test: $test"
            include(file)
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end
