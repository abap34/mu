include("methodtable.jl")

struct Env
    bindings::Dict{String,Any}
    function Env()
        new(Dict{String,Any}())
    end
end

mutable struct Frame
    method_id::Int          # Method id
    pc::Int         # Program counter
    env::Env        # Environment
    function Frame(id::Int, pc::Int, env::Env)
        new(id, pc, env)
    end
end

function bind!(frame::Frame, name::String, value::Any)
    frame.env.bindings[name] = value
end

function lookup(frame::Frame, name::String)
    return frame.env.bindings[name]
end

const CallStack = Vector{Frame}

mutable struct ConcreateInterpreter <: AbstractInterpreter
    # Method id -> label -> pc
    label_to_pc::Dict{Int,Dict{Int,Int}}
    methodtable::MethodTable
    callstack::CallStack
    function ConcreateInterpreter()
        new(Dict{Int,Int}(), MethodTable(), CallStack())
    end
end

function reset!(interp::ConcreateInterpreter)
    interp.label_to_pc = Dict{Int,Dict{Int,Int}}()
    interp.methodtable = MethodTable()
    interp.callstack = CallStack()
end

function label_to_pc(interp::ConcreateInterpreter, method_id::Int, label::Int)
    @assert haskey(interp.label_to_pc, method_id) "Method id $method_id not found in label_to_pc. Available method ids: $(keys(interp.label_to_pc))"
    @assert haskey(interp.label_to_pc[method_id], label) "Label $label not found in label_to_pc[$method_id]. Available labels: $(keys(interp.label_to_pc[method_id])). Method ir:\n$(interp.methodtable.id_to_codeinfo[method_id].ir)"

    return interp.label_to_pc[method_id][label]
end

function currentframe(interp::ConcreateInterpreter)
    return interp.callstack[end]
end

function injection!(interp::ConcreateInterpreter, codeinfo::MuIR.CodeInfo)
    # Register the method
    add_method!(interp.methodtable, codeinfo)

    # register method
    interp.label_to_pc[codeinfo.id] = Dict{Int,Int}()

    for (idx, instr) in enumerate(codeinfo.ir)
        if instr.irtype == MuIR.LABEL
            label = instr.expr.args[1]
            interp.label_to_pc[codeinfo.id][label] = idx
        end
    end
end

function execute_expr!(interp::ConcreateInterpreter, expr::MuAST.Literal)
    return expr
end

function execute_expr!(interp::ConcreateInterpreter, expr::MuAST.Ident)
    return lookup(currentframe(interp), expr.name)
end

function execute_expr!(interp::ConcreateInterpreter, expr::MuAST.Expr)
    if expr.head == MuAST.GCALL
        f, args... = expr.args

        @assert all(arg -> arg isa MuAST.Ident || arg isa MuAST.Literal, args) "Arguments must be LITERAL or IDENT. Got $(args)"

        argvalues = [execute_expr!(interp, arg) for arg in args]

        return call_generics!(interp, f, argvalues)
    elseif expr.head == MuAST.BCALL
        f, args... = expr.args

        @assert all(arg -> arg isa MuAST.Ident || arg isa MuAST.Literal, args) "Arguments must be LITERAL or IDENT. Got $(args)"

        argvalues = [execute_expr!(interp, arg) for arg in args]

        return call_builtin!(interp, f, argvalues)
    else
        throw(ArgumentError("Unknown expression type: $(expr.head). Expected GCALL or BCALL"))
    end
end

function call_generics!(interp::ConcreateInterpreter, name::MuAST.Ident, args::Vector{<:Any})
    @assert all(arg -> arg isa MuAST.Ident || arg isa MuAST.Literal, args) "Arguments must be LITERAL or IDENT. Got $(args)"

    argvalues = [execute_expr!(interp, arg) for arg in args]
    argtypes = [MuTypes.typeof(arg) for arg in argvalues]
    method_id = lookup(interp.methodtable, name, argtypes)

    codeinfo = codeinfo_by_id(interp.methodtable, method_id)
    formalargs = codeinfo.args

    push!(interp.callstack, Frame(method_id, 1, Env()))

    for (formal, arg) in zip(formalargs.args, argvalues)
        @assert arg isa MuAST.Literal || arg isa MuAST.Ident "Argument must be Literal or Ident. Got $(arg.head)"
        bind!(currentframe(interp), formal.args[1].name, arg)
    end

    result = interpret_local!(interp, codeinfo.ir)

    pop!(interp.callstack)

    return result
end


function call_builtin!(interp::ConcreateInterpreter, name::MuAST.Ident, args::Vector{<:Any})
    MuBuiltins.get_builtin(name.name)(args, currentframe(interp).env.bindings)
end


function interpret_local!(interp::ConcreateInterpreter, ir::MuIR.IR)
    frame = currentframe(interp)

    while frame.pc <= length(ir)
        instr = ir[frame.pc]
        if instr.irtype == MuIR.ASSIGN
            lhs, rhs = instr.expr.args
            bind!(frame, lhs.name, execute_expr!(interp, rhs))
            frame.pc += 1

        elseif instr.irtype == MuIR.GOTO
            label = instr.expr.args[1]
            frame.pc = label_to_pc(interp, frame.method_id, label)

        elseif instr.irtype == MuIR.GOTOIFNOT
            label, cond = instr.expr.args


            if !execute_expr!(interp, cond)
                frame.pc = label_to_pc(interp, frame.method_id, label)
            else
                frame.pc += 1
            end

        elseif instr.irtype == MuIR.RETURN
            return execute_expr!(interp, instr.expr.args[1])

        elseif instr.irtype == MuIR.LABEL
            frame.pc += 1

        else
            throw(ArgumentError("Unknown IRType: $(instr.irtype)"))
        end

    end

    throw(ArgumentError("End of IR reached. Expected RETURN"))
end


function interpret(program::MuIR.ProgramIR, interp::ConcreateInterpreter; debug=false)
    for f in program
        injection!(interp, f)
    end

    main_id = lookup(interp.methodtable, MuAST.Ident("main"), DataType[])

    push!(interp.callstack, Frame(main_id, 1, Env()))

    main_ir = codeinfo_by_id(interp.methodtable, main_id).ir

    interpret_local!(interp, main_ir)
end

function interpret(program::MuIR.ProgramIR)
    interpret(program, ConcreateInterpreter(); debug=false)
end


