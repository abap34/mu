module mu

module MuCore

include("parse/parse.jl")
include("builtin/builtin.jl")

include("lowering/lowering.jl")

include("types/types.jl")   

include("interpreter/interpreter.jl")

end # module MuCore

module MuBase

include("base/base.jl")

end


function run(filename::AbstractString, mode=:interpret)
    @assert mode in [:interpret, :compile] "Invalid mode: $mode. Must be either :interpret or :compile"

    ast = MuCore.parse_file(filename)
    ir = MuCore.lowering(ast)
    if mode == :interpret
        interp = MuCore.MuInterpreter.ConcreateInterpreter()
        
        for f in MuBase.load_base()
            MuCore.MuInterpreter.injection!(interp, f)
        end

        MuCore.MuInterpreter.interpret(ir, interp; debug=debug)
    
    elseif mode == :compile
        # TODO
    end
end


end