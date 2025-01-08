import Base

include("methodtable.jl")

struct Env
    bindings::Dict{String,Any}
    function Env()
        new(Dict{String,Any}())
    end
end

function Base.show(io::IO, env::Env)
    println(io, "Env")
    name_width = maximum(length, string.(keys(env.bindings)), init=10)
    println(io, "│ $(rpad("Name", name_width)) │ Value")
    for (name, value) in env.bindings
        println(io, "├ $(repeat("─", name_width)) ┼ $(repeat("─", 40)) ")
        print(io, "│ $(lpad(name, name_width)) │ ")
        println(io, value)
    end

end

mutable struct Frame
    method_id::Int  # Method id
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

function Base.show(io::IO, frame::Frame)
    println("┌ Method id: $(frame.method_id)")
    println("│ PC: $(frame.pc)")
    println("│ Env:", frame.env)
    println("└")

end

function Base.show(io::IO, callstack::CallStack)
    println("Call stack")
    for frame in callstack
        println(io, "─"^40)
        println(frame)
    end
end

mutable struct NativeInterpreter <: AbstractInterpreter
    # Method id -> label -> pc
    label_to_pc::Dict{Int,Dict{Int,Int}}
    methodtable::MethodTable
    callstack::CallStack
    function NativeInterpreter(;label_to_pc=Dict{Int,Dict{Int,Int}}(), methodtable=MethodTable(), callstack=CallStack())
        new(label_to_pc, methodtable, callstack)
    end
end

function reset!(interp::NativeInterpreter)
    interp.label_to_pc = Dict{Int,Dict{Int,Int}}()
    interp.methodtable = MethodTable()
    interp.callstack = CallStack()
end

function label_to_pc(interp::NativeInterpreter, method_id::Int, label::Int)
    if !haskey(interp.label_to_pc, method_id)
        throw(ArgumentError("Method id $method_id not found in label_to_pc. Available method ids: $(keys(interp.label_to_pc))"))
    end

    if !haskey(interp.label_to_pc[method_id], label)
        throw(ArgumentError("Label $label not found in label_to_pc[$method_id]. Available labels: $(keys(interp.label_to_pc[method_id])). Method: $(mi_by_id(interp.methodtable, method_id).name)"))
    end

    return interp.label_to_pc[method_id][label]
end

function currentframe(interp::NativeInterpreter)
    return interp.callstack[end]
end

function injection!(interp::NativeInterpreter, mi::MuIR.MethodInstance)
    # Register the method
    add_method!(interp.methodtable, mi)

    # register method
    interp.label_to_pc[mi.id] = Dict{Int,Int}()

    for (idx, instr) in enumerate(mi.ci)
        if instr.irtype == MuIR.LABEL
            label = MuIR.get_label(instr)
            interp.label_to_pc[mi.id][label] = idx
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

    mi = mi_by_id(interp.methodtable, method_id)

    push!(interp.callstack, Frame(method_id, 1, Env()))

    for (name, value) in zip(mi.argname, argvalues)
        bind!(currentframe(interp), name.name, value)
    end

    result = interpret_local!(interp, mi)

    pop!(interp.callstack)

    return result
end


function call_builtin!(interp::NativeInterpreter, name::MuAST.Ident, args::Vector{<:Any})
    MuBuiltins.get_builtin(name.name)(args, currentframe(interp).env.bindings)
end


function interpret_local!(interp::NativeInterpreter, mi::MuIR.MethodInstance)
    frame = currentframe(interp)
    ci = mi.ci

    try
        while frame.pc <= length(ci)
            instr = ci[frame.pc]
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
                return execute_expr!(interp, MuIR.get_returnbody(instr))

            elseif instr.irtype == MuIR.LABEL
                frame.pc += 1

            else
                throw(ArgumentError("Unknown IRType: $(instr.irtype)"))
            end

        end
    catch e
        @error "Error: $e in method: $(mi_by_id(interp.methodtable, frame.method_id).name) at $(ci[frame.pc])"
        rethrow(e)
    end

    throw(ArgumentError("End of IR reached. Expected RETURN"))
end


function interpret(program::MuIR.ProgramIR, interp::NativeInterpreter)
    load!(interp.methodtable, program)

    main_id = lookup(interp.methodtable, MuAST.Ident("main"), DataType[])

    push!(interp.callstack, Frame(main_id, 1, Env()))

    main_mi = mi_by_id(interp.methodtable, main_id)

    interpret_local!(interp, main_mi)
end

function interpret(program::MuIR.ProgramIR)
    interpret(program, NativeInterpreter())
end


