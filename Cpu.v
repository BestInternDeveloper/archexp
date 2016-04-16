`timescale 1ns / 1ps

module Cpu (

		input clock,
		input reset,

		output [31:0] debug_pc,
		output [31:0] debug_instruction,
		output [32 * 32 - 1 : 0] debug_registers,
		output [31:0] debug_memoryAddress,
		output [31:0] debug_memoryReadData,
		output debug_shouldWriteMemory,
		output [31:0] debug_memoryWriteData
	);

	wire [31:0] pc_pc;

	wire [31:0] if_pc_4;
	wire [31:0] if_instruction;
	wire [31:0] if_nextPc;

	wire [31:0] id_pc_4;
	wire [31:0] id_instruction;

	wire id_shouldJumpOrBranch;
	wire [31:0] id_jumpOrBranchPc;
	wire [31:0] id_shiftAmount;
	wire [31:0] id_immediate;
	wire [31:0] id_registerRsOrPc_4;
	wire [31:0] id_registerRtOrZero;
	wire [3:0] id_aluOperation;
	wire id_shouldAluUseShiftAmountElseRegisterRsOrPc_4;
	wire id_shouldAluUseImmeidateElseRegisterRtOrZero;
	wire id_shouldWriteRegister;
	wire [4:0] id_registerWriteAddress;
	wire id_shouldWriteMemoryElseAluOutputToRegister;
	wire id_shouldWriteMemory;
	wire id_shouldStall;

	wire [31:0] ex_shiftAmount;
	wire [31:0] ex_immediate;
	wire [31:0] ex_registerRsOrPc_4;
	wire [31:0] ex_registerRtOrZero;
	wire [3:0] ex_aluOperation;
	wire ex_shouldAluUseShiftAmountElseRegisterRsOrPc_4;
	wire ex_shouldAluUseImmeidateElseRegisterRtOrZero;
	wire ex_shouldWriteRegister;
	wire [4:0] ex_registerWriteAddress;
	wire ex_shouldWriteMemoryElseAluOutputToRegister;
	wire ex_shouldWriteMemory;

	wire [31:0] ex_aluOutput;

	wire mem_shouldWriteRegister;
	wire [4:0] mem_registerWriteAddress;
	wire mem_shouldWriteMemoryElseAluOutputToRegister;
	wire [31:0] mem_aluOutput;
	wire mem_shouldWriteMemory;
	wire [31:0] mem_registerRtOrZero;

	wire [31:0] mem_memoryData;

	wire wb_shouldWriteRegister;
	wire [4:0] wb_registerWriteAddress;
	wire wb_shouldWriteMemoryElseAluOutputToRegister;
	wire [31:0] wb_memoryData;
	wire [31:0] wb_aluOutput;

	wire [31:0] wb_registerWriteData;

	Pc pc (

		.clock(clock),
		.reset(reset),

		.nextPc(if_nextPc[31:0]),
		.pc(pc_pc[31:0])
	);

	IfStage ifStage (

		.clock(clock),

		.pc(pc_pc[31:0]),

		.id_shouldJumpOrBranch(id_shouldJumpOrBranch),
		.id_jumpOrBranchPc(id_jumpOrBranchPc[31:0]),

		.pc_4(if_pc_4[31:0]),

		.instruction(if_instruction[31:0]),

		.nextPc(if_nextPc[31:0])
	);

	IfIdRegisters ifIdRegisters (

		.clock(clock),
		.reset(reset),

		.if_pc_4(if_pc_4[31:0]),

		.if_instruction(if_instruction[31:0]),

		.id_pc_4(id_pc_4[31:0]),

		.id_instruction(id_instruction[31:0])
	);

	IdStage idStage (

		.clock(clock),
		.reset(reset),

		.pc_4(id_pc_4[31:0]),

		.instruction(id_instruction[31:0]),

		.shouldJumpOrBranch(id_shouldJumpOrBranch),
		.jumpOrBranchPc(id_jumpOrBranchPc[31:0]),

		.shiftAmount(id_shiftAmount[31:0]),
		.immediate(id_immediate[31:0]),

		.registerRsOrPc_4(id_registerRsOrPc_4[31:0]),
		.registerRtOrZero(id_registerRtOrZero[31:0]),

		.aluOperation(id_aluOperation[3:0]),
		.shouldAluUseShiftAmountElseRegisterRsOrPc_4(id_shouldAluUseShiftAmountElseRegisterRsOrPc_4),
		.shouldAluUseImmeidateElseRegisterRtOrZero(id_shouldAluUseImmeidateElseRegisterRtOrZero),

		.shouldWriteRegister(id_shouldWriteRegister),
		.registerWriteAddress(id_registerWriteAddress[4:0]),
		.shouldWriteMemoryElseAluOutputToRegister(id_shouldWriteMemoryElseAluOutputToRegister),

		.shouldWriteMemory(id_shouldWriteMemory),

		.wb_shouldWriteRegister(wb_shouldWriteRegister),
		.wb_registerWriteAddress(wb_registerWriteAddress[4:0]),
		.wb_registerWriteData(wb_registerWriteData[31:0]),

		.shouldStall(id_shouldStall),

		.debug_registers(debug_registers[32 * 32 - 1 : 0])
	);

	IdExRegisters idExRegisters (

		.clock(clock),
		.reset(reset),

		.id_shiftAmount(id_shiftAmount[31:0]),
		.id_immediate(id_immediate[31:0]),

		.id_registerRsOrPc_4(id_registerRsOrPc_4[31:0]),
		.id_registerRtOrZero(id_registerRtOrZero[31:0]),

		.id_aluOperation(id_aluOperation[3:0]),
		.id_shouldAluUseShiftAmountElseRegisterRsOrPc_4(id_shouldAluUseShiftAmountElseRegisterRsOrPc_4),
		.id_shouldAluUseImmeidateElseRegisterRtOrZero(id_shouldAluUseImmeidateElseRegisterRtOrZero),

		.id_shouldWriteRegister(id_shouldWriteRegister),
		.id_registerWriteAddress(id_registerWriteAddress[4:0]),
		.id_shouldWriteMemoryElseAluOutputToRegister(id_shouldWriteMemoryElseAluOutputToRegister),

		.id_shouldWriteMemory(id_shouldWriteMemory),

		.ex_shiftAmount(ex_shiftAmount[31:0]),
		.ex_immediate(ex_immediate[31:0]),

		.ex_registerRsOrPc_4(ex_registerRsOrPc_4[31:0]),
		.ex_registerRtOrZero(ex_registerRtOrZero[31:0]),

		.ex_aluOperation(ex_aluOperation[3:0]),
		.ex_shouldAluUseShiftAmountElseRegisterRsOrPc_4(ex_shouldAluUseShiftAmountElseRegisterRsOrPc_4),
		.ex_shouldAluUseImmeidateElseRegisterRtOrZero(ex_shouldAluUseImmeidateElseRegisterRtOrZero),

		.ex_shouldWriteRegister(ex_shouldWriteRegister),
		.ex_registerWriteAddress(ex_registerWriteAddress[4:0]),
		.ex_shouldWriteMemoryElseAluOutputToRegister(ex_shouldWriteMemoryElseAluOutputToRegister),

		.ex_shouldWriteMemory(ex_shouldWriteMemory)
	);

	ExStage exStage (

		.shiftAmount(ex_shiftAmount[31:0]),
		.immediate(ex_immediate[31:0]),

		.aluOperation(ex_aluOperation[3:0]),
		.shouldAluUseShiftAmountElseRegisterRsOrPc_4(ex_shouldAluUseShiftAmountElseRegisterRsOrPc_4),
		.shouldAluUseImmeidateElseRegisterRtOrZero(ex_shouldAluUseImmeidateElseRegisterRtOrZero),

		.registerRsOrPc_4(ex_registerRsOrPc_4[31:0]),
		.registerRtOrZero(ex_registerRtOrZero[31:0]),

		.aluOutput(ex_aluOutput[31:0])
	);

	ExMemRegisters exMemRegisters (

		.clock(clock),
		.reset(reset),

		.ex_shouldWriteRegister(ex_shouldWriteRegister),
		.ex_registerWriteAddress(ex_registerWriteAddress[4:0]),
		.ex_shouldWriteMemoryElseAluOutputToRegister(ex_shouldWriteMemoryElseAluOutputToRegister),

		.ex_aluOutput(ex_aluOutput[31:0]),
		.ex_shouldWriteMemory(ex_shouldWriteMemory),
		.ex_registerRtOrZero(ex_registerRtOrZero[31:0]),

		.mem_shouldWriteRegister(mem_shouldWriteRegister),
		.mem_registerWriteAddress(mem_registerWriteAddress[4:0]),
		.mem_shouldWriteMemoryElseAluOutputToRegister(mem_shouldWriteMemoryElseAluOutputToRegister),

		.mem_aluOutput(mem_aluOutput[31:0]),
		.mem_shouldWriteMemory(mem_shouldWriteMemory),
		.mem_registerRtOrZero(mem_registerRtOrZero[31:0])
	);

	MemStage memStage (

		.clock(clock),
		.reset(reset),

		.aluOutput(mem_aluOutput[31:0]),
		.shouldWriteMemory(mem_shouldWriteMemory),
		.registerRtOrZero(mem_registerRtOrZero[31:0]),
		.memoryData(mem_memoryData[31:0])
	);

	MemWbRegisters memWbRegisters (

		.clock(clock),
		.reset(reset),

		.mem_shouldWriteRegister(mem_shouldWriteRegister),
		.mem_registerWriteAddress(mem_registerWriteAddress[4:0]),
		.mem_shouldWriteMemoryElseAluOutputToRegister(mem_shouldWriteMemoryElseAluOutputToRegister),
		.mem_memoryData(mem_memoryData[31:0]),
		.mem_aluOutput(mem_aluOutput[31:0]),

		.wb_shouldWriteRegister(wb_shouldWriteRegister),
		.wb_registerWriteAddress(wb_registerWriteAddress[4:0]),
		.wb_shouldWriteMemoryElseAluOutputToRegister(wb_shouldWriteMemoryElseAluOutputToRegister),
		.wb_memoryData(wb_memoryData[31:0]),
		.wb_aluOutput(wb_aluOutput[31:0])
	);

	WbStage wbStage (
		.shouldWriteMemoryElseAluOutputToRegister(wb_shouldWriteMemoryElseAluOutputToRegister),
		.memoryData(wb_memoryData[31:0]),
		.aluOutput(wb_aluOutput[31:0]),
		.registerWriteData(wb_registerWriteData[31:0])
	);

	assign debug_pc = pc_pc;
	assign debug_instruction = if_instruction;
	assign debug_memoryAddress = mem_aluOutput;
	assign debug_memoryReadData = mem_memoryData;
	assign debug_shouldWriteMemory = mem_shouldWriteMemory;
	assign debug_memoryWriteData = mem_registerRtOrZero;
endmodule
