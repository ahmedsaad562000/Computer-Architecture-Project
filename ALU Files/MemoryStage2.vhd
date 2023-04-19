LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY MemoryStage2 IS
    PORT (
        clk, rst, Wb, M2R, Sp_inc, Sp_dec, MemW, OutEn, CallSignal : IN STD_LOGIC;
        Pc_Plus_one, Read_Add_Data, Write_Data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rsrc1, Rsrc2, Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        WbOut, M2ROut, Sp_IncOut, Sp_decOut, OutEnOut, CallSignalOut : OUT STD_LOGIC;
        Pc_Out, Memory_Out_data, Read_add_Data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rsrc1_Out, Rsrc2_Out, Rdst_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END MemoryStage2;
ARCHITECTURE MemoryStage2_arch OF MemoryStage2 IS
    COMPONENT RegisterBuffer IS
        GENERIC (N : INTEGER := 16);
        PORT (
            CLK, RST : IN STD_LOGIC;
            D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT Memory IS
        GENERIC (
            N : INTEGER := 1024;
            M : INTEGER := 10);
        PORT (
            clk, we, rst : IN STD_LOGIC;
            raddress : IN STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
            datain : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            dataout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
    END COMPONENT;
    SIGNAL Mem2WbBufferin : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Mem2WbBufferout : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    ----------------------------------------------
    SIGNAL NOT_CLK : STD_LOGIC;
    ---------------------------------------------
BEGIN
    Mem2WbBufferin <= pc_plus_one & wb & M2r & Sp_inc & Sp_dec & Memw & OutEn & CallSignal & Read_Add_Data & Write_data & Rsrc1 & Rsrc2 & Rdst;
    The_Buffer : RegisterBuffer GENERIC MAP(64) PORT MAP(NOT_CLK, RST, Mem2WbBufferin, Mem2WbBufferout);
    The_Memory : Memory GENERIC MAP(1024, 10) PORT MAP(clk, Mem2WbBufferout(43), rst, Mem2WbBufferout(34 DOWNTO 25), Mem2WbBufferout(24 DOWNTO 9), Memory_out_data);
    wbout <= Mem2WbBufferout(47);
    M2ROut <= Mem2WbBufferout(46);
    Sp_IncOut <= Mem2WbBufferout(45);
    Sp_DecOut <= Mem2WbBufferout(44);
    OutenOut <= Mem2WbBufferout(42);
    CallSignalOut <= Mem2WbBufferout(41);
    pc_out <= Mem2WbBufferout(63 DOWNTO 48);
    read_add_data_out <= Mem2WbBufferout(40 DOWNTO 25);
    Rsrc1_out <= Mem2WbBufferout(8 DOWNTO 6);
    Rsrc2_out <= Mem2WbBufferout(5 DOWNTO 3);
    Rdst_out <= Mem2WbBufferout(2 DOWNTO 0);
    ---------------------------------------------
    NOT_CLK <= NOT CLK;
    ---------------------------------------------
END MemoryStage2_arch;