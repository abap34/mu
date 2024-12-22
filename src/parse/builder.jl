OP_MAP = Dict(
    "+" => "add",
    "-" => "sub",
    "*" => "mul",
    "/" => "div",
    "%" => "mod",
    "==" => "eq",
    "!=" => "neq",
    "<" => "lt",
    ">" => "gt",
    "<=" => "le",
    ">=" => "ge",
)

recjoin(arr::AbstractArray) = join(recjoin.(arr))
recjoin(s::AbstractString) = s

build_bool(w::AbstractString) = w == "true"

build_str(w::AbstractArray) = recjoin(w[2])

build_int(w::AbstractString) = Base.parse(Int, w)
build_int(w::AbstractArray) = build_int(recjoin(w))

build_float(w::AbstractString) = Base.parse(Float64, w)
build_float(w::AbstractArray) = build_float(recjoin(w))


function build_ident(w)
    if w == "true"
        return true
    elseif w == "false"
        return false
    end

    return MuAST.Ident(String(w[2]))
end

function build_array(w::AbstractArray)
    array_body = w[2]
    value = [array_body[1], [x[2] for x in array_body[2]]...]
    return value
end

function build_matrix(w::AbstractArray)
    first_row = w[2]
    rest_rows = w[3:end-1][1]
    result = [[first_row[1], [x[2] for x in first_row[2]]...],]

    n_col = length(result[1])

    for row in rest_rows
        row_arr = build_array(row)
        if length(row_arr) != n_col
            error("All rows in a matrix must have the same number of columns")
        end
        push!(result, row_arr)
    end

    # make [1; 2; 3; 4] as Vector
    if n_col == 1
        return [result[i][begin] for i in eachindex(result)]
    else
        return stack(result, dims=1)
    end
end

function build_unary(w::AbstractArray)
    op, expr = w
    if op == ["-"]
        return MuAST.Expr(:call, [MuAST.Ident("sub"), expr])
    else
        return expr
    end
end


function build_binop(w::AbstractArray)
    lhs = w[1]
    for ex in w[2]
        op, rhs = ex
        lhs = MuAST.Expr(:call, [MuAST.Ident(OP_MAP[op]), lhs, rhs])
    end
    return lhs
end


function build_assign(w::AbstractArray)
    ident = w[1]
    expr = w[3]
    return MuAST.Expr(:assign, [ident, expr])
end


function build_call(w::AbstractArray)
    name = w[1]
    args = w[3][1]
    if isempty(args)
        return MuAST.Expr(:call, [name])
    end
    return MuAST.Expr(:call, [name, args...])
end


function build_args(w::AbstractArray)
    if isempty(w)
        return []
    end
    args = Any[w[1][1],]
    restargs = w[1][2]
    for arg in restargs
        push!(args, arg[2])
    end
    return args
end


function build_seq(w::AbstractArray)
    bodies = w[2]
    return MuAST.Expr(:block, [bodies...])
end


function build_if(w::AbstractArray)
    cand = w[3]
    body = w[5]
    elsebody = w[6]

    haselse = !isempty(elsebody)

    if haselse
        return MuAST.Expr(:if, [cand, body, elsebody[1][2]])
    else
        return MuAST.Expr(:if, [cand, body])
    end
end


function build_argnames(w)
    args = Any[w[1],]
    restargs = w[2]
    for arg in restargs
        push!(args, arg[2])
    end
    return args
end


function build_function(w)
    name = w[2]
    args = w[4]
    body = w[6]
    return MuAST.Expr(:function, [MuAST.Expr(:call, [name, args...]), body])
end


function build_while(w)
    cond = w[3]
    body = w[5]
    return MuAST.Expr(:while, [cond, body])
end

function build_return(w)
    return MuAST.Expr(:return, [w[2]])
end


function build_program(w)
    exprs = filter(x -> x !== nothing, w)
    return exprs
end
