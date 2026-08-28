// --- K.E.N.N.Y. (12-Bit Breadboard Computer) Microcode ---

// Control signals (EEPROM outputs)
const SIGNALS = {
    mari: 0b1110000000000000, // Memory address register in
    iri:  0b1100000000000000, // Instruction register in
    romi: 0b1010000000000000, // Memory in
    pci:  0b1000000000000000, // Program counter in
    // 
    fo:   0b0001110000000000, // Flip out
    iro:  0b0001100000000000, // Instruction register out
    romo: 0b0001010000000000, // Memory out
    pco:  0b0001000000000000, // Program counter out
    // 
    ai:   0b0000001000000000, // A register in
    bi:   0b0000000100000000, // B register in
    sum:  0b0000000010000000, // Adder out
    nand: 0b0000000001000000, // NAND out
    inv:  0b0000000000100000, // Invert flip output
    ci:   0b0000000000010000, // Carry in 
    fi:   0b0000000000001000, // Flip out
    // 
    flag: 0b0000000000000111, // Latch flags
    halt: 0b0000000000000110, // Halt
    ce:   0b0000000000000101, // Count enable
    irr:  0b0000000000000100, // Instruction register reset (clear microcode counter)
    lcd:  0b0000000000000001, // Send adder value to display
    con:  0b0000000000000010, // Enable controller
};

// Simplifies decoding
const DECODE = {
    mari: 0b100000000000000000000,
    iri:  0b010000000000000000000,
    romi: 0b001000000000000000000,
    pci:  0b000100000000000000000,
    // 
    fo:   0b000010000000000000000,
    iro:  0b000001000000000000000,
    romo: 0b000000100000000000000,
    pco:  0b000000010000000000000,
    // 
    ai:   0b000000001000000000000,
    bi:   0b000000000100000000000,
    sum:  0b000000000010000000000,
    nand: 0b000000000001000000000,
    inv:  0b000000000000100000000,
    ci:   0b000000000000010000000,
    fi:   0b000000000000001000000,
    // 
    flag: 0b000000000000000100000,
    halt: 0b000000000000000010000,
    ce:   0b000000000000000001000,
    irr:  0b000000000000000000100,
    lcd:  0b000000000000000000010,
    con:  0b000000000000000000001,
};

// Opcodes 
// Here ? means bit reverse, ie, 0x80c -> 0x301
// Note that in the K language this is "rotate"
const OPCODES = {
    BOOT: 0b000000, // boot 
    ADD:  0b000100, // A+B -> *op
    AWC:  0b001000, // A+B+1 -> *op
    NAN:  0b001100, // !(A&B) -> *op
    FLP:  0b010000, // !*op -> *op
    ROT:  0b010100, // ?*op -> *op
    INC:  0b011000, // *op+1 -> *op
    JMP:  0b011100, // jump to op
    LDA:  0b100000, // *op -> A
    LDB:  0b100100, // *op -> B
    MXX:  0b101000, // *op*2 -> *op
    DXX:  0b101100, // *op/2 -> *op
    LCD:  0b110000, // LCD operation from op
    INP:  0b110100, // bus -> *op
    WRI:  0b111000, // write data
    NOP:  0b111100, // no operation
    // 
    //  : 0b000001, // boot 
    SVP:  0b000101, // *op -> *0xff
    SWP:  0b001001, // *0xff -> *op
    FAN:  0b001101, // flip&*op -> flip
    FAD:  0b010001, // flip+*op -> flip
    FSU:  0b010101, // flip-*op -> flip
    CWF:  0b011001, // compare *op and flip
    JIN:  0b011101, // jump if controller 
    LDF:  0b100001, // *op -> flip
    SAF:  0b100101, // flip -> *op
    FMX:  0b101001, // flip*2 -> flip
    FDX:  0b101101, // flip/2 -> flip
    LCF:  0b110001, // LCD operation from flip
    INF:  0b110101, // bus -> flip
    // :  0b111001, // 
    CLR:  0b111101, // clear all registers
    // 
    //  : 0b000010, // boot 
    PXA:  0b000110, // [*0xff]+*op -> [*0xff], ie, add value at op's memory location to pointer location's value (@0xff).
    PXS:  0b001010, // [*0xff]-*op -> [*0xff]
    FOR:  0b001110, // flip|*op -> flip
    FIN:  0b010010, // flip+1 -> flip
    FDE:  0b010110, // flip-1 -> flip
    CWB:  0b011010, // compare *op and B
    JFO:  0b011110, // jump if flip odd
    AFF:  0b100010, // flip+A -> flip
    BFF:  0b100110, // flip+B -> flip
    FMT:  0b101010, // flip*3 -> flip
    FMV:  0b101110, // flip*5 -> flip
    LFP:  0b110010, // LCD operation from *flip
    // :  0b110110, // 
    // :  0b111010, // 
    // :  0b111110, //
    // 
    //  : 0b000011, // boot 
    PPA:  0b000111, // *0xff+*op -> *0xff, ie, add value at op's memory location to pointer's value (@0xff).
    PPS:  0b001011, // *0xff-*op -> *0xff
    FXO:  0b001111, // flip^*op -> flip
    AIF:  0b010011, // increments A register, adds to flip register until ...
    NGF:  0b010111, // !flip+1 -> flip
    JFM:  0b011011, // jumps PC to op if !(flip&*op)+*op == 0xfff
    JFC:  0b011111, // jump if flip msb == 1
    SRI:  0b100011, // PC+1 -> *op
    SRO:  0b100111, // *op -> PC
    FSS:  0b101011, // ???
    FSX:  0b101111, // ???
    // :  0b110011, // 
    // :  0b110111, // 
    // :  0b111011, // 
    HLT:  0b111111, // halt
};

