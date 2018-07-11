`ifndef CPU_DEFS_SVH
`define CPU_DEFS_SVH


/*
	This header defines data structures and constants used in CPU internally
*/

`include "common_defs.svh"


`define TLB_ENTRIES_NUM       16
`define TLB_ENTRIES_NUM_LOG2  4
`define PC_RESET_VECTOR 32'hbfc00000

// register access
typedef struct packed {
	Bit_t     we;
	RegAddr_t waddr;
	Word_t    wdata;
} RegWriteReq_t;

typedef struct packed {
	Bit_t        we;
	DoubleWord_t hilo;
} HiloWriteReq_t;

typedef struct packed {
	Bit_t     we;
	RegAddr_t waddr;
	Word_t    wdata;
	logic [2:0] sel;
} CP0RegWriteReq_t;

// memory access
typedef struct packed {
	// READ  if ce = 1 and we = 0
	// WRITE if ce = 1 and we = 1
	Bit_t       ce;
	Bit_t       we;
	logic [3:0] sel;
	MemAddr_t   addr;
	Word_t      wdata;
} MemAccessReq_t;

// stall
typedef struct packed {
	Bit_t hold_pc;
	Bit_t stall_if; 
	Bit_t stall_id;
	Bit_t stall_ex;
	Bit_t stall_mem;
	Bit_t stall_wb;  // not used
} Stall_t;

// CP0 registers
typedef struct packed {
	logic cu3, cu2, cu1, cu0;
	logic rp, fr, re, mx;
	logic px, bev, ts, sr;
	logic nmi, zero;
	logic [1:0] impl;
	logic [7:0] im;
	logic kx, sx, ux, um;
	logic r0, erl, exl, ie;
} CP0StatusReg_t;

typedef struct packed {
	logic bd, zero30;
	logic [1:0] ce;
	logic [3:0] zero27_24;
	logic iv, wp;
	logic [5:0] zero21_16;
	logic [7:0] ip;
	logic zero7;
	logic [4:0] exc_code;
	logic [1:0] zero1_0;
} CP0CauseReg_t;

typedef struct packed {
	Word_t config1;
	/* The order of the following registers is important.
	 * DO NOT change them. New registers must be added 
	 * BEFORE this comment */
	/* primary 32 registers (sel = 0) */
	Word_t 
	 desave,    error_epc,  tag_hi,     tag_lo,    
	 cache_err, err_ctl,    perf_cnt,   depc,      
	 debug,     reserved22, reserved21, reserved20,
	 watch_hi,  watch_lo,   ll_addr,    config0,   
	 prid,      epc;
	CP0CauseReg_t  cause;
	CP0StatusReg_t status;
	Word_t
	 compare,   entry_hi,   count,      bad_vaddr, 
	 reserved7, wired,      page_mask,  context_,  
	 entry_lo1, entry_lo0,  random,     index;
} CP0Regs_t;

`define CP0_REG_COUNT    5'd9
`define CP0_REG_COMPARE  5'd11
`define CP0_REG_STATUS   5'd12
`define CP0_REG_CAUSE    5'd13

// exception
typedef struct packed {
	Bit_t occur, eret;
	logic [4:0] code;
	Word_t extra;
} ExceptInfo_t;

typedef struct packed {
	Bit_t flush, delayslot, eret;
	Bit_t alpha_taken;
	logic [4:0] code;
	InstAddr_t cur_pc, jump_pc;
	Word_t extra;
} ExceptReq_t;

