using PEG

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
@rule literal = bool, str, num

@rule ident = (
    -(r"^if\s*$"p, r"^else\s*$"p, r"^while\s*$"p, r"^true\s*$"p, r"^false\s*$"p, r"^function\s*$"p, r"^return\s*$"p)
    & r"[a-zA-Z_α-ωΑ-Ω][a-zA-Z_α-ωΑ-Ω0-9]*"p
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
    generics_call,
    literal,
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
    add & ((r"<="p, r">="p, r"<"p, r">"p, r"=="p, r"!="p) & add)[*]
) |> build_binop

@rule and_or = (
    relational & ((r"&&"p, r"\|\|"p) & relational)[*]
) |> build_binop

@rule assign = (
    ident & r"="p & expr
) |> build_assign


@rule actual_args = (
    (expr & (r","p & expr)[*])[:?]
) |> build_actual_args


@rule generics_call = (
    ident & r"\("p & actual_args[:?] & r"\)"p
) |> build_generics_call

@rule builtin_call = (
    "@" & ident & r"\("p & actual_args[:?] & r"\)"p
) |> build_builtin_call

@rule seq = (
    r"\{"p & statement[*] & r"\}"p
) |> build_seq


@rule _if = (
    r"if"p & r"\("p & expr & r"\)"p & seq & (r"else"p & seq)[:?]
) |> build_if


@rule _while = (
    r"while"p & r"\("p & expr & r"\)"p & seq
) |> build_while


@rule type_parameter = (
    primary & (r","p & primary)[*]
) |> build_type_parameter


@rule type = (
    ident & (r"\{"p & type_parameter & r"\}"p)[:?]
) |> build_type

@rule typedident = (
    ident & r"::"p & type
) |> build_typedident

@rule formal_args = (
    typedident & (r","p & typedident)[*]
) |> build_formal_args

@rule _function = (
    r"function"p & ident & r"\("p & formal_args[:?] & r"\)"p & seq
) |> build_function


@rule _return = (
    r"return"p & expr
) |> build_return



@rule expr = builtin_call, generics_call, and_or

@rule statement = _return, _function, assign, _if, _while, seq, expr

@rule program = statement[*] |> build_program

