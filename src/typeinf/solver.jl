function build_pred(ci::MuIR.CodeInfo)
    n = length(ci)
    pred = [Int[] for _ in 1:n]
    label_to_pc = Dict{Int,Int}()

    # build label_to_pc 
    for (i, instr) in enumerate(ci)
        if instr.instrtype == MuIR.LABEL
            label = MuIR.get_label(instr)
            label_to_pc[label] = i
        end
    end

    for (i, instr) in enumerate(ci)
        if instr.instrtype == MuIR.ASSIGN || instr.instrtype == MuIR.LABEL
            push!(pred[i+1], i)
        elseif instr.instrtype == MuIR.GOTO
            dest = MuIR.get_dest(instr)
            push!(pred[label_to_pc[dest]], i)
        elseif instr.instrtype == MuIR.GOTOIFNOT
            dest = MuIR.get_dest(instr)
            push!(pred[i+1], i)
            push!(pred[label_to_pc[dest]], i)
        elseif instr.instrtype == MuIR.RETURN
            continue  # RETURN must be the last instruction.
        else
            throw(ArgumentError("Unknown InstrType: $(instr.instrtype)"))
        end
    end

    return pred
end

const MAX_PARAMETER_LENGTH = 10
# **Try to** find the minimum supertype of a set of types.
# (This is a very naive implementation, and is not guaranteed to be find the minimum supertype.
#  It is only guaranteed to find a supertype.)
function minimum_supertype(types::Vector{DataType})
    candidates = [
        MuTypes.Real, 
        MuTypes.AbstractString,
        MuTypes.AbstractArray,
        MuTypes.Any
    ]
    for c in candidates
        if all(t -> MuTypes.issubtype(t, c), types)
            return c
        end
    end
    return MuTypes.Any
end

function ∇(new_output, current_output)
    _new_output = copy(new_output)
    for (k, t) in new_output.state
        if MuTypes.parameterlength(t) > MAX_PARAMETER_LENGTH
            _new_output.state[k] = minimum_supertype(MuTypes.expand_types(t))
        end
    end
    return _new_output
end


function ⊔(state1::AbstractState, state2::AbstractState)
    new_state = copy(state1)
    for (ident, value) in state2.state
        if haskey(new_state, ident)
            new_state.state[ident] = MuTypes.jointype(new_state.state[ident], value)
        else
            new_state.state[ident] = value
        end
    end
    return new_state
end

function abstract_interpret(
    mi::MuIR.MethodInstance,
    abstract_semantics::Function,
    ∇::Function;
    initstate::AbstractState=AbstractState(DataType),
)::InferenceFrame
    ci = mi.ci
    n = length(ci)
    pred = build_pred(ci)
    frame = InferenceFrame(initstate, n, mi, ∇)

    while true
        changed = false
        for i in 1:n
            new_input::AbstractState = reduce(⊔, frame.outputs[j] for j in pred[i]; init=copy(initstate))
            try
                new_output::AbstractState = abstract_semantics(ci[i])(new_input)
                changed = update!(frame, i, new_input, new_output)
            catch e
                @error "Failed to interpret instruction: $(ci[i])" exception = e
                rethrow(e)
            end
        end
        if !changed
            break
        end
    end

    return frame
end

