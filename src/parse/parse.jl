using PEG

include("ast.jl")

module MuParse

using ..MuAST

include("builder.jl")
include("rules.jl")

end

using .MuParse

function parse(src::String; rule=MuParse.program)
    return PEG.parse_whole(rule, src)
end

function parse_file(filename::AbstractString)
    return parse(join(readlines(filename), "\n"))
end