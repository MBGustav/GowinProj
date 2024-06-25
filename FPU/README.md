# Implementacao de uma Unid. Ponto Flutuante (FPU) 


## Metodo de Representacao

``` 
FLOAT POINT OPERATION 32bits - IEEE 754
|   31   | 30 ... 23  |  22 ... 0 |
| signal |  exponent  | fraction  |
```

## Excecoes de Operacoes

Levando como base a arquitetura arm para operacoes do tipo Float, temos interrupcoes que sao elencadas por conta de operacoes invalidas . Para este exemplo, faremos uso dos seus nomes para o projeto.


[awaw](https://infocenter.nordicsemi.com/index.jsp?topic=%2Fps_nrf5340%2Ffpu.html)

|Instr|Descr|Algebra|
|-|-|-|
|flw             |Flt Load Word         | rd = M[rs1 + imm]
|fsw             |Flt Store Word        | M[rs1 + imm] = rs2
|fmadd.s         |Flt Fused Mul-Add     | rd = rs1 * rs2 + rs3
|fmsub.s         |Flt Fused Mul-Sub     | rd = rs1 * rs2 - rs3
|fnmadd.s        |Flt Neg Fused Mul-Add | rd = -rs1 * rs2 + rs3
|fnmsub.s        |Flt Neg Fused Mul-Sub | rd = -rs1 * rs2 - rs3
|fadd.s          |Flt Add               | rd = rs1 + rs2
|fsub.s          |Flt Sub               | rd = rs1 - rs2
|fmul.s          |Flt Mul               | rd = rs1 * rs2
|fdiv.s          |Flt Div               | rd = rs1 / rs2
|fsqrt.s         |Flt Square Root       | rd = sqrt(rs1)
|fsgnj.s         |Flt Sign Injection    | rd = abs(rs1) * sgn(rs2)
|fsgnjn.s        |Flt Sign Neg Injection| rd = abs(rs1) * -sgn(rs2)
|fsgnjx.s        |Flt Sign Xor Injection| rd = rs1 * sgn(rs2)
|fmin.s          |Flt Minimum           | rd = min(rs1, rs2)
|fmax.s          |Flt Maximum           | rd = max(rs1, rs2)
|fcvt.s.w        |Flt Conv from Sign Int| rd = (float) rs1
|fcvt.s.wu       |Flt Conv from Uns Int | rd = (float) rs1
|fcvt.w.s        |Flt Convert to Int    | rd = (int32_t) rs1
|fcvt.wu.s       |Flt Convert to Int    | rd = (uint32_t) rs1
|fmv.x.w         |Move Float to Int     | rd = * ((int*) &rs1)
|fmv.w.x         |Move Int to Float     | rd = * ((float*) &rs1)
|feq.s           |Float Equality        | rd = (rs1 == rs2) ? 1 : 0
|flt.s           |Float Less Than       | rd = (rs1 < rs2) ? 1 : 0
|fle.s           |Float Less / Equal    | rd = (rs1 <= rs2) ? 1 : 0
|fclass.s        |Float Classify        | rd = 0..9


<!-- FPUIOC: INVALIDOPERATION
FPUIDC: DENORMALINPUT
FPUOFC: OVERFLOW
FPUUFC: UNDERFLOW
FPUDZC: DIVIDEBYZERO
FPUIXC: INEXACT -->

# Proximos Passos

Implementacao de Interrupcao de Sistemas, com base na arquitetura RV.
|Signal Output |Description|
|-|-|
|**FPUIOC** | Floating-point inexact exception        |
|**FPUIDC** | Floating-point input denormal exception |
|**FPUOFC** | Floating-point overflow exception       |
|**FPUUFC** | Floating-point underflow exception      |
|**FPUDZC** | Floating-point divide-by-zero exception |
|**FPUIXC** | Invalid operation                       |