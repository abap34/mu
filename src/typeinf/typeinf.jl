module MuTypeInf


using ..MuTypes
using ..MuAST
using ..MuIR
using ..MuInterpreter
using ..MuBuiltins

import Base


struct InferenceFrame{T}
    inputs::Vector{T}
    outputs::Vector{T}
    mi::MuIR.MethodInstance
    ∇::Function
end


function InferenceFrame(init::T, n::Int, mi::MuIR.MethodInstance, ∇::Function)::InferenceFrame{T} where {T}
    InferenceFrame{T}([init for i in 1:n], [init for i in 1:n], mi, ∇)
end


function preview(state::InferenceFrame{T}; highlight::Int=-1) where {T}
    if isempty(state.inputs)
        println("Empty InferenceState")
        return
    end

    n = length(state.inputs)

    idx_width = max(ndigits(n), 3)

    inputs_width = max(maximum(x -> length(render(x, mode=:minimal)), state.inputs), 10)
    outputs_width = max(maximum(x -> length(render(x, mode=:minimal)), state.outputs), 10)
    instr_width = max(maximum(x -> length(string(x)), state.mi.ci), 10)

    println("| ", lpad("idx", idx_width), " | ", lpad("inputs", inputs_width), " | ", lpad("outputs", outputs_width), " | ", lpad("instr", instr_width))
    println("| ", "-"^idx_width, " | ", "-"^inputs_width, " | ", "-"^outputs_width, " | ", "-"^instr_width)

    for i in 1:n
        _println(args...) = i == highlight ? printstyled(args..., "\n", bold=true, color=:yellow, underline=true, blink=true) : println(args...)

        _println("| ", lpad(string(i), idx_width), " | ", lpad(render(state.inputs[i], mode=:minimal), inputs_width), " | ", lpad(render(state.outputs[i], mode=:minimal), outputs_width), " | ", lpad(string(state.mi.ci[i]), instr_width))
    end

    println()

end

function Base.getindex(state::InferenceFrame{T}, i::Int)::Tuple{T,T} where {T}
    return state.inputs[i], state.outputs[i]
end

function update!(state::InferenceFrame{T}, i::Int, new_input::T, new_output::T)::Bool where {T}
    current_input, current_output = state[i]

    state.inputs[i] = new_input
    state.outputs[i] = state.∇(new_output, current_output)

    return (new_input != current_input) || (new_output != current_output)
end

struct AbstractState{T}
    state::Dict{MuAST.Ident,T}
    mt::MuInterpreter.MethodTable
end

function AbstractState(T::Type; mt::MuInterpreter.MethodTable=MuInterpreter.MethodTable())
    AbstractState{T}(Dict{MuAST.Ident,T}(), mt)
end



function lookup(state::AbstractState{T}, ident::MuAST.Ident)::T where {T}
    if haskey(state.state, ident)
        return state.state[ident]
    else
        throw(ArgumentError("Unknown identifier: $ident"))
    end
end

function bind!(state::AbstractState{T}, ident::MuAST.Ident, value::T)::AbstractState{T} where {T}
    state.state[ident] = value
    return state
end

function Base.haskey(state::AbstractState{T}, ident::MuAST.Ident)::Bool where {T}
    return haskey(state.state, ident)
end

function render(state::AbstractState{T}; mode=:minimal) where {T}
    out = IOBuffer()

    if isempty(state.state)
        if mode == :minimal
            return " "
        else
            println(out, "Empty AbstractState")
            return String(take!(out))
        end
    end

    n = length(state.state)

    if mode == :minimal
        for (ident, value) in state.state
            if ident.name == "_"
                continue
            end

            print(out, repr(ident), "::", MuTypes.shorten_str(value), " ")
        end
    else
        ident_width = max(maximum(x -> length(repr(x)), keys(state.state)), 10)
        value_width = max(maximum(x -> length(repr(x)), values(state.state)), 10)

        println(out, "| ", lpad("ident", ident_width), " | ", lpad("value", value_width))
        println(out, "| ", "-"^ident_width, " | ", "-"^value_width)

        for (ident, value) in state.state
            println(out, "| ", lpad(repr(ident), ident_width), " | ", lpad(repr(value), value_width))
        end

        println(out)
    end

    return String(take!(out))

