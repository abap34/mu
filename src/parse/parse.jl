using PEG

include("ast.jl")

module MuParse

using ..MuAST

include("builder.jl")
include("rules.jl")

end

using .MuParse


# ignore line starts with "#""
function removecomments(src::String)
    removed = ""
    for line in split(src, '\n')
        if !startswith(line, "#")
            removed *= line
        end
    end

    return removed
end


function parse(src::String; rule=MuParse.program)
    _parse(src) = PEG.parse_whole(rule, src)
    return src |> removecomments |> _parse
end

function parse_file(filename::AbstractString)
    return parse(join(readlines(filename), "\n"))
end
