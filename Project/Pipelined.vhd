LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Pipelined IS
    PORT (
        RST : IN STD_LOGIC;
        CLK : IN STD_LOGIC;
        IN_PORT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        OUT_PORT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END Pipelined;

ARCHITECTURE Pipelined_arch OF Pipelined IS
    --------------------------------SIGNALS------------------------------------------
    -------------------------------FETCH STAGE OUTPUTS--------------------------------------
    --SIGNAL FETCH_DECODE_PC_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FETCH_DECODE_PC_PLUS_ONE : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FETCH_DECODE_OP_CODE_OUT : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL FETCH_DECODE_CAT_OUT : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL FETCH_DECODE_IMM_OR_IN_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FETCH_DECODE_RDST_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FETCH_DECODE_RSRC1_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FETCH_DECODE_RSRC2_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    -------------------------------DECODE STAGE OUTPUTS--------------------------------------
    -- SET_CLEAR       : OUT std_logic_vector(1 downto 0);
    -- PC_PLUS_ONE_OUT : OUT std_logic_vector(15 downto 0);
    -- Write_back      : OUT std_logic;
    -- MEM_SRC         : OUT std_logic;
    -- SP_INC          : OUT std_logic;
    -- SP_DEC          : OUT std_logic;
    -- MEM_WRITE       : OUT std_logic;
    -- Out_Signal      : OUT std_logic;
    -- CALL_Signal     : OUT std_logic;
    -- ALU_Operation   : OUT std_logic_vector(2 downto 0);
    -- CIN_Signal      : OUT std_logic;
    -- MEM_TO_REG      : OUT std_logic;
    -- RSRC1_Value     : OUT std_logic_vector(15 downto 0);
    -- RSRC2_Value     : OUT std_logic_vector(15 downto 0);
    -- ALU_SRC         : OUT std_logic;
    -- RSRC1_ADD_OUT   : OUT std_logic_vector(2 downto 0);
    -- RSRC2_ADD_OUT   : OUT std_logic_vector(2 downto 0);
    -- RDST_ADD_OUT    : OUT std_logic_vector(2 downto 0);
    -- IMM_OR_IN_OUT   : OUT std_logic_vector(15 downto 0);
    -- JMP_FLAG        : OUT STD_LOGIC

    -------------------------------INTERMEDIATE STAGE SIGNALS--------------------------------------

    SIGNAL DECODE_WB_ENABLE : STD_LOGIC;
    SIGNAL DECODE_WB_ADD : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DECODE_WB_VALUE : STD_LOGIC_VECTOR(15 DOWNTO 0);

    ---------------------------------------------------------------------------------------
    SIGNAL CONTROLLER_JMP_FLAG : STD_LOGIC;
    SIGNAL DECODE_OP_CODE_OUT : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL DECODE_CAT_OUT : STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL DECODE_EXECUTE_IMM_OR_IN_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL DECODE_EXECUTE_RDST_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DECODE_EXECUTE_RSRC1_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DECODE_EXECUTE_RSRC2_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DECODE_EXECUTE_ALU_SRC_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_ALU_OP_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DECODE_EXECUTE_CIN_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_MEM_TO_REG_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_MEM_WRITE_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_MEM_SRC_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_SP_INC_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_SP_DEC_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_WRITE_BACK_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_PC_PLUS_ONE_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL DECODE_EXECUTE_SET_CLEAR_OUT : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL DECODE_EXECUTE_CALL_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_OUT_OUT : STD_LOGIC;
    SIGNAL DECODE_EXECUTE_RSRC1_VALUE_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL DECODE_EXECUTE_RSRC2_VALUE_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);

    ---------------------------------------------------------------------------------

    -- ZF_OUT : OUT STD_LOGIC;
    -- CF_OUT : OUT STD_LOGIC;
    -- NF_OUT : OUT STD_LOGIC;
    -- PC_PLUS_ONE_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- Write_back_OUT : OUT STD_LOGIC;
    -- MEM_SRC_OUT : OUT STD_LOGIC;
    -- SP_INC_OUT : OUT STD_LOGIC;
    -- SP_DEC_OUT : OUT STD_LOGIC;
    -- MEM_WRITE_OUT : OUT STD_LOGIC;
    -- Out_Signal_OUT : OUT STD_LOGIC;
    -- CALL_Signal_OUT : OUT STD_LOGIC;
    -- MEM_TO_REG_OUT : OUT STD_LOGIC;
    -- Result_Value_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- RSRC2_Value_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- RSRC1_ADD_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- RSRC2_ADD_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- RDST_ADD_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

    -------------------------------EXECUTE STAGE OUTPUTS--------------------------------------
    SIGNAL EXECUTE_ZF_OUT : STD_LOGIC;
    SIGNAL EXECUTE_NF_OUT : STD_LOGIC;
    SIGNAL EXECUTE_CF_OUT : STD_LOGIC;
    SIGNAL EXECUTE_FLAGS : STD_LOGIC_VECTOR(2 DOWNTO 0);
    --FLAGS(2) = Z
    --FLAGS(1) = C
    --FLAGS(0) = N

    SIGNAL EXECUTE_MEM1_PC_PLUS_ONE_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL EXECUTE_MEM1_WB_OUT : STD_LOGIC;
    SIGNAL EXECUTE_MEM1_MEM_SRC_OUT : STD_LOGIC;
    SIGNAL EXECUTE_MEM1_SP_INC_OUT : STD_LOGIC;
    SIGNAL EXECUTE_MEM1_SP_DEC_OUT : STD_LOGIC;
    SIGNAL EXECUTE_MEM1_MEM_WRITE_OUT : STD_LOGIC;
    SIGNAL EXECUTE_MEM1_OUT_OUT : STD_LOGIC;
    SIGNAL EXECUTE_MEM1_CALL_OUT : STD_LOGIC;
    SIGNAL EXECUTE_MEM1_MEM_TO_REG_OUT : STD_LOGIC;
    SIGNAL EXECUTE_MEM1_RESULT_VALUE_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL EXECUTE_MEM1_RSRC2_VALUE_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL EXECUTE_MEM1_RSRC1_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EXECUTE_MEM1_RSRC2_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EXECUTE_MEM1_RDST_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    -------------------------------MEM_ONE STAGE OUTPUTS--------------------------------------

    -- PC_PLUS_ONE_OUT : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- WB_OUT : OUT STD_LOGIC;
    -- SP_INC_OUT : OUT STD_LOGIC;
    -- SP_DEC_OUT : OUT STD_LOGIC;
    -- MEMW_OUT : OUT STD_LOGIC;
    -- OUT_SIG_OUT : OUT STD_LOGIC;
    -- CALL_SIG_OUT : OUT STD_LOGIC;
    -- MEM_TO_REG_OUT : OUT STD_LOGIC;
    -- READ_ADD_OUT : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- WRITE_DATA_OUT : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- RSRC1_ADD_OUT : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
    -- RSRC2_ADD_OUT : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
    -- RDST_ADD_OUT : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
    ------------------------------------------------------------------------------------------------

    SIGNAL MEM1_MEM2_PC_PLUS_ONE_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL MEM1_MEM2_WB_OUT : STD_LOGIC;
    SIGNAL MEM1_MEM2_SP_INC_OUT : STD_LOGIC;
    SIGNAL MEM1_MEM2_SP_DEC_OUT : STD_LOGIC;
    SIGNAL MEM1_MEM2_MEM_WRITE_OUT : STD_LOGIC;
    SIGNAL MEM1_MEM2_OUT_OUT : STD_LOGIC;
    SIGNAL MEM1_MEM2_CALL_OUT : STD_LOGIC;
    SIGNAL MEM1_MEM2_MEM_TO_REG_OUT : STD_LOGIC;
    SIGNAL MEM1_MEM2_READ_ADD_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL MEM1_MEM2_WRITE_DATA_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL MEM1_MEM2_RSRC1_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL MEM1_MEM2_RSRC2_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL MEM1_MEM2_RDST_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -------------------------------MEM_TWO STAGE OUTPUTS--------------------------------------

    -- WbOut, M2ROut, Sp_IncOut, Sp_decOut, OutEnOut, CallSignalOut : OUT STD_LOGIC;
    -- Pc_Out, Memory_Out_data, Read_add_Data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- Rsrc1_Out, Rsrc2_Out, Rdst_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)



    SIGNAL MEM2_SP_INC : STD_LOGIC;
    SIGNAL MEM2_SP_DEC : STD_LOGIC;
    SIGNAL MEM2_WB_WB_OUT : STD_LOGIC;
    SIGNAL MEM2_WB_MEM_TO_REG_OUT : STD_LOGIC;
    SIGNAL MEM2_WB_OUT_OUT : STD_LOGIC;
    
    
    SIGNAL MEM2_WB_MEM_OUT_DATA_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL MEM2_WB_READ_ADD_DATA_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL MEM2_WB_RSRC1_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL MEM2_WB_RSRC2_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL MEM2_WB_RDST_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -------------------------------WB STAGE OUTPUTS--------------------------------------
    -- WbEn : out STD_LOGIC;
    -- Data,outputport : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    --   Rsrc1out,Rsrc2out,Rdstout : out STD_LOGIC_VECTOR(2 DOWNTO 0)




    --NOT_USED-----------------------------------------
    SIGNAL WB_RSRC1_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL WB_RSRC2_ADD_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL MEM2_WB_CALL_OUT : STD_LOGIC;
    SIGNAL MEM2_WB_PC_PLUS_ONE_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);


    ----------- --------------------Forwarding Signals---------------------------------------------------------------
    SIGNAL ALU_DATA_MemoryTwo_Wb : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    
    
    ----------- --------------------Load Signals---------------------------------------------------------------
    SIGNAL Load_OUT : STD_LOGIC;
 