end

function Base.show(io::IO, state::AbstractState{T}) where {T}
    if isempty(state.state)
        println(io, "Empty AbstractState")
        return
    end

    n = length(state.state)

    ident_width = max(maximum(x -> length(repr(x)), keys(state.state)), 10)
    value_width = max(maximum(x -> length(repr(x)), values(state.state)), 10)

    println(io, "| ", lpad("ident", ident_width), " | ", lpad("value", value_width))
    println(io, "| ", "-"^ident_width, " | ", "-"^value_width)

    for (ident, value) in state.state
        println(io, "| ", lpad(repr(ident), ident_width), " | ", lpad(repr(value), value_width))
    end

    println(io)
end

function Base.:(==)(state1::AbstractState{T}, state2::AbstractState{T})::Bool where {T}
    return state1.state == state2.state
end

function Base.copy(state::AbstractState{T})::AbstractState{T} where {T}
    AbstractState{T}(copy(state.state), state.mt)
end

include("abstractsemantics.jl")
include("solver.jl")

# Interface for type inference
function infer(mi::MuIR.MethodInstance; argtypes::AbstractArray, mt::MuInterpreter.MethodTable)
    initstate = AbstractState(DataType, mt=mt)

    for (argname, argtype) in zip(mi.argname, argtypes)
        bind!(initstate, argname, argtype)
    end


    inferedframe = abstract_interpret(
        mi,
        abstract_semantics,
        ∇,
        initstate=initstate,
    )

    return inferedframe
end


# Interface for type inference
function return_type(mi::MuIR.MethodInstance; argtypes::AbstractArray, mt::MuInterpreter.MethodTable)
    infered_state = infer(mi, argtypes=argtypes, mt=mt)
    return lookup(infered_state.outputs[end], MuAST.RETURN_IDENT)
end

function show_typing(mi::MuIR.MethodInstance, frame::InferenceFrame; io::IO=stdout)
    ci = mi.ci
    n = length(ci)

    if n != length(frame.inputs) || n != length(frame.outputs)
        throw(ArgumentError("InferenceFrame length mismatch"))
    end

    if length(ci.instrs) == 0
        println(io, "Empty IR")
        return
    end

    instrs = ci.instrs

    idx_width = max(ndigits(length(instrs)), 3)
    irtype_width = max(maximum(x -> length(string(x.irtype)), instr for instr in instrs), 10)

    println(io, "| ", lpad("idx", idx_width), " | ", lpad("irtype", irtype_width), " | instr")
    println(io, "| ", "-"^idx_width, " | ", "-"^irtype_width, " | ", "-"^40)

    for (idx, instr) in enumerate(instrs)
        print(io, "| ", lpad(string(idx), idx_width), " | ", lpad(string(instr.irtype), irtype_width), " | ", instr)

        if instr.irtype == MuIR.ASSIGN
            assign_var = MuIR.get_varname(instr)

            if assign_var.name == "_"
                println(io, " ")
                continue
            end

            inferred_type = lookup(frame.outputs[idx], assign_var)


            if inferred_type == MuTypes.Bottom
                color = :red
            elseif inferred_type == MuTypes.Any
                color = :red
            else
                if MuTypes.is_concrete(inferred_type)
                    color = :blue
                else
                    color = :magenta
                end
            end

            printstyled(io, "::", MuTypes.shorten_str(inferred_type), "\n", bold=true, color=color)
        else
            println(io, " ")
        end 
    end

    printstyled(io, "=> ", MuTypes.shorten_str(lookup(frame.outputs[end], MuAST.RETURN_IDENT)), "\n", bold=true, color=:green)
end


end