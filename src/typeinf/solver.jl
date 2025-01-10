function build_pred(ci::MuIR.CodeInfo)
    n = length(ci)
    pred = [Int[] for _ in 1:n]
    label_to_pc = Dict{Int,Int}()

    # build label_to_pc 
    for (i, instr) in enumerate(ci)
        if instr.irtype == MuIR.LABEL
            label = MuIR.get_label(instr)
            label_to_pc[label] = i
        end
    end

    for (i, instr) in enumerate(ci)
        if instr.irtype == MuIR.ASSIGN || instr.irtype == MuIR.LABEL
            push!(pred[i+1], i)
        elseif instr.irtype == MuIR.GOTO
            dest = MuIR.get_dest(instr)
            push!(pred[label_to_pc[dest]], i)
        elseif instr.irtype == MuIR.GOTOIFNOT
            dest = MuIR.get_dest(instr)
            push!(pred[i+1], i)
            push!(pred[label_to_pc[dest]], i)
        elseif instr.irtype == MuIR.RETURN
            continue  # RETURN must be the last instruction.
        else
            throw(ArgumentError("Unknown IRType: $(instr.irtype)"))
        end
    end

    return pred
end

function ∇(new_output, current_output)
    return new_output
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

