library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.SPC700_pkg.all;

entity SPC700_MCode is
    port( 
        CLK 	: in std_logic;
		  RST_N	: in std_logic;
		  EN 		: in std_logic;
        IR		: in std_logic_vector(7 downto 0);
        STATE	: in unsigned(3 downto 0);
        M		: out MCode_r
    );
end SPC700_MCode;

architecture rtl of SPC700_MCode is

	type MicroInst_t is array(0 to 4095) of MicroInst_r;
	constant  M_TAB: MicroInst_t := (
	-- 00 NOP
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 01 TCALL 0
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 02 SET1 d.0
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010110","000"),-- ['ALU([AX]|01)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 03 BBS d.0
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 04 OR A, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","01","000000","000100","000"),-- ['ALU(A|[AX])', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 05 OR A, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","01","000000","000100","000"),-- ['ALU(A|[AX])', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 06 OR A, (X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("10","01","000000","00011","01","000000","000100","000"),-- ['ALU(A|[AX])', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 07 OR A, (d+X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011010","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR->AL']
	("10","01","000000","00011","01","000000","000100","000"),-- ['ALU(A|[AX])', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 08 OR #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","01","000000","000100","000"),-- ['ALU(A|[PC])', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 09 OR dd, ds
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00110","00","000000","000000","000"),-- ['[AX]->T']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","011000","000100","000"),-- ['ALU(T|[AX])', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 0A OR1 C, m.b
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]&1F->AH', '[PC]->DR', 'PC++']
	("00","01","000000","01010","00","101011","010110","000"),-- ['ALU(C|[AX].b)', 'ALU()->C']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 0B ASL d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","000000","001010","000"),-- ['ALU([AX]<<1)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 0C ASL !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00111","00","000000","001010","000"),-- ['ALU([AX]<<1)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 0D PUSH PSW
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","00000","00","000000","000000","011"),-- ['PSW->[SP]']
	("10","10","000000","01101","00","000000","000000","000"),-- ['SP--']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 0E TSET1 !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00011","00","000000","011000","000"),-- ['ALU([AX])', 'Flags']
	("00","01","000000","01011","00","000000","001111","000"),-- ['ALU([AX]|A)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 0F BRK
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","011"),-- ['PSW->[SP]', 'SP--']
	("00","00","000000","01111","00","000000","000000","000"),-- ['0->I', '1->B']
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 10 BPL
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR, 'PC++'']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 11 TCALL 1
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 12 CLR1 d.0
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010101","000"),-- ['ALU([AX]&~01)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 13 BBC d.0
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 14 OR A, d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("10","01","000000","00011","01","000000","000100","000"),-- ['ALU(A|[AX])', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 15 OR A, !a+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000100","000"),-- ['ALU(A|[AX])', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 16 OR A, !a+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011001","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+Y->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000100","000"),-- ['ALU(A|[AX])', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 17 OR A, (d)+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011011","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR+Y->AL']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000100","000"),-- ['ALU(A|[AX])', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 18 OR d, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00101","00","000000","000000","000"),-- ['[PC]->T', 'PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000100","000"),-- ['ALU(T|[AX])', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 19 OR (X), (Y)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100110","00000","00","000000","000000","000"),-- ['Y->AL', 'P->AH']
	("00","01","100101","00110","00","000000","000000","000"),-- ['[AX]->T', 'X->AL', 'P->AH']
	("00","01","000000","00111","00","100101","000100","000"),-- ['ALU(T|[AX])', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 1A DECW d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000010","000"),-- ['ALU([AX]-1)', 'ALU()->T']
	("00","01","110000","00000","00","011000","000000","001"),-- ['T->[AX]', 'AL+1->AL']
	("00","01","000000","00111","00","100101","000001","000"),-- ['ALU([AX]-C)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 1B ASL d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","000000","00111","00","000000","001010","000"),-- ['ALU([AX]<<1)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 1C ASL A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","01","000001","001010","000"),-- ['ALU(A<<1)', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 1D DEC X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","10","001001","000010","000"),-- ['ALU(X-1)', 'ALU()->X', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 1E CMP X, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","00","001000","010011","000"),-- ['ALU(X-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 1F JMP [!a+X]
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("00","01","111100","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AX+1->AX']
	("10","01","000000","01100","00","000000","000000","000"),-- ['[AX]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 20 CLRP
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","01000","00","000000","000000","000"),-- ['Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 21 TCALL 2
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 22 SET1 d.1
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010110","000"),-- ['ALU([AX]|02)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 23 BBS d.1
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 24 AND A, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","01","000000","000101","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 25 AND A, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","01","000000","000101","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 26 AND A, (X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("10","01","000000","00011","01","000000","000101","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 27 AND A, (d+X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011010","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR->AL']
	("10","01","000000","00011","01","000000","000101","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 28 AND #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","01","000000","000101","000"),-- ['ALU([PC])->A', 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 29 AND dd, ds
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00110","00","000000","000000","000"),-- ['[AX]->T']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000101","000"),-- ['ALU([AX])->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 2A OR1 C, !m.b
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]&1F->AH', 'PC++']
	("00","01","000000","01010","00","101011","011010","000"),-- ['ALU(C|~[AX].b)', 'ALU()->C']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 2B ROL d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","000000","001100","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 2C ROL !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00111","00","000000","001100","000"),-- ['ALU([AX]<<1)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 2D PUSH A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","00000","00","000000","000000","001"),-- ['A->[SP]']
	("10","10","000000","01101","00","000000","000000","000"),-- ['SP--']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 2E CBNE d, r
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","010011","000"),-- ['ALU([AX])']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 2F BRA
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 30 BMI
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 31 TCALL 3
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 32 CLR1 d.1
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010101","000"),-- ['ALU([AX]&~02)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 33 BBC d.1
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 34 AND A, d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("10","01","000000","00011","01","000000","000101","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 35 AND A, !a+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000101","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 36 AND A, !a+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011001","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+Y->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000101","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 37 AND A, (d)+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011011","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR+Y->AL']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000101","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 38 AND d, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00101","00","000000","000000","000"),-- ['[PC]->T', 'PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000101","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 39 AND (X), (Y)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100110","00000","00","000000","000000","000"),-- ['Y->AL', 'P->AH']
	("00","01","100101","00110","00","000000","000000","000"),-- ['[AX]->T', 'X->AL', 'P->AH']
	("00","01","000000","00111","00","100101","000101","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 3A INCW d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000011","000"),-- ['ALU([AX]+1)', 'ALU()->T']
	("00","01","110000","00000","00","011000","000000","001"),-- ['T->[AX]', 'AL+1->AL']
	("00","01","000000","00111","00","100101","001001","000"),-- ['ALU([AX]+C)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 3B ROL d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","000000","00111","00","000000","001100","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 3C ROL A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","01","000001","001100","000"),-- ['ALU(A)->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 3D INC X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","10","001001","000011","000"),-- ['ALU(X)->X', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 3E CMP X, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","00","001000","010011","000"),-- ['ALU(X-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 3F CALL !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","01110","00","000000","000000","000"),-- ['AX->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 40 SETP
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","01000","00","000000","000000","000"),-- ['Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 41 TCALL 4
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 42 SET1 d.2
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010110","000"),-- ['ALU([AX]|04)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 43 BBS d.2
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 44 EOR A, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","01","000000","000110","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 45 EOR A, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","01","000000","000110","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 46 EOR A, (X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("10","01","000000","00011","01","000000","000110","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 47 EOR A, (d+X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011010","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR->AL']
	("10","01","000000","00011","01","000000","000110","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 48 EOR #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","01","000000","000110","000"),-- ['ALU([PC])->A', 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 49 EOR dd, ds
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00110","00","000000","000000","000"),-- ['[AX]->T']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000110","000"),-- ['ALU([AX])->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 4A AND1 C, m.b
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]&1F->AH', '[PC]->DR', 'PC++']
	("10","01","000000","01010","00","101011","010111","000"),-- ['ALU([AX])->C']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 4B LSR d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","000000","001011","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 4C LSR !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00111","00","000000","001011","000"),-- ['ALU([AX]>>1)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 4D PUSH X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","00000","00","001000","000000","001"),-- ['X->[SP]']
	("10","10","000000","01101","00","000000","000000","000"),-- ['SP--']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 4E TCLR1 !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00011","00","000000","011000","000"),-- ['ALU([AX])', 'Flags']
	("00","01","000000","01011","00","000000","001110","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 4F PCALL u
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("10","00","000000","10010","00","000000","000000","000"),-- ['FF:AL->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 50 BVC
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 51 TCALL 5
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 52 CLR1 d.2
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010101","000"),-- ['ALU([AX]&~04)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 53 BBC d.2
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 54 EOR A, d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("10","01","000000","00011","01","000000","000110","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 55 EOR A, !a+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000110","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 56 EOR A, !a+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011001","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000110","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 57 EOR A, (d)+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011011","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR+Y->AL']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000110","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 58 EOR d, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00101","00","000000","000000","000"),-- ['[PC]->T', 'PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000110","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 59 EOR (X), (Y)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100110","00000","00","000000","000000","000"),-- ['Y->AL', 'P->AH']
	("00","01","100101","00110","00","000000","000000","000"),-- ['[AX]->T', 'X->AL', 'P->AH']
	("00","01","000000","00111","00","100101","000110","000"),-- ['ALU([AX])->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 5A CMPW YA, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","110000","00011","00","000000","010011","000"),-- ['ALU(A-[AX])', 'AL+1->AL']
	("10","01","000000","00011","00","010000","010000","000"),-- ['ALU([AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 5B LSR d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","000000","00111","00","000000","001011","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 5C LSR A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","01","000001","001011","000"),-- ['ALU(A)->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 5D MOV X, A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","10","000001","000000","000"),-- ['ALU(A)->X', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 5E CMP Y, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","00","010000","010011","000"),-- ['ALU(Y-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 5F JMP !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("10","00","000000","01100","00","000000","000000","000"),-- ['[PC]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 60 CLRC
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","01000","00","000000","000000","000"),-- ['Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 61 TCALL 6
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 62 SET1 d.3
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010110","000"),-- ['ALU([AX]|08)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 63 BBS d.3
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 64 CMP A, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","00","000000","010011","000"),-- ['ALU(A-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 65 CMP A, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","00","000000","010011","000"),-- ['ALU(A-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 66 CMP A, (X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("10","01","000000","00011","00","000000","010011","000"),-- ['ALU(A-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 67 CMP A, (d+X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011010","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR->AL']
	("10","01","000000","00011","00","000000","010011","000"),-- ['ALU(A-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 68 CMP #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","00","000000","010011","000"),-- ['ALU(A-[PC])', 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 69 CMP dd, ds
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00110","00","000000","000000","000"),-- ['[AX]->T']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","010011","000"),-- ['ALU([AX]-T)', 'Flags']
	("10","00","000000","00000","00","000000","000000","000"),-- 
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 6A AND1 C, !m.b
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]&1F->AH', '[PC]->DR', 'PC++']
	("10","01","000000","01010","00","101011","010101","000"),-- ['ALU([AX])->C']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 6B ROR d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","000000","001101","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 6C ROR !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00111","00","000000","001101","000"),-- ['ALU([AX]>>1)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 6D PUSH Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","00000","00","010000","000000","001"),-- ['Y->[SP]']
	("10","10","000000","01101","00","000000","000000","000"),-- ['SP--']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 6E DBNZ d, r
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100101","000010","000"),-- ['ALU([AX])->T']
	("00","01","000000","00000","00","011001","000000","001"),-- ['T->[AX]']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 6F RET
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","10000","00","000000","000000","000"),-- ['SP++']
	("00","10","000000","10000","00","000000","000000","000"),-- ['[SP]->DR', 'SP++']
	("00","10","000000","01100","00","000000","000000","000"),-- ['[SP]:DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 70 BVS
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 71 TCALL 7
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 72 CLR1 d.3
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010101","000"),-- ['ALU([AX]&~08)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 73 BBC d.3
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 74 CMP A, d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("10","01","000000","00011","00","000000","010011","000"),-- ['ALU(A-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 75 CMP A, !a+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","00","000000","010011","000"),-- ['ALU(A-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 76 CMP A, !a+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011001","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","00","000000","010011","000"),-- ['ALU(A-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 77 CMP A, (d)+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011011","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR+Y->AL']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","00","000000","010011","000"),-- ['ALU(A-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 78 CMP d, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00101","00","000000","000000","000"),-- ['[PC]->T', 'PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","010011","000"),-- ['ALU([AX]-T)', 'Flags']
	("10","00","000000","00000","00","000000","000000","000"),-- 
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 79 CMP (X), (Y)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100110","00000","00","000000","000000","000"),-- ['Y->AL', 'P->AH']
	("00","01","100101","00110","00","000000","000000","000"),-- ['[AX]->T', 'X->AL', 'P->AH']
	("00","01","000000","00111","00","100101","010011","000"),-- ['ALU([AX]-T)', 'Flags']
	("10","00","000000","00000","00","000000","000000","000"),-- 
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 7A ADDW YA, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00011","01","000000","010001","000"),-- ['ALU([AX])->A']
	("00","00","110000","00000","00","000000","000000","000"),-- ['AL+1->AL']
	("10","01","000000","00011","11","010000","010010","000"),-- ['ALU([AX])->Y']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 7B ROR d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","000000","00111","00","000000","001101","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 7C ROR A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","01","000001","001101","000"),-- ['ALU(A)->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 7D MOV A, X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","01","001001","000000","000"),-- ['ALU(X)->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 7E CMP Y, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","00","010000","010011","000"),-- ['ALU(Y-[AX])', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 7F RETI
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","10000","00","000000","000000","000"),-- ['SP++']
	("00","10","000000","10001","00","000000","000000","000"),-- ['[SP]->PSW']
	("00","00","000000","10000","00","000000","000000","000"),-- ['SP++']
	("00","10","000000","10000","00","000000","000000","000"),-- ['[SP]->DR', 'SP++']
	("10","10","000000","01100","00","000000","000000","000"),-- ['[SP]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 80 SETC
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","01000","00","000000","000000","000"),-- ['Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 81 TCALL 8
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 82 SET1 d.4
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010110","000"),-- ['ALU([AX]|10)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 83 BBS d.4
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 84 ADC A, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","01","000000","000111","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 85 ADC A, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","01","000000","000111","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 86 ADC A, (X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("10","01","000000","00011","01","000000","000111","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 87 ADC A, (d+X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011010","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR->AL']
	("10","01","000000","00011","01","000000","000111","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 88 ADC #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","01","000000","000111","000"),-- ['ALU([PC])->A', 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 89 ADC dd, ds
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00110","00","000000","000000","000"),-- ['[AX]->T']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000111","000"),-- ['ALU([AX])->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 8A EOR1 C, m.b
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]&1F->AH', '[PC]->DR', 'PC++']
	("00","01","000000","01010","00","101011","011011","000"),-- ['ALU([AX])->C']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 8B DEC d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000010","000"),-- ['ALU([AX]-1)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 8C DEC !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00111","00","100101","000010","000"),-- ['ALU([AX]-1)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 8D MOV Y, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","11","000000","000000","000"),-- ['ALU([PC])->Y', 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 8E POP PSW
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","10000","00","000000","000000","000"),-- ['SP++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","10","000000","10001","00","000000","000000","000"),-- ['[SP]->PSW']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 8F MOV d, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00101","00","000000","000000","000"),-- ['[PC]->T', 'PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 90 BCC
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 91 TCALL 9
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 92 CLR1 d.4
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010101","000"),-- ['ALU([AX]&~10)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 93 BBC d.4
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 94 ADC A, d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("10","01","000000","00011","01","000000","000111","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 95 ADC A, !a+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000111","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 96 ADC A, !a+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011001","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000111","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 97 ADC A, (d)+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011011","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR+Y->AL']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000111","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 98 ADC d, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00101","00","000000","000000","000"),-- ['[PC]->T', 'PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000111","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 99 ADC (X), (Y)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100110","00000","00","000000","000000","000"),-- ['Y->AL', 'P->AH']
	("00","01","100101","00110","00","000000","000000","000"),-- ['[AX]->T', 'X->AL', 'P->AH']
	("00","01","000000","00111","00","100101","000111","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 9A SUBW YA, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00011","01","000000","010011","000"),-- ['ALU([AX])->A']
	("00","00","110000","00000","00","000000","000000","000"),-- ['AL+1->AL']
	("10","01","000000","00011","11","010000","010100","000"),-- ['ALU([AX])->Y']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 9B DEC d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","000000","00111","00","100101","000010","000"),-- ['ALU([AX]-1)', 'ALU()->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 9C DEC A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","01","000001","000010","000"),-- ['ALU(A-1)', 'ALU()->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 9D MOV X, SP
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","10","111001","000000","000"),-- ['ALU(SP)->X', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 9E DIV YA, X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","100001","000"),-- ['ALU(YA/X)']
	("00","00","000000","00000","00","000000","100001","000"),-- ['ALU(YA/X)']
	("00","00","000000","00000","00","000000","100001","000"),-- ['ALU(YA/X)']
	("00","00","000000","00000","00","000000","100001","000"),-- ['ALU(YA/X)']
	("00","00","000000","00000","00","000000","100001","000"),-- ['ALU(YA/X)']
	("00","00","000000","00000","00","000000","100001","000"),-- ['ALU(YA/X)']
	("00","00","000000","00000","00","000000","100001","000"),-- ['ALU(YA/X)']
	("00","00","000000","00000","00","000000","100001","000"),-- ['ALU(YA/X)']
	("00","00","000000","00000","00","000000","100001","000"),-- ['ALU(YA/X)']
	("10","00","000000","00011","01","110001","100001","000"),-- ['ALU()->YA', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- 9F XCN
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00011","01","000001","011101","000"),-- ['ALU(A)->A', 'Flags']
	("00","00","000000","00000","00","000000","000000","000"),
	("00","00","000000","00000","00","000000","000000","000"),
	("10","00","000000","00000","00","000000","000000","000"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	--A0 EI
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","01000","00","000000","000000","000"),-- ['Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- A1 TCALL 10
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- A2 SET1 d.5
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010110","000"),-- ['ALU([AX]|20)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- A3 BBS d.5
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- A4 SBC A, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","01","000000","001000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- A5 SBC A, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","01","000000","001000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- A6 SBC A, (X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("10","01","000000","00011","01","000000","001000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- A7 SBC A, (d+X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011010","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR->AL']
	("10","01","000000","00011","01","000000","001000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- A8 SBC #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","01","000000","001000","000"),-- ['ALU([PC])->A', 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- A9 SBC dd, ds
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00110","00","000000","000000","000"),-- ['[AX]->T']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","001000","000"),-- ['ALU([AX])->T', 'Flags']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- AA MOV1 C, m.b
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]&1F->AH', '[PC]->DR', 'PC++']
	("10","01","000000","01010","00","000011","000000","000"),-- ['ALU([AX])->C']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- AB INC d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","000011","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- AC INC !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00111","00","100101","000011","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- AD CMP Y, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","00","010000","010011","000"),-- ['ALU(Y-[PC]), 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- AE POP A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","10000","00","000000","000000","000"),-- ['SP++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","10","000000","00000","01","000000","000000","000"),-- ['[SP]->A']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- AF MOV (X)+, A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("00","00","000000","00000","10","001001","000011","000"),-- ['X++']
	("10","01","000000","00000","00","000000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B0 BCS
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B1 TCALL 11
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B2 CLR1 d.5
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010101","000"),-- ['ALU([AX]&~20)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B3 BBC d.5
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B4 SBC A, d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("10","01","000000","00011","01","000000","001000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B5 SBC A, !a+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","001000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B6 SBC A, !a+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011001","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","001000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B7 SBC A, (d)+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011011","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR+Y->AL']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","001000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B8 SBC d, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00101","00","000000","000000","000"),-- ['[PC]->T', 'PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00111","00","100101","001000","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- B9 SBC (X), (Y)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100110","00000","00","000000","000000","000"),-- ['Y->AL', 'P->AH']
	("00","01","100101","00110","00","000000","000000","000"),-- ['[AX]->T', 'X->AL', 'P->AH']
	("00","01","000000","00111","00","100101","001000","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- BA MOV YA, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("00","00","110000","00000","00","000000","000000","000"),-- ['AL+1->AL']
	("10","01","000000","00011","11","000000","011001","000"),-- ['ALU([AX])->Y', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- BB INC d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","000000","00111","00","100101","000011","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- BC INC A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","01","000001","000011","000"),-- ['ALU(A)->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- BD MOV SP, X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00100","00","000000","000000","000"),-- ['X->SP']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- BE DAS
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00111","01","000000","011111","000"),-- ['ALU(A)->A', 'Flags']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- BF MOV A, (X)+
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("00","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("10","00","000000","00000","10","001001","000011","000"),-- ['X++']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C0 DI
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","01000","00","000000","000000","000"),-- ['Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C1 TCALL 12
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C2 SET1 d.6
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010110","000"),-- ['ALU([AX]|40)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C3 BBS d.6
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C4 MOV d, A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","000000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C5 MOV !a, A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","000000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C6 MOV (X), A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","000000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C7 MOV (d+X), A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011010","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR->AL']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","000000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C8 CMP X, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","00","001000","010011","000"),-- ['ALU(X-[PC])', 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- C9 MOV !a, X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","001000","000000","001"),-- ['X->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- CA MOV1 m.b, C
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]&1F->AH', '[PC]->DR', 'PC++']
	("00","01","000000","01011","00","100010","010101","000"),-- ['ALU([AX])->T']
	("00","00","000000","01011","00","011100","010110","000"),-- ['ALU(T)->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- CB MOV d, Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","010000","000000","001"),-- ['Y->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- CC MOV !a, Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","010000","000000","001"),-- ['Y->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- CD MOV X, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","10","000000","000000","000"),-- ['ALU([PC])->X', 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- CE POP X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","10000","00","000000","000000","000"),-- ['SP++']
	("00","10","000000","00000","10","000000","000000","000"),-- ['[SP]->X']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- CF MUL YA
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","100000","000"),-- ['ALU(Y*A)']
	("00","00","000000","00000","00","000000","100000","000"),-- ['ALU(Y*A)']
	("00","00","000000","00000","00","000000","100000","000"),-- ['ALU(Y*A)']
	("00","00","000000","00000","00","000000","100000","000"),-- ['ALU(Y*A)']
	("00","00","000000","00000","00","000000","100000","000"),-- ['ALU(Y*A)']
	("00","00","000000","00000","00","000000","100000","000"),-- ['ALU(Y*A)']
	("00","00","000000","00000","00","000000","100000","000"),-- ['ALU(Y*A)']
	("10","00","000000","00011","01","110001","100000","000"),-- ['ALU(Y*A)', 'ALU()->YA', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D0 BNE
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D1 TCALL 13
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D2 CLR1 d.6
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010101","000"),-- ['ALU([AX]&~40)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D3 BBC d.6
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D4 MOV d+X, A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","000000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D5 MOV !a+X, A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","000000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D6 MOV !a+Y, A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011001","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","000000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D7 MOV (d)+Y, A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011011","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR+Y->AL']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","000000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D8 MOV d, X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","001000","000000","001"),-- ['X->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- D9 MOV d+Y, X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010001","00000","00","000000","000000","000"),-- ['AL+Y->AL']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","001000","000000","001"),-- ['X->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- DA MOV d, YA
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("00","01","110000","00000","00","000000","000000","001"),-- ['A->[AX]', 'AL+1->AL']
	("10","01","000000","00000","00","010000","000000","001"),-- ['Y->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- DB MOV d+X, Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]']
	("10","01","000000","00000","00","010000","000000","001"),-- ['A->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- DC DEC Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","11","010001","000010","000"),-- ['ALU(Y-1)', 'ALU()->Y', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- DD MOV A, Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","01","010001","000000","000"),-- ['ALU(Y)->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- DE CBNE d+X, r
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","000000","00000","00","000000","010011","000"),-- ['ALU([AX])']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- DF DAA
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00111","01","000000","011110","000"),-- ['ALU(A)->A', 'Flags']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E0 CLRV
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","01000","00","000000","000000","000"),-- ['Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E1 TCALL 14
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E2 SET1 d.7
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010110","000"),-- ['ALU([AX]|80)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E3 BBS d.7
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E4 MOV A, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E5 MOV A, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E6 MOV A, (X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100101","00000","00","000000","000000","000"),-- ['X->AL', 'P->AH']
	("10","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E7 MOV A, (d+X)
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011010","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR->AL']
	("10","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E8 MOV A, #i
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00010","01","000000","000000","000"),-- ['ALU([PC])->A', 'PC++', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- E9 X, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","10","000000","000000","000"),-- ['ALU([AX])->X', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- EA NOT1 m.b
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]&1F->AH', '[PC]->DR', 'PC++']
	("00","01","000000","01011","00","100010","011011","000"),-- ['ALU([AX])->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- EB MOV Y, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","11","000000","000000","000"),-- ['ALU([AX])->Y', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- EC Y, !a
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","001000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'PC++']
	("10","01","000000","00011","11","000000","000000","000"),-- ['ALU([AX])->Y', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- ED NOT C
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","01010","00","101000","011100","000"),-- ['C ^ 1']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- EE POP Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","10000","00","000000","000000","000"),-- ['SP++']
	("00","10","000000","00000","11","000000","000000","000"),-- ['[SP]->Y']
	("10","00","000000","00000","00","000000","000000","000"),--
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- EF SLEEP
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F0 BEQ
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F1 TCALL 15
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","10","000000","01101","00","000000","000000","101"),-- ['PCH->[SP]', 'SP--']
	("00","10","000000","01101","00","000000","000000","100"),-- ['PCL->[SP]', 'SP--']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","11","000000","00000","00","000000","000000","000"),-- ['[VECT]->DR ']
	("10","11","000000","01100","00","000000","000000","000"),-- ['[VECT]:DR->PC ']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F2 CLR1 d.7
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","01011","00","100010","010101","000"),-- ['ALU([AX]&~80)', 'ALU()->T']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F3 BBC d.7
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00000","00","000000","000000","000"),-- ['[AX]->DR']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F4 MOV A, d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("10","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F5 MOV A, !a+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011000","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F6 MOV A, !a+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100000","00001","00","000000","000000","000"),-- ['[PC]->AL', 'PC++']
	("00","00","011001","00001","00","000000","000000","000"),-- ['[PC]->AH', 'AL+X->AL', 'PC++']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),	
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F7 MOV A, (d)+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","110000","00000","00","000000","000000","000"),-- ['[AX]->DR', 'AL+1->AL']
	("00","01","011011","00000","00","000000","000000","000"),-- ['[AX]->AH', 'DR+Y->AL']
	("00","00","001100","00000","00","000000","000000","000"),-- ['AH+Carry->AH']
	("10","01","000000","00011","01","000000","000000","000"),-- ['ALU([AX])->A', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F8 MOV X, d
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00011","10","000000","000000","000"),-- ['ALU([AX])->X', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- F9 MOV X, d+Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010001","00000","00","000000","000000","000"),-- ['AL+Y->AL']
	("10","01","000000","00011","10","000000","000000","000"),-- ['ALU([AX])->X', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- FA MOV dd, ds
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","01","000000","00110","00","000000","000000","000"),-- ['[AX]->T']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("10","01","000000","00000","00","011000","000000","001"),-- ['T->[AX]']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- FB MOV Y, d+X
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","100100","00001","00","000000","000000","000"),-- ['[PC]->AL', 'P->AH', 'PC++']
	("00","00","010000","00000","00","000000","000000","000"),-- ['AL+X->AL']
	("10","01","000000","00011","11","000000","000000","000"),-- ['ALU([AX])->Y', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- FC INC Y
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","11","010001","000011","000"),-- ['ALU(Y)->Y', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- FD MOV Y, A
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("10","00","000000","00011","11","000001","000000","000"),-- ['ALU(A)->Y', 'Flags']
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- FE DBNZ Y, r
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("00","00","000000","00000","11","010001","000010","000"),-- ['ALU(Y)->Y']
	("10","00","000000","00001","00","000000","000000","000"),-- ['[PC]->DR', 'PC++']
	("00","00","000000","01001","00","000000","000000","000"),-- ['PC+DR->PC']
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	-- FF STOP
	("00","00","000000","00001","00","000000","000000","000"),-- ['PC++']
	("00","00","000000","00000","00","000000","000000","000"),-- []
	("10","00","000000","00000","00","000000","000000","000"),-- []
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX"),
	("XX","XX","XXXXXX","XXXXX","XX","XXXXXX","XXXXXX","XXX")
	);
	

	type ALUCtrl_t is array(0 to 33) of ALUCtrl_r;
	constant ALU_TAB: ALUCtrl_t := (
	("110","0011",'0','0','0','0','0'),-- 000000 MOV
	("100","1011",'0','0','1','0','1'),-- 000001 DECW
	("101","1011",'0','0','0','0','0'),-- 000010 DEC 
	("101","1001",'0','0','0','0','0'),-- 000011 INC
	("110","0000",'0','0','0','0','0'),-- 000100 OR
	("110","0001",'0','0','0','0','0'),-- 000101 AND
	("110","0010",'0','0','0','0','0'),-- 000110 EOR
	("110","1000",'1','1','0','1','0'),-- 000111 ADC
	("110","1010",'1','1','0','1','0'),-- 001000 SBC
	("100","1001",'0','0','1','0','1'),-- 001001 INCW
	("000","0011",'0','0','0','1','0'),-- 001010 ASL
	("010","0011",'0','0','0','1','0'),-- 001011 LSR
	("001","0011",'0','0','0','1','0'),-- 001100 ROL
	("011","0011",'0','0','0','1','0'),-- 001101 ROR
	("110","0100",'0','0','0','0','0'),-- 001110 TCLR1
	("110","0101",'0','0','0','0','0'),-- 001111 TSET1
	("110","1011",'0','0','1','1','1'),-- 010000 CMPW
	("110","1001",'0','0','0','1','0'),-- 010001 ADD
	("110","1001",'1','1','1','1','1'),-- 010010 ADDW
	("110","1011",'0','0','0','1','0'),-- 010011 SUB/CMP
	("110","1011",'1','1','1','1','1'),-- 010100 SUBW
	("111","0001",'0','0','0','0','0'),-- 010101 CLR1/NOT AND1
	("110","0000",'0','0','0','0','0'),-- 010110 SET1/OR1
	("110","0001",'0','0','0','0','0'),-- 010111 AND1
	("110","1011",'0','0','0','0','0'),-- 011000 CMP (TCLR1/TSET1)
	("110","0011",'0','0','0','0','1'),-- 011001 MOVW
	("111","0000",'0','0','0','0','0'),-- 011010 NOT OR1
	("110","0010",'0','0','0','0','0'),-- 011011 EOR1
	("101","0010",'0','0','0','0','0'),-- 011100 NOTC (C ^ 1)
	("110","0110",'0','0','0','0','0'),-- 011101 XCN
	("110","1100",'0','0','0','1','0'),-- 011110 DAA 
	("110","1101",'0','0','0','1','0'),-- 011111 DAS
	("110","1110",'0','0','0','0','0'),-- 100000 MUL 
	("110","1111",'1','1','0','0','0') -- 100001 DIV
	);
	
	type RegCtrl_t is array(0 to 18) of RegCtrl_r;
	constant  REG_TAB: RegCtrl_t := (
	("000","00","000","00"),--00000
	("001","00","000","00"),--00001 PC++
	("001","00","001","00"),--00010 PC++, Flags
	("000","00","001","00"),--00011 Flags
	("000","11","000","00"),--00100 X->SP
	("001","00","000","01"),--00101 [PC]->T, PC++
	("000","00","000","01"),--00110 []->T
	("000","00","001","10"),--00111 ALU()->T, Flags
	("000","00","100","00"),--01000 CLR/SET
	("011","00","000","00"),--01001 PC+DR->PC
	("000","00","101","00"),--01010 C change
	("000","00","000","10"),--01011 ALU()->T
	("010","00","000","00"),--01100 []:DR->PC
	("000","10","000","00"),--01101 Reg->[SP], SP--
	("100","00","000","00"),--01110 AX->PC
	("000","00","010","00"),--01111 1->B
	("000","01","000","00"),--10000 SP++
	("000","00","011","00"),--10001 []->PSW
	("101","00","000","00") --10010 FF:AL->PC
	);
	
	signal MI    	: MicroInst_r;
	signal ALUFlags: ALUCtrl_r;
	signal R: RegCtrl_r;
    
begin

	ALUFlags <= ALU_TAB(to_integer(unsigned(MI.ALUCtrl)));
	R <= REG_TAB(to_integer(unsigned(MI.regMode)));

	process(CLK, RST_N)
	begin
		if RST_N = '0' then
			MI <= ("00","00","000000","00001","00","000000","000000","000");
		elsif rising_edge(CLK) then
			if EN = '1' then
				MI <= M_TAB(to_integer(unsigned(IR) & STATE));
			end if;
		end if;
	end process;
	
	M <= (ALUFlags, 
			MI.stateCtrl, 
			MI.addrBus, 
			MI.addrCtrl,
			R.loadPC,
			R.loadSP, 
			MI.regAXY, 
			R.loadP, 
			R.loadT,
			MI.busCtrl,
			MI.outBus);
	 
end rtl;