BEGIN
    

    ------------------------------------COMPONENTS-----------------------------------
    FETCH_STAGE_BOX : ENTITY work.fetch_stage PORT MAP (RST, CLK, CONTROLLER_JMP_FLAG, DECODE_EXECUTE_RSRC1_VALUE_OUT, DECODE_OP_CODE_OUT, DECODE_CAT_OUT, IN_PORT, FETCH_DECODE_PC_PLUS_ONE, FETCH_DECODE_OP_CODE_OUT, FETCH_DECODE_CAT_OUT, FETCH_DECODE_IMM_OR_IN_OUT, FETCH_DECODE_RDST_ADD_OUT, FETCH_DECODE_RSRC1_ADD_OUT, FETCH_DECODE_RSRC2_ADD_OUT,Load_OUT);
    DECODE_STAGE_BOX : ENTITY work.Decode_stage PORT MAP (RST, CLK, FETCH_DECODE_RSRC1_ADD_OUT, FETCH_DECODE_RSRC2_ADD_OUT, FETCH_DECODE_RDST_ADD_OUT, FETCH_DECODE_PC_PLUS_ONE, FETCH_DECODE_OP_CODE_OUT, FETCH_DECODE_CAT_OUT, FETCH_DECODE_IMM_OR_IN_OUT, DECODE_WB_ENABLE, DECODE_WB_VALUE , DECODE_WB_ADD, EXECUTE_FLAGS, DECODE_EXECUTE_SET_CLEAR_OUT, DECODE_EXECUTE_PC_PLUS_ONE_OUT, DECODE_EXECUTE_WRITE_BACK_OUT, DECODE_EXECUTE_MEM_SRC_OUT, DECODE_EXECUTE_SP_INC_OUT, DECODE_EXECUTE_SP_DEC_OUT, DECODE_EXECUTE_MEM_WRITE_OUT, DECODE_EXECUTE_OUT_OUT, DECODE_EXECUTE_CALL_OUT, DECODE_EXECUTE_ALU_OP_OUT, DECODE_EXECUTE_CIN_OUT, DECODE_EXECUTE_MEM_TO_REG_OUT, DECODE_EXECUTE_RSRC1_VALUE_OUT, DECODE_EXECUTE_RSRC2_VALUE_OUT, DECODE_EXECUTE_ALU_SRC_OUT, DECODE_EXECUTE_RSRC1_ADD_OUT, DECODE_EXECUTE_RSRC2_ADD_OUT, DECODE_EXECUTE_RDST_ADD_OUT, DECODE_EXECUTE_IMM_OR_IN_OUT, CONTROLLER_JMP_FLAG, DECODE_OP_CODE_OUT, DECODE_CAT_OUT,EXECUTE_MEM1_MEM_TO_REG_OUT ,EXECUTE_MEM1_RSRC2_ADD_OUT ,Load_OUT );
    EXECUTE_STAGE_BOX : ENTITY work.Execute_stage PORT MAP (RST, CLK, DECODE_EXECUTE_SET_CLEAR_OUT, DECODE_EXECUTE_PC_PLUS_ONE_OUT, DECODE_EXECUTE_WRITE_BACK_OUT, DECODE_EXECUTE_MEM_SRC_OUT, DECODE_EXECUTE_SP_INC_OUT, DECODE_EXECUTE_SP_DEC_OUT, DECODE_EXECUTE_MEM_WRITE_OUT, DECODE_EXECUTE_OUT_OUT, DECODE_EXECUTE_CALL_OUT, DECODE_EXECUTE_ALU_OP_OUT, DECODE_EXECUTE_CIN_OUT, DECODE_EXECUTE_MEM_TO_REG_OUT, DECODE_EXECUTE_RSRC1_VALUE_OUT, DECODE_EXECUTE_RSRC2_VALUE_OUT, DECODE_EXECUTE_ALU_SRC_OUT, DECODE_EXECUTE_RSRC1_ADD_OUT, DECODE_EXECUTE_RSRC2_ADD_OUT, DECODE_EXECUTE_RDST_ADD_OUT, DECODE_EXECUTE_IMM_OR_IN_OUT, EXECUTE_ZF_OUT, EXECUTE_CF_OUT, EXECUTE_NF_OUT, EXECUTE_MEM1_PC_PLUS_ONE_OUT, EXECUTE_MEM1_WB_OUT, EXECUTE_MEM1_MEM_SRC_OUT, EXECUTE_MEM1_SP_INC_OUT, EXECUTE_MEM1_SP_DEC_OUT, EXECUTE_MEM1_MEM_WRITE_OUT, EXECUTE_MEM1_OUT_OUT, EXECUTE_MEM1_CALL_OUT, EXECUTE_MEM1_MEM_TO_REG_OUT, EXECUTE_MEM1_RESULT_VALUE_OUT, EXECUTE_MEM1_RSRC2_VALUE_OUT, EXECUTE_MEM1_RSRC1_ADD_OUT, EXECUTE_MEM1_RSRC2_ADD_OUT, EXECUTE_MEM1_RDST_ADD_OUT,EXECUTE_MEM1_RESULT_VALUE_OUT,MEM1_MEM2_READ_ADD_OUT ,MEM2_WB_READ_ADD_DATA_OUT , EXECUTE_MEM1_RDST_ADD_OUT ,MEM1_MEM2_RDST_ADD_OUT ,MEM2_WB_RDST_ADD_OUT ,  EXECUTE_MEM1_WB_OUT, MEM1_MEM2_WB_OUT,MEM2_WB_WB_OUT );
    MEMORY_ONE_STAGE_BOX : ENTITY work.MEM_ONE PORT MAP (RST,CLK , EXECUTE_MEM1_PC_PLUS_ONE_OUT , EXECUTE_MEM1_WB_OUT , EXECUTE_MEM1_MEM_SRC_OUT , EXECUTE_MEM1_SP_INC_OUT , EXECUTE_MEM1_SP_DEC_OUT , EXECUTE_MEM1_MEM_WRITE_OUT , EXECUTE_MEM1_OUT_OUT , EXECUTE_MEM1_CALL_OUT , EXECUTE_MEM1_MEM_TO_REG_OUT , EXECUTE_MEM1_RESULT_VALUE_OUT , EXECUTE_MEM1_RSRC1_ADD_OUT , EXECUTE_MEM1_RSRC2_ADD_OUT , EXECUTE_MEM1_RDST_ADD_OUT , EXECUTE_MEM1_RSRC2_VALUE_OUT , MEM2_SP_INC , MEM2_SP_DEC , MEM1_MEM2_PC_PLUS_ONE_OUT , MEM1_MEM2_WB_OUT , MEM1_MEM2_SP_INC_OUT , MEM1_MEM2_SP_DEC_OUT , MEM1_MEM2_MEM_WRITE_OUT , MEM1_MEM2_OUT_OUT , MEM1_MEM2_CALL_OUT , MEM1_MEM2_MEM_TO_REG_OUT , MEM1_MEM2_READ_ADD_OUT , MEM1_MEM2_WRITE_DATA_OUT , MEM1_MEM2_RSRC1_ADD_OUT , MEM1_MEM2_RSRC2_ADD_OUT , MEM1_MEM2_RDST_ADD_OUT);
    MEMORY_TWO_STAGE_BOX : ENTITY work.MemoryStage2 PORT MAP (CLK , RST , MEM1_MEM2_WB_OUT , MEM1_MEM2_MEM_TO_REG_OUT , MEM1_MEM2_SP_INC_OUT , MEM1_MEM2_SP_DEC_OUT , MEM1_MEM2_MEM_WRITE_OUT , MEM1_MEM2_OUT_OUT , MEM1_MEM2_CALL_OUT , MEM1_MEM2_PC_PLUS_ONE_OUT , MEM1_MEM2_READ_ADD_OUT , MEM1_MEM2_WRITE_DATA_OUT, MEM1_MEM2_RSRC1_ADD_OUT , MEM1_MEM2_RSRC2_ADD_OUT , MEM1_MEM2_RDST_ADD_OUT , MEM2_WB_WB_OUT , MEM2_WB_MEM_TO_REG_OUT  , MEM2_SP_INC , MEM2_SP_DEC , MEM2_WB_OUT_OUT , MEM2_WB_CALL_OUT , MEM2_WB_PC_PLUS_ONE_OUT , MEM2_WB_MEM_OUT_DATA_OUT , MEM2_WB_READ_ADD_DATA_OUT , MEM2_WB_RSRC1_ADD_OUT , MEM2_WB_RSRC2_ADD_OUT , MEM2_WB_RDST_ADD_OUT,ALU_DATA_MemoryTwo_Wb);
    --Needs Fixing
    WB_STAGE_BOX : ENTITY work.WbRegister PORT MAP (MEM2_WB_WB_OUT , MEM2_WB_MEM_TO_REG_OUT , MEM2_WB_OUT_OUT , MEM2_WB_MEM_OUT_DATA_OUT , MEM2_WB_READ_ADD_DATA_OUT , MEM2_WB_RSRC1_ADD_OUT , MEM2_WB_RSRC2_ADD_OUT , MEM2_WB_RDST_ADD_OUT , DECODE_WB_ENABLE , DECODE_WB_VALUE , OUT_PORT , WB_RSRC1_ADD_OUT , WB_RSRC2_ADD_OUT , DECODE_WB_ADD);
    ---------------------------------------OUTPUTS------------------------------------
    ---------------------------------------LOGIC--------------------------------------
    EXECUTE_FLAGS <= EXECUTE_ZF_OUT & EXECUTE_CF_OUT & EXECUTE_NF_OUT;
END ARCHITECTURE Pipelined_arch;

------22