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
- [ニューラルネットワークの訓練](example/nn.mu)

例えば、 `example/nn.mu`　から以下のような型推論の結果を得ることができます。

```
julia> ast = MuCore.parse_file("example/nn.mu");

julia> lowerd = MuCore.lowering(ast);

julia> mt = MuBase.load_base();

julia> MuCore.MuInterpreter.load!(mt, lowerd);

julia> train_mi = lowerd[end - 1]
function train(x::mu.MuCore.MuTypes.Array{mu.MuCore.MuTypes.Float, 1}, y::mu.MuCore.MuTypes.Array{mu.MuCore.MuTypes.Float, 1}, epochs::mu.MuCore.MuTypes.Int, learning_rate::mu.MuCore.MuTypes.Float)

| idx |  instrtype | instr
| --- | ---------- | ----------------------------------------
|   1 |     ASSIGN | w1 = [0.2, -0.2, 0.3, 0.3, -0.5, 0.6, -0.7, 0.8, 0.4, 0.1]
|   2 |     ASSIGN | b1 = [-0.4, 0.2, -0.3, 0.4, 0.1, -0.6, 0.5, 0.8, 0.2, 0.1]
|   3 |     ASSIGN | w2 = [0.3, -0.1, 0.3, 0.4, 0.5, -0.6, 0.7, 0.8, -0.9, 0.1]
|   4 |     ASSIGN | b2 = 0.2
|   5 |     ASSIGN | epoch = 1
|   6 |      LABEL | LABEL #42
|   7 |     ASSIGN | %207 = (GCALL le epoch epochs)
|   8 |  GOTOIFNOT | GOTO #43 IF NOT %207
|   9 |     ASSIGN | loss_sum = 0.0
|  10 |     ASSIGN | dw1_acc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
|  11 |     ASSIGN | db1_acc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
|  12 |     ASSIGN | dw2_acc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
|  13 |     ASSIGN | db2_acc = 0.0
|  14 |     ASSIGN | j = 1
|  15 |     ASSIGN | %208 = (GCALL size x)
|  16 |     ASSIGN | count = (GCALL get %208 1)
|  17 |      LABEL | LABEL #44
|  18 |     ASSIGN | %209 = (GCALL le j count)
|  19 |  GOTOIFNOT | GOTO #45 IF NOT %209
|  20 |     ASSIGN | _x = (GCALL get x j)
|  21 |     ASSIGN | _y = (GCALL get y j)
|  22 |     ASSIGN | yhat = (GCALL forward _x w1 b1 w2 b2)
|  23 |     ASSIGN | loss = (GCALL square_error _y yhat)
|  24 |     ASSIGN | loss_sum = (GCALL add loss_sum loss)
|  25 |     ASSIGN | dloss = (GCALL square_error_derivative _y yhat)
|  26 |     ASSIGN | dz2 = dloss
|  27 |     ASSIGN | %212 = (GCALL mul w1 _x)
|  28 |     ASSIGN | %211 = (GCALL add %212 b1)
|  29 |     ASSIGN | %210 = (GCALL sigmoid %211)
|  30 |     ASSIGN | dw2_ = (GCALL mul dz2 %210)
|  31 |     ASSIGN | db2_ = dz2
|  32 |     ASSIGN | da1 = (GCALL mul dz2 w2)
|  33 |     ASSIGN | %215 = (GCALL mul w1 _x)
|  34 |     ASSIGN | %214 = (GCALL add %215 b1)
|  35 |     ASSIGN | %213 = (GCALL sigmoid_derivative %214)
|  36 |     ASSIGN | dz1 = (GCALL mul da1 %213)
|  37 |     ASSIGN | dw1_ = (GCALL mul dz1 _x)
|  38 |     ASSIGN | db1_ = dz1
|  39 |     ASSIGN | dw1_acc = (GCALL add dw1_acc dw1_)
|  40 |     ASSIGN | db1_acc = (GCALL add db1_acc db1_)
|  41 |     ASSIGN | dw2_acc = (GCALL add dw2_acc dw2_)
|  42 |     ASSIGN | db2_acc = (GCALL add db2_acc db2_)
|  43 |     ASSIGN | j = (GCALL add j 1)
|  44 |       GOTO | GOTO #44
|  45 |      LABEL | LABEL #45
|  46 |     ASSIGN | %216 = (GCALL div 1.0 count)
|  47 |     ASSIGN | dw1_acc = (GCALL mul dw1_acc %216)
|  48 |     ASSIGN | %217 = (GCALL div 1.0 count)
|  49 |     ASSIGN | db1_acc = (GCALL mul db1_acc %217)
|  50 |     ASSIGN | %218 = (GCALL div 1.0 count)
|  51 |     ASSIGN | dw2_acc = (GCALL mul dw2_acc %218)
|  52 |     ASSIGN | db2_acc = (GCALL div db2_acc count)
|  53 |     ASSIGN | %219 = (GCALL mul learning_rate dw1_acc)
|  54 |     ASSIGN | w1 = (GCALL sub w1 %219)
|  55 |     ASSIGN | %220 = (GCALL mul learning_rate db1_acc)
|  56 |     ASSIGN | b1 = (GCALL sub b1 %220)
|  57 |     ASSIGN | %221 = (GCALL mul learning_rate dw2_acc)
|  58 |     ASSIGN | w2 = (GCALL sub w2 %221)
|  59 |     ASSIGN | %222 = (GCALL mul learning_rate db2_acc)
|  60 |     ASSIGN | b2 = (GCALL sub b2 %222)
|  61 |     ASSIGN | %223 = (GCALL div loss_sum count)
|  62 |     ASSIGN | _ = (GCALL log epoch %223)
|  63 |     ASSIGN | %225 = (GCALL mod epoch 100)
|  64 |     ASSIGN | %224 = (GCALL eq %225 0)
|  65 |  GOTOIFNOT | GOTO #46 IF NOT %224
|  66 |     ASSIGN | _ = (GCALL test 0.0 w1 b1 w2 b2)
|  67 |     ASSIGN | %227 = (GCALL pi)
|  68 |     ASSIGN | %226 = (GCALL div %227 4)
|  69 |     ASSIGN | _ = (GCALL test %226 w1 b1 w2 b2)
|  70 |     ASSIGN | %229 = (GCALL pi)
|  71 |     ASSIGN | %228 = (GCALL div %229 2)
|  72 |     ASSIGN | _ = (GCALL test %228 w1 b1 w2 b2)
|  73 |     ASSIGN | %232 = (GCALL pi)
|  74 |     ASSIGN | %231 = (GCALL mul 3 %232)
|  75 |     ASSIGN | %230 = (GCALL div %231 4)
|  76 |     ASSIGN | _ = (GCALL test %230 w1 b1 w2 b2)
|  77 |     ASSIGN | %233 = (GCALL pi)
|  78 |     ASSIGN | _ = (GCALL test %233 w1 b1 w2 b2)
|  79 |      LABEL | LABEL #46
|  80 |     ASSIGN | epoch = (GCALL add epoch 1)
|  81 |       GOTO | GOTO #42
|  82 |      LABEL | LABEL #43
|  83 |     ASSIGN | _ = (GCALL print "w1: ")
|  84 |     ASSIGN | _ = (GCALL println w1)
|  85 |     ASSIGN | _ = (GCALL print "b1: ")
|  86 |     ASSIGN | _ = (GCALL println b1)
|  87 |     ASSIGN | _ = (GCALL print "w2: ")
|  88 |     ASSIGN | _ = (GCALL println w2)
|  89 |     ASSIGN | _ = (GCALL print "b2: ")
|  90 |     ASSIGN | _ = (GCALL println b2)
|  91 |     ASSIGN | _ = (GCALL test 0.0 w1 b1 w2 b2)
|  92 |     ASSIGN | %235 = (GCALL pi)
|  93 |     ASSIGN | %234 = (GCALL div %235 4)
|  94 |     ASSIGN | _ = (GCALL test %234 w1 b1 w2 b2)
|  95 |     ASSIGN | %237 = (GCALL pi)
|  96 |     ASSIGN | %236 = (GCALL div %237 2)
|  97 |     ASSIGN | _ = (GCALL test %236 w1 b1 w2 b2)
|  98 |     ASSIGN | %240 = (GCALL pi)
|  99 |     ASSIGN | %239 = (GCALL mul 3 %240)
| 100 |     ASSIGN | %238 = (GCALL div %239 4)
| 101 |     ASSIGN | _ = (GCALL test %238 w1 b1 w2 b2)
| 102 |     ASSIGN | %241 = (GCALL pi)
| 103 |     ASSIGN | _ = (GCALL test %241 w1 b1 w2 b2)
| 104 |     ASSIGN | %ret = 0
| 105 |       GOTO | GOTO RETURN
| 106 |      LABEL | LABEL RETURN
| 107 |     RETURN | RETURN %ret

end


julia> frame = MuCore.MuTypeInf.infer(train_mi, argtypes=[MuCore.MuTypes.Array{MuCore.MuTypes.Float, 1}, MuCore.MuTypes.Array{MuCore.MuTypes.Float, 1}, MuCore.MuTypes.Int, MuCore.MuTypes.Float], mt=mt);

julia> MuCore.MuTypeInf.show_typing(train_mi, frame)
| idx |  instrtype | instr
| --- | ---------- | ----------------------------------------
|   1 |     ASSIGN | w1 = [0.2, -0.2, 0.3, 0.3, -0.5, 0.6, -0.7, 0.8, 0.4, 0.1]::Array{Float, 1}
|   2 |     ASSIGN | b1 = [-0.4, 0.2, -0.3, 0.4, 0.1, -0.6, 0.5, 0.8, 0.2, 0.1]::Array{Float, 1}
|   3 |     ASSIGN | w2 = [0.3, -0.1, 0.3, 0.4, 0.5, -0.6, 0.7, 0.8, -0.9, 0.1]::Array{Float, 1}
|   4 |     ASSIGN | b2 = 0.2::Float
|   5 |     ASSIGN | epoch = 1::Int
|   6 |      LABEL | LABEL #42
|   7 |     ASSIGN | %207 = (GCALL le epoch epochs)::Bool
|   8 |  GOTOIFNOT | GOTO #43 IF NOT %207
|   9 |     ASSIGN | loss_sum = 0.0::Float
|  10 |     ASSIGN | dw1_acc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]::Array{Float, 1}
|  11 |     ASSIGN | db1_acc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]::Array{Float, 1}
|  12 |     ASSIGN | dw2_acc = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]::Array{Float, 1}
|  13 |     ASSIGN | db2_acc = 0.0::Float
|  14 |     ASSIGN | j = 1::Int
|  15 |     ASSIGN | %208 = (GCALL size x)::Tuple{Int}
|  16 |     ASSIGN | count = (GCALL get %208 1)::Int
|  17 |      LABEL | LABEL #44
|  18 |     ASSIGN | %209 = (GCALL le j count)::Bool
|  19 |  GOTOIFNOT | GOTO #45 IF NOT %209
|  20 |     ASSIGN | _x = (GCALL get x j)::Float
|  21 |     ASSIGN | _y = (GCALL get y j)::Float
|  22 |     ASSIGN | yhat = (GCALL forward _x w1 b1 w2 b2)::Float
|  23 |     ASSIGN | loss = (GCALL square_error _y yhat)::Float
|  24 |     ASSIGN | loss_sum = (GCALL add loss_sum loss)::Float
|  25 |     ASSIGN | dloss = (GCALL square_error_derivative _y yhat)::Float
|  26 |     ASSIGN | dz2 = dloss::Float
|  27 |     ASSIGN | %212 = (GCALL mul w1 _x)::Array{Float, 1}
|  28 |     ASSIGN | %211 = (GCALL add %212 b1)::Array{Float, 1}
|  29 |     ASSIGN | %210 = (GCALL sigmoid %211)::Array{Float, 1}
|  30 |     ASSIGN | dw2_ = (GCALL mul dz2 %210)::Array{Float, 1}
|  31 |     ASSIGN | db2_ = dz2::Float
|  32 |     ASSIGN | da1 = (GCALL mul dz2 w2)::Array{Float, 1}
|  33 |     ASSIGN | %215 = (GCALL mul w1 _x)::Array{Float, 1}
|  34 |     ASSIGN | %214 = (GCALL add %215 b1)::Array{Float, 1}
|  35 |     ASSIGN | %213 = (GCALL sigmoid_derivative %214)::Array{Float, 1}
|  36 |     ASSIGN | dz1 = (GCALL mul da1 %213)::Array{Float, 1}
|  37 |     ASSIGN | dw1_ = (GCALL mul dz1 _x)::Array{Float, 1}
|  38 |     ASSIGN | db1_ = dz1::Array{Float, 1}
|  39 |     ASSIGN | dw1_acc = (GCALL add dw1_acc dw1_)::Array{Float, 1}
|  40 |     ASSIGN | db1_acc = (GCALL add db1_acc db1_)::Array{Float, 1}
|  41 |     ASSIGN | dw2_acc = (GCALL add dw2_acc dw2_)::Array{Float, 1}
|  42 |     ASSIGN | db2_acc = (GCALL add db2_acc db2_)::Float
|  43 |     ASSIGN | j = (GCALL add j 1)::Int
|  44 |       GOTO | GOTO #44
|  45 |      LABEL | LABEL #45
|  46 |     ASSIGN | %216 = (GCALL div 1.0 count)::Float
|  47 |     ASSIGN | dw1_acc = (GCALL mul dw1_acc %216)::Array{Float, 1}
|  48 |     ASSIGN | %217 = (GCALL div 1.0 count)::Float
|  49 |     ASSIGN | db1_acc = (GCALL mul db1_acc %217)::Array{Float, 1}
|  50 |     ASSIGN | %218 = (GCALL div 1.0 count)::Float
|  51 |     ASSIGN | dw2_acc = (GCALL mul dw2_acc %218)::Array{Float, 1}
|  52 |     ASSIGN | db2_acc = (GCALL div db2_acc count)::Float
|  53 |     ASSIGN | %219 = (GCALL mul learning_rate dw1_acc)::Array{Float, 1}
|  54 |     ASSIGN | w1 = (GCALL sub w1 %219)::Array{Float, 1}
|  55 |     ASSIGN | %220 = (GCALL mul learning_rate db1_acc)::Array{Float, 1}
|  56 |     ASSIGN | b1 = (GCALL sub b1 %220)::Array{Float, 1}
|  57 |     ASSIGN | %221 = (GCALL mul learning_rate dw2_acc)::Array{Float, 1}
|  58 |     ASSIGN | w2 = (GCALL sub w2 %221)::Array{Float, 1}
|  59 |     ASSIGN | %222 = (GCALL mul learning_rate db2_acc)::Float
|  60 |     ASSIGN | b2 = (GCALL sub b2 %222)::Float
|  61 |     ASSIGN | %223 = (GCALL div loss_sum count)::Float
|  62 |     ASSIGN | _ = (GCALL log epoch %223)
|  63 |     ASSIGN | %225 = (GCALL mod epoch 100)::Int
|  64 |     ASSIGN | %224 = (GCALL eq %225 0)::Bool
|  65 |  GOTOIFNOT | GOTO #46 IF NOT %224
|  66 |     ASSIGN | _ = (GCALL test 0.0 w1 b1 w2 b2)
|  67 |     ASSIGN | %227 = (GCALL pi)::Float
|  68 |     ASSIGN | %226 = (GCALL div %227 4)::Float
|  69 |     ASSIGN | _ = (GCALL test %226 w1 b1 w2 b2)
|  70 |     ASSIGN | %229 = (GCALL pi)::Float
|  71 |     ASSIGN | %228 = (GCALL div %229 2)::Float
|  72 |     ASSIGN | _ = (GCALL test %228 w1 b1 w2 b2)
|  73 |     ASSIGN | %232 = (GCALL pi)::Float
|  74 |     ASSIGN | %231 = (GCALL mul 3 %232)::Float
|  75 |     ASSIGN | %230 = (GCALL div %231 4)::Float
|  76 |     ASSIGN | _ = (GCALL test %230 w1 b1 w2 b2)
|  77 |     ASSIGN | %233 = (GCALL pi)::Float
|  78 |     ASSIGN | _ = (GCALL test %233 w1 b1 w2 b2)
|  79 |      LABEL | LABEL #46
|  80 |     ASSIGN | epoch = (GCALL add epoch 1)::Int
|  81 |       GOTO | GOTO #42
|  82 |      LABEL | LABEL #43
|  83 |     ASSIGN | _ = (GCALL print "w1: ")
|  84 |     ASSIGN | _ = (GCALL println w1)
|  85 |     ASSIGN | _ = (GCALL print "b1: ")
|  86 |     ASSIGN | _ = (GCALL println b1)
|  87 |     ASSIGN | _ = (GCALL print "w2: ")
|  88 |     ASSIGN | _ = (GCALL println w2)
|  89 |     ASSIGN | _ = (GCALL print "b2: ")
|  90 |     ASSIGN | _ = (GCALL println b2)
|  91 |     ASSIGN | _ = (GCALL test 0.0 w1 b1 w2 b2)
|  92 |     ASSIGN | %235 = (GCALL pi)::Float
|  93 |     ASSIGN | %234 = (GCALL div %235 4)::Float
|  94 |     ASSIGN | _ = (GCALL test %234 w1 b1 w2 b2)
|  95 |     ASSIGN | %237 = (GCALL pi)::Float
|  96 |     ASSIGN | %236 = (GCALL div %237 2)::Float
|  97 |     ASSIGN | _ = (GCALL test %236 w1 b1 w2 b2)
|  98 |     ASSIGN | %240 = (GCALL pi)::Float
|  99 |     ASSIGN | %239 = (GCALL mul 3 %240)::Float
| 100 |     ASSIGN | %238 = (GCALL div %239 4)::Float
| 101 |     ASSIGN | _ = (GCALL test %238 w1 b1 w2 b2)
| 102 |     ASSIGN | %241 = (GCALL pi)::Float
| 103 |     ASSIGN | _ = (GCALL test %241 w1 b1 w2 b2)
| 104 |     ASSIGN | %ret = 0::Int
| 105 |       GOTO | GOTO RETURN
| 106 |      LABEL | LABEL RETURN
| 107 |     RETURN | RETURN %ret
=> Int
```