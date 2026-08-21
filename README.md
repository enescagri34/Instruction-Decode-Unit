# RISC-V Instruction Decode Unit

Bu proje, Verilog HDL kullanılarak geliştirilen **modüler bir RISC-V Instruction Decode Unit (IDU)** tasarımıdır.

Instruction Decode Unit, işlemciye gelen 32 bitlik RISC-V makine komutunu analiz ederek komut alanlarını ayırır, komut tipini belirler, Immediate değerini üretir ve işlemcinin diğer birimlerine gönderilecek kontrol sinyallerini oluşturur.

---

# Projenin Amacı

Bu projenin amacı temel seviyede çalışan bir RISC-V Instruction Decode Unit tasarlamaktır.

Gerçekleştirilen işlemler:

- 32 bit instruction çözümleme
- Opcode ayrıştırma
- Register alanlarının ayrıştırılması
- Instruction Type belirleme
- Immediate üretme
- ALU kontrol sinyali üretme
- Register kontrol sinyali üretme
- Bellek kontrol sinyali üretme
- Branch kontrol sinyali üretme
- Illegal Instruction tespiti

---

# Desteklenen Komutlar

| Komut | Açıklama | Destek |
|--------|----------|---------|
| ADD | Register Toplama | ✅ |
| SUB | Register Çıkarma | ✅ |
| ADDI | Immediate Toplama | ✅ |
| LW | Load Word | ✅ |
| SW | Store Word | ✅ |
| BEQ | Branch if Equal | ✅ |

---

# Sistem Mimarisi

```
                 32-bit Instruction
                         │
                         ▼
            +--------------------------+
            |   Instruction Decoder    |
            +--------------------------+
                         │
     ┌───────────────────┼───────────────────┐
     ▼                   ▼                   ▼
Field Extractor   Immediate Generator   Control Unit
     │                   │                   │
     └───────────────────┴───────────────────┘
                         │
                         ▼
                  Decoder Outputs
```

---

# Modüller

## instruction_decoder.v

Projenin üst modülüdür.

Diğer bütün modülleri birbirine bağlar.

---

## field_extractor.v

Instruction içerisinden aşağıdaki alanları ayırır.

```
opcode
rd
rs1
rs2
funct3
funct7
```

---

## immediate_generator.v

Instruction tipine göre Immediate değerini üretir.

Desteklenen Immediate formatları:

- I-Type
- S-Type
- B-Type

Negatif Immediate değerlerinde Sign Extension uygulanmaktadır.

---

## control_unit.v

Opcode, Funct3 ve Funct7 alanlarını kullanarak aşağıdaki kontrol sinyallerini üretir.

- Instruction Type
- ALU Control
- Register Write
- Memory Read
- Memory Write
- ALU Source
- Branch
- Illegal Instruction

---

# Çıkışlar

| Çıkış | Açıklama |
|--------|----------|
| opcode | Opcode alanı |
| rd | Destination Register |
| rs1 | Source Register 1 |
| rs2 | Source Register 2 |
| funct3 | Funct3 alanı |
| funct7 | Funct7 alanı |
| instruction_type | Komut tipi |
| alu_control | ALU kontrol sinyali |
| immediate | Sign Extended Immediate |
| reg_write | Register Write Enable |
| mem_read | Memory Read Enable |
| mem_write | Memory Write Enable |
| alu_src | ALU ikinci operand seçimi |
| branch | Branch Enable |
| illegal_instruction | Geçersiz komut göstergesi |

---

# Instruction Type Kodları

| Kod | Tür |
|------|------|
| 000 | Unknown |
| 001 | R-Type |
| 010 | I-Type |
| 011 | Load |
| 100 | Store |
| 101 | Branch |

---

# ALU Control Kodları

| Kod | İşlem |
|------|--------|
| 000 | ADD |
| 001 | SUB |

---

# Testbench'ler

Projede iki farklı testbench bulunmaktadır.

## instruction_decoder_tb.v

Otomatik doğrulama testbenchidir.

Özellikleri:

- 8 farklı test
- PASS / FAIL çıktısı
- Otomatik kontrol
- Test özeti

Örnek çıktı:

```
Passed Tests : 8

Failed Tests : 0

RESULT

ALL TESTS PASSED
```

---

## demo_tb.v

Sunum amacıyla hazırlanmıştır.

Her komutu tek tek çözümler.

Gösterilen bilgiler:

- Assembly komutu
- Machine Code
- Opcode
- Funct3
- Funct7
- Instruction Type
- ALU Operation
- Register bilgileri
- Immediate
- Kontrol sinyalleri

Bu testbench sunum sırasında sistemin çalışma mantığını göstermek amacıyla hazırlanmıştır.

---

# Proje Yapısı

```
BILGOR_PROJE
│
├── docs
│
├── output
│   ├── demo_sim
│   └── test_sim
│
├── src
│   ├── instruction_decoder.v
│   ├── field_extractor.v
│   ├── control_unit.v
│   └── immediate_generator.v
│
├── tb
│   ├── instruction_decoder_tb.v
│   └── demo_tb.v
│
├── wave
│   ├── decoder.vcd
│   └── demo.vcd
│
└── README.md
```

---

# Derleme

## Otomatik Test

```powershell
iverilog -Wall -o output/test_sim src/field_extractor.v src/immediate_generator.v src/control_unit.v src/instruction_decoder.v tb/instruction_decoder_tb.v
```

## Demo

```powershell
iverilog -Wall -o output/demo_sim src/field_extractor.v src/immediate_generator.v src/control_unit.v src/instruction_decoder.v tb/demo_tb.v
```

---

# Çalıştırma

## Otomatik Test

```powershell
vvp output/test_sim
```

## Demo

```powershell
vvp output/demo_sim
```

---

# Waveform

GTKWave ile waveform görüntülemek için:

```powershell
gtkwave wave/decoder.vcd
```

veya

```powershell
gtkwave wave/demo.vcd
```

---

# Test Edilen Komutlar

```assembly
ADD  x5, x6, x7

SUB  x8, x5, x6

ADDI x5, x6, 10

ADDI x5, x6, -4

LW   x5, 4(x6)

SW   x5, 4(x6)

BEQ  x5, x6, 8

ILLEGAL OPCODE
```

---

# Kullanılan Araçlar

- Verilog HDL
- Visual Studio Code
- Icarus Verilog
- GTKWave

---

# Gelecekte Yapılabilecek Geliştirmeler

Bu proje temel seviyede bir Instruction Decode Unit tasarımıdır.

İlerleyen sürümlerde aşağıdaki geliştirmeler yapılabilir:

- AND
- OR
- XOR
- SLT
- SLTI
- LUI
- AUIPC
- JAL
- JALR
- Tam RV32I desteği
- FPGA üzerinde gerçekleme
- Pipeline mimarisine entegrasyon

---

# Sonuç

Bu proje kapsamında modüler yapıda çalışan temel seviyede bir **RISC-V Instruction Decode Unit** geliştirilmiştir.

Sistem;

- Instruction alanlarını ayrıştırmakta,
- Instruction tipini belirlemekte,
- Immediate üretmekte,
- Kontrol sinyallerini oluşturmaktadır.

Proje, otomatik doğrulama testbench'i ile başarıyla test edilmiş ve tüm testlerden başarılı sonuç almıştır.

Ayrıca sunum amacıyla hazırlanan demo testbench sayesinde decoder'ın çalışma mantığı adım adım gösterilebilmektedir.
