using PEG

include("ast.jl")

@rule bool = (
    r"true"p,
    r"false"p
) |> build_bool


@rule str = (
    "\"" & r"[^\"]"[*] & "\""
) |> build_str


@rule int = (
    r"0"p,
    r"[1-9]" & r"[0-9]*"p
) |> build_int


@rule float = (
    r"[0-9]+" & r"\." & r"[0-9]+"p
) |> build_float


@rule num = float, int


@rule ident = (
    r"^(?!.*(function|if|else|while|return|function|return|true|false))[a-zA-Z_][a-zA-Z0-9_]*"p 
) |> build_ident


@rule array_contents = (
    expr & (r","p & expr)[*]
) 

@rule array = (
    r"\["p & array_contents & r"\]"p
) |> build_array


@rule matrix = (
    r"\["p & array_contents & (r";"p & array_contents)[*] & r"\]"p
) |> build_matrix


@rule primary = (
    call,    
    num, 
    str,
    bool,
    ident, 
    array,
    matrix,
) 

@rule unary = (
    r"-"[:?] & primary
) |> build_unary


@rule mul = (
    unary & ((r"\*"p, r"/"p, r"%"p) & unary)[*]
) |> build_binop


@rule add = (
    mul & ((r"\+"p, r"-"p) & mul)[*]
) |> build_binop


@rule relational = (
    add & ((r"!="p, r"<="p, r"=<"p, r">"p, r"<"p, r"=="p) & add)[*]
) |> build_binop


@rule assign = (
    ident & r"="p & expr
) |> build_assign


@rule args = (
    "" & (expr & (r","p & expr)[*])[:?]
) |> build_args


@rule call = (
    ident & r"\("p & args & r"\)"p
) |> build_call


@rule seq = (
    r"\{"p & expr[*] & r"\}"p
) |> build_seq


@rule _if = (
    r"if"p & r"\("p & expr & r"\)"p & seq & (r"elseif"p & r"\("p & expr & r"\)"p & seq)[*] & (r"else"p & seq)[:?]
) |> build_if


@rule argnames = (
    ident & (r","p & ident)[*]
) |> build_argnames


@rule _function = (
    r"function"p & ident & r"\("p & argnames & r"\)"p & seq
) |> build_function


@rule _while = (
    r"while"p & r"\("p & expr & r"\)"p & seq
) |> build_while


@rule _return = (
    r"return"p & expr
) |> build_return


@rule expr = assign, call, relational, _if, _while, _function, seq, _return

@rule program = expr[*] |> build_program

