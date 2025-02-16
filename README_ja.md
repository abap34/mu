# mu

[![Build Status](https://github.com/abap34/mu/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/abap34/mu/actions/workflows/CI.yml?query=branch%3Amain)

mu は

- 多重ディスパッチによる generic programming
- 抽象解釈ベースの型解析と、それによるディスパッチのパフォーマンス最適化

が実装されている Experimental なプログラミング言語です。

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
    println(double([1, 2, 3])) // [2, 4, 6]  (dispatch without dynamic method lookup !)
}
```


## Quick Start

```
$ git clone https://github.com/abap34/mu.git
$ cd mu
$ julia --project=.
julia> using mu.MuCore; using mu.MuBase

julia> ast = MuCore.parse_file("example/example.mu");  # parse a file

julia> lowerd = MuCore.lowering(ast);   # lowering

julia> mt = MuBase.load_base(); # get method table with base functions

julia> MuCore.MuInterpreter.load!(mt, lowerd); # load lowered code

julia> MuCore.MuTypeInf.return_type(lowerd[3], argtypes=[MuCore.MuTypes.Array{MuCore.MuTypes.Int, 1}, MuCore.MuTypes.Int], mt=mt)  # inference `binarysearch` return `Int` or `Bool`
mu.MuCore.MuTypes.Union{mu.MuCore.MuTypes.Int, mu.MuCore.MuTypes.Bool}
```


## Installation

## Requirements

実行には Julia 1.11 以上が必要です。

[ダウンロードページ](https://julialang.org/downloads/) か、 [juliaup](https://github.com/JuliaLang/juliaup) を使ってインストールしてください。

## Install

(WIP)

## Usage


### REPL

(WIP)

### Run a script

(WIP)

## Examples

- [FizzBuzz](example/fizzbuzz.mu)
- [多重ディスパッチ](example/multipledispatch.mu)





