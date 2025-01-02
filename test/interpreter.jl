using mu

testcases = [
    ("runtest/multipledispatch.mu",
    """
    Int, Int
    Int, Number
    Number, Int
    Number, Number
    Number, Array{Int, 1}
    """
    ),
    ("runtest/fizzbuzz.mu",
    """
    1
    2
    Fizz
    4
    Buzz
    Fizz
    7
    8
    Fizz
    Buzz
    11
    Fizz
    13
    14
    FizzBuzz
    16
    17
    Fizz
    19
    Buzz
    Fizz
    22
    23
    Fizz
    Buzz
    26
    Fizz
    28
    29
    FizzBuzz
    """
    )
]


function get_run_result(file)
    open("/tmp/stdout", "w") do io
        open("/tmp/stderr", "w") do io2
            redirect_stdout(io) do
                redirect_stderr(io2) do
                    mu.run(file)
                end
            end
        end
    end

    return read("/tmp/stdout", String), read("/tmp/stderr", String)
end

@testset "Files Execution Test" begin
    for (file, expected) in testcases
        stdout_result, stderr_result = get_run_result(file)
        @test stdout_result == expected
        @test stderr_result == ""     
    end
end