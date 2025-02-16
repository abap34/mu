# mu

[![Build Status](https://github.com/abap34/mu/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/abap34/mu/actions/workflows/CI.yml?query=branch%3Amain)

<div style="text-align: center;">
     <a href="README.md">English</a> | <a href="README_ja.md">日本語</a>
</div>



**mu** is an experimental programming language that features:

- **Generic programming** enabled by multiple dispatch
- **Abstract interpretation-based type analysis** for optimizing dispatch performance

```js
function double(x::Number){
    return 2 * x
}

function double(x::Array{Int, 1}){
    n = length(x)
    i = 1
    while (i <= n){
        set(x, i, 2 * get(x, i))
        i = i + 1
    }

    return x
}

function main(){
    println(double(3))         // 6
    println(double([1, 2, 3])) // [2, 4, 6]  (dispatch without dynamic method lookup!)
}
```

## Quick Start

```bash
$ git clone https://github.com/abap34/mu.git
$ cd mu
$ julia --project=.
```

```julia
julia> using mu.MuCore; using mu.MuBase

julia> ast = MuCore.parse_file("example/example.mu");  # parse a file

julia> lowerd = MuCore.lowering(ast);   # lowering

julia> mt = MuBase.load_base(); # get method table with base functions

julia> MuCore.MuInterpreter.load!(mt, lowerd); # load lowered code

julia> MuCore.MuTypeInf.return_type(lowerd[3], argtypes=[MuCore.MuTypes.Array{MuCore.MuTypes.Int, 1}, MuCore.MuTypes.Int], mt=mt)  # inference `binarysearch` return `Int` or `Bool`
mu.MuCore.MuTypes.Union{mu.MuCore.MuTypes.Int, mu.MuCore.MuTypes.Bool}
```



## Installation

### Requirements

To run mu, you need Julia version 1.11 or later.

Download Julia from the [official download page](https://julialang.org/downloads/) or install it using [juliaup](https://github.com/JuliaLang/juliaup).

### Install

(WIP)

## Usage

### REPL

(WIP)

### Run a script

(WIP)

## Examples

- [FizzBuzz](example/fizzbuzz.mu)
- [Multiple Dispatch](example/multipledispatch.mu)
