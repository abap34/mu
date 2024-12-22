using PEG

include("ast.jl")
include("builder.jl")
include("rules.jl")

function parse(src::String; rule=program)
    return PEG.parse_whole(rule, src)
end

function parse_file(filename::AbstractString)
    return parse(join(readlines(filename), "\n"))
end