// EEPROM microcode
// *Most* opcodes perform fetch cycle on steps 0 and 1:
// SIGNALS.pco | SIGNALS.mari,              // Set memory address to program counter
// SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, // Put memory value in instruction register and let PC count
const MICROCODE = {

    [OPCODES.BOOT]: [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        SIGNALS.flag,
        SIGNALS.mari,
        SIGNALS.pci | SIGNALS.ai | SIGNALS.bi | SIGNALS.fi,
        SIGNALS.romo | SIGNALS.iri
    ],
    
    [OPCODES.ADD]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,              
        SIGNALS.sum | SIGNALS.romi | SIGNALS.flag, 
        SIGNALS.irr  
    ],
    
    [OPCODES.AWC]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,              
        SIGNALS.sum | SIGNALS.ci | SIGNALS.romi | SIGNALS.flag, 
        SIGNALS.irr  
    ],

    [OPCODES.NAN]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,              
        SIGNALS.nand | SIGNALS.romi | SIGNALS.flag, 
        SIGNALS.irr  
    ],

    [OPCODES.FLP]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.fi, 
        SIGNALS.fo | SIGNALS.inv | SIGNALS.fi,
        SIGNALS.fo | SIGNALS.romi | SIGNALS.flag,  
        SIGNALS.irr  
    ],

    [OPCODES.ROT]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.fi, 
        SIGNALS.fo | SIGNALS.romi | SIGNALS.flag,  
        SIGNALS.irr  
    ],

    [OPCODES.INC]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.ai, 
        SIGNALS.bi,
        SIGNALS.sum | SIGNALS.romi | SIGNALS.ci,  
        SIGNALS.irr  
    ],

    [OPCODES.JMP]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.pci,
        SIGNALS.irr  
    ],

    [OPCODES.LDA]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,
        SIGNALS.romo | SIGNALS.ai,
        SIGNALS.irr  
    ],

    [OPCODES.LDB]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,
        SIGNALS.romo | SIGNALS.bi,
        SIGNALS.irr  
    ],

    [OPCODES.MXX]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,
        SIGNALS.romo | SIGNALS.ai | SIGNALS.bi,
        SIGNALS.sum | SIGNALS.romi | SIGNALS.flag,
        SIGNALS.irr  
    ],

    [OPCODES.DXX]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,
        SIGNALS.romo | SIGNALS.fi,
        SIGNALS.fo | SIGNALS.ai | SIGNALS.bi,
        SIGNALS.sum | SIGNALS.fi,
        SIGNALS.fo | SIGNALS.romi | SIGNALS.flag,
        SIGNALS.irr  
    ],

    [OPCODES.LCD]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.ai,
        SIGNALS.bi,
        SIGNALS.lcd | SIGNALS.bi,
        SIGNALS.irr  
    ],

    [OPCODES.INP]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,
        SIGNALS.romi | SIGNALS.halt,
        SIGNALS.halt,
        SIGNALS.irr  
    ],

    [OPCODES.WRI]: [
        SIGNALS.mari | SIGNALS.ai | SIGNALS.halt,              
        SIGNALS.romi | SIGNALS.bi | SIGNALS.halt, 
        SIGNALS.irr  
    ],

    [OPCODES.NOP]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        SIGNALS.irr                              
    ],


    [OPCODES.JIN]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.ai | SIGNALS.bi,
        SIGNALS.nand | SIGNALS.ai,
        SIGNALS.flag,
        SIGNALS.romo | SIGNALS.iri | SIGNALS.con,
        SIGNALS.iro | SIGNALS.pci,
        SIGNALS.irr  
    ],

    [OPCODES.LDF]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.iro | SIGNALS.mari,
        SIGNALS.romo | SIGNALS.fi,
        SIGNALS.fo | SIGNALS.fi,
        SIGNALS.irr  
    ],


    [OPCODES.CWB]: [
        SIGNALS.pco | SIGNALS.mari,              
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        // 
        SIGNALS.ai,
        SIGNALS.sum | SIGNALS.ai,
        SIGNALS.nand | SIGNALS.bi,
        SIGNALS.iro | SIGNALS.mari,
        SIGNALS.romo | SIGNALS.ai,
        SIGNALS.flag,
        SIGNALS.ai,
        SIGNALS.sum | SIGNALS.ai,
        SIGNALS.nand | SIGNALS.bi,
        SIGNALS.irr  
    ],


    [OPCODES.HLT]: [
        SIGNALS.pco | SIGNALS.mari,             
        SIGNALS.romo | SIGNALS.iri | SIGNALS.ce, 
        SIGNALS.halt, 
        SIGNALS.irr                            
    ],
};
