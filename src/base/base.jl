using ..MuCore

function load_base()::MuCore.MuIR.ProgramIR
    ast = MuCore.parse_file("base/base.mu")
    ir = MuCore.lowering(ast)
    return ir
end

