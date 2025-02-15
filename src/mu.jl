module mu

module MuCore

include("parse/parse.jl")

include("types/types.jl")

include("lowering/lowering.jl")
include("builtin/builtin.jl")
include("interpreter/interpreter.jl")

include("typeinf/typeinf.jl")

end # module MuCore

module MuBase

include("base/base.jl")

end


function run(filename::AbstractString, mode=:interpret; reload_base=false)
    @assert mode in [:interpret, :compile] "Invalid mode: $mode. Must be either :interpret or :compile"

    ast = MuCore.parse_file(filename)
    ci = MuCore.lowering(ast)
    if mode == :interpret
        interp = MuCore.MuInterpreter.ConcreateInterpreter(methodtable=MuBase.load_base(reload=reload_base))

        MuCore.MuInterpreter.interpret(ci, interp)
    elseif mode == :compile
        # TODO
    end
end


end