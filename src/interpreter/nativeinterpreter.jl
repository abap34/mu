import Base

include("methodtable.jl")

struct Env
    bindings::Dict{String,Any}
    function Env()
        new(Dict{String,Any}())
    end
end

function Base.show(io::IO, env::Env)
    println("Env")
    name_width = max(10, maximum(length.(string.(keys(env.bindings)))))
    println("│ $(rpad("Name", name_width)) │ Value")
    for (name, value) in env.bindings
        println("├ $(repeat("─", name_width)) ┼ $(repeat("─", 40)) ")
        print("│ $(lpad(name, name_width)) │ ")
        println(value)
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
    if !haskey(frame.env.bindings, name)
        throw(ArgumentError("Name $name not found in frame. Available names: $(keys(frame.env.bindings))"))
    end
    return frame.env.bindings[name]
end

const CallStack = Vector{Frame}

mutable struct NativeInterpreter <: AbstractInterpreter
    # Method id -> label -> pc
    label_to_pc::Dict{Int,Dict{Int,Int}}
    methodtable::MethodTable
    callstack::CallStack
    function NativeInterpreter()
        new(Dict{Int,Int}(), MethodTable(), CallStack())
    end
end

function reset!(interp::NativeInterpreter)
    interp.label_to_pc = Dict{Int,Dict{Int,Int}}()
    interp.methodtable = MethodTable()
    interp.callstack = CallStack()
end

function label_to_pc(interp::NativeInterpreter, method_id::Int, label::Int)
    @assert haskey(interp.label_to_pc, method_id) "Method id $method_id not found in label_to_pc. Available method ids: $(keys(interp.label_to_pc))"
    @assert haskey(interp.label_to_pc[method_id], label) "Label $label not found in label_to_pc[$method_id]. Available labels: $(keys(interp.label_to_pc[method_id])). Method ir:\n$(interp.methodtable.id_to_codeinfo[method_id].ir)"

    return interp.label_to_pc[method_id][label]
end

function currentframe(interp::NativeInterpreter)
    return interp.callstack[end]
end

function injection!(interp::NativeInterpreter, codeinfo::MuIR.CodeInfo)
    # Register the method
    add_method!(interp.methodtable, codeinfo)

    # register method
    interp.label_to_pc[codeinfo.id] = Dict{Int,Int}()

    for (idx, instr) in enumerate(codeinfo.ir)
        if instr.irtype == MuIR.LABEL
            label = MuIR.get_label(instr)
            interp.label_to_pc[codeinfo.id][label] = idx
        end
    end
end

function execute_expr!(interp::NativeInterpreter, expr::MuAST.Literal)
    return expr
end

function execute_expr!(interp::NativeInterpreter, expr::MuAST.Ident)
    return lookup(currentframe(interp), expr.name)
end

function execute_expr!(interp::NativeInterpreter, expr::MuAST.Expr)
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

function call_generics!(interp::NativeInterpreter, name::MuAST.Ident, args::Vector{<:Any})
    @assert all(arg -> arg isa MuAST.Ident || arg isa MuAST.Literal, args) "Arguments must be LITERAL or IDENT. Got $(args)"

    argvalues = [execute_expr!(interp, arg) for arg in args]
    argtypes = [MuTypes.typeof(arg) for arg in argvalues]
    method_id = lookup(interp.methodtable, name, argtypes)

    codeinfo = codeinfo_by_id(interp.methodtable, method_id)

    push!(interp.callstack, Frame(method_id, 1, Env()))

    for (name, value) in zip(codeinfo.argname, argvalues)
        bind!(currentframe(interp), name.name, value)
    end

    result = interpret_local!(interp, codeinfo.ir)

    pop!(interp.callstack)

    return result
end


function call_builtin!(interp::NativeInterpreter, name::MuAST.Ident, args::Vector{<:Any})
    MuBuiltins.get_builtin(name.name)(args, currentframe(interp).env.bindings)
end


function interpret_local!(interp::NativeInterpreter, ir::MuIR.IR)
    frame = currentframe(interp)

    while frame.pc <= length(ir)
        instr = ir[frame.pc]
        if instr.irtype == MuIR.ASSIGN
            lhs, rhs = instr.expr.args
            bind!(frame, lhs.name, execute_expr!(interp, rhs))
            frame.pc += 1

        elseif instr.irtype == MuIR.GOTO
            dest = MuIR.get_dest(instr)
            frame.pc = label_to_pc(interp, frame.method_id, dest)

        elseif instr.irtype == MuIR.GOTOIFNOT
            label, cond = instr.expr.args


            if !execute_expr!(interp, cond)
                frame.pc = label_to_pc(interp, frame.method_id, label)
            else
                frame.pc += 1
            end

        elseif instr.irtype == MuIR.RETURN
            return execute_expr!(interp, MuIR.get_returnexpr(instr))

        elseif instr.irtype == MuIR.LABEL
            frame.pc += 1

        else
            throw(ArgumentError("Unknown IRType: $(instr.irtype)"))
        end

    end

    throw(ArgumentError("End of IR reached. Expected RETURN"))
end


function interpret(program::MuIR.ProgramIR, interp::NativeInterpreter)
    for f in program
        injection!(interp, f)
    end

    main_id = lookup(interp.methodtable, MuAST.Ident("main"), DataType[])

    push!(interp.callstack, Frame(main_id, 1, Env()))

    main_ir = codeinfo_by_id(interp.methodtable, main_id).ir

    interpret_local!(interp, main_ir)
end

function interpret(program::MuIR.ProgramIR)
    interpret(program, NativeInterpreter())
end