/* cause register exc_code field */
`define EXCCODE_INT   5'h00  // interrupt
`define EXCCODE_TLBL  5'h02  // TLB exception (load or instruction fetch)
`define EXCCODE_TLBS  5'h03  // TLB exception (store)
`define EXCCODE_ADEL  5'h04  // address exception (load or instruction fetch)
`define EXCCODE_ADES  5'h05  // address exception (store)
`define EXCCODE_SYS   5'h08  // syscall
`define EXCCODE_BP    5'h09  // breakpoint
`define EXCCODE_RI    5'h0a  // reserved instruction exception
`define EXCCODE_CpU   5'h0b  // coprocesser unusable exception
`define EXCCODE_OV    5'h0c  // overflow
`define EXCCODE_TR    5'h0d  // trap

// operation
typedef enum {
	/* instruction control instructions */
	OP_NOP, OP_SSNOP,

	/* arithmetic instructions */
	OP_ADD, OP_ADDU, OP_SUB, OP_SUBU,
	OP_CLO, OP_CLZ,
	OP_DIV, OP_DIVU,
	OP_MADD, OP_MADDU, OP_MSUB, OP_MSUBU,
	OP_MUL, OP_MULT, OP_MULTU,
	OP_SLT, OP_SLTU,

	/* logical instructions */
	OP_AND, OP_LUI, OP_NOR, OP_OR, OP_XOR, 

	/* branch and jump instructions */
	OP_BEQ, OP_BGEZ, OP_BGEZAL,
	OP_BGTZ, OP_BLEZ, OP_BLTZ, OP_BLTZAL, OP_BNE,
	OP_J, OP_JAL, OP_JALR, OP_JR,
	// OP_B,   the same as OP_BEQ with rs = rt = 0
	// OP_BAL, the same as OP_BGEZAL with rs = 0

	/* load, store, and memory control instructions */
	OP_LB, OP_LBU, OP_LH, OP_LHU,
	OP_LW, OP_LWL, OP_LWR, OP_SB,
	OP_SH, OP_SW, OP_SWL, OP_SWR,
	OP_LL, OP_SC,
	// OP_PERF, OP_SYNC, regarded as OP_NOP

	/* move instructions */
	OP_MFHI, OP_MFLO, OP_MTHI, OP_MTLO,
	OP_MOVN, OP_MOVZ,
	// OP_MOVF, OP_MOVT, floating-point involved

	/* shift instructions */
	OP_SLL, OP_SLLV, OP_SRA, OP_SRAV, OP_SRL, OP_SRLV, 

	/* trap instructions */
	OP_BREAK, OP_SYSCALL, OP_TEQ, OP_TNE,
	OP_TGEU, OP_TGE, OP_TLTU, OP_TLT, 

	/* privileged instructions */
	OP_CACHE, OP_ERET, OP_MFC0, OP_MTC0,
	OP_TLBP, OP_TLBR, OP_TLBWI, OP_TLBWR, OP_WAIT,

	/* invalid */
	OP_INVALID
} Oper_t;

// pipeline
typedef struct packed {
	Oper_t op;               // ID, EX, MEM
	InstAddr_t pc;           // ID, EX, MEM
	Inst_t inst;             // ID, EX
	Word_t reg1, reg2, imm;  // ID, EX
	RegAddr_t reg_addr1, reg_addr2;  // ID, EX
	Bit_t delayslot;         // IF, ID, EX, MEM
	Bit_t is_priv_inst;      // EX, MEM
} PipelineData_t;

typedef struct packed {
	HiloWriteReq_t hilo_wr;      // EX, MEM, WB
	CP0RegWriteReq_t cp0_reg_wr; // EX, MEM, WB
	MemAccessReq_t memory_req;   // EX, MEM
	RegWriteReq_t reg_wr;        // ID, EX, MEM, WB
	ExceptInfo_t except;         // ID, EX, MEM
	Bit_t llbit_set;             // EX, MEM
} PipelineReq_t;

// superscalar
typedef struct packed {
	Inst_t inst1, inst2;
	Bit_t inst2_taken;
} InstPair_t;

// TLB entries
typedef struct packed {
	logic [2:0] c0, c1;
	logic [7:0] asid;
	logic [18:0] vpn2;
	logic [23:0] pfn0, pfn1;
	logic d1, v1, d0, v0;
	logic G;
} TLBEntry_t;

typedef logic [`TLB_ENTRIES_NUM * $bits(TLBEntry_t) - 1:0] TLBFlatEntries_t;
typedef struct packed {
	MemAddr_t phy_addr;
	logic [3:0] which;
	logic miss, dirty, valid;
	logic [2:0] cache_flag;
} TLBResult_t;

typedef struct packed {
	MemAddr_t phy_addr;
	logic invalid, miss, dirty, illegal;
} MMUResult_t;

`endif
