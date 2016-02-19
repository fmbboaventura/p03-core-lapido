-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--  				Arquivo de de teste para o componente ram 					 --
-----------------------------------------------------------------------------------
--   Le os dados do arquivo "rom.out" para a memoria, incrementa de uma unidade  --
--cada valor da memoria e guarda os novos valores da memoria no arquivo data.out --
-----------------------------------------------------------------------------------
--    Arquivo de teste do componente ram desenvolvido para a disciplina de     	 --
--                      MI -- Sistemas Digitais									 --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
library ieee;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

entity ram_tb is
		generic(
			dim : INTEGER := 1024 );
end ram_tb;

architecture TB_ARCHITECTURE of ram_tb is
	component ram
		generic(
			dim : INTEGER := 1024 );
		port(
			read_file : in std_logic;
			write_file : in std_logic;
			WE : in std_logic;
			clk : in std_logic;
			ADRESS : in std_logic_vector(9 downto 0);
			DATA : in std_logic_vector(31 downto 0);
			Q : out std_logic_vector(31 downto 0) );
	end component;

	signal read_file : std_logic;
	signal write_file : std_logic;
	signal WE : std_logic;
	signal clk : std_logic;
	signal ADRESS : std_logic_vector(9 downto 0);
	signal DATA : std_logic_vector(31 downto 0);
	signal Q : std_logic_vector(31 downto 0);
begin
	MEMB : ram
		generic map (
			dim => dim
		)
		port map (
			read_file => read_file,
			write_file => write_file,
			WE => WE,
			clk => clk,
			ADRESS => ADRESS,
			DATA => DATA,
			Q => Q
		);

	teste : process	
	variable DATA_TMP : STD_LOGIC_VECTOR(31 downto 0);
	variable index : integer;
	begin  
		write_file <='0';
		read_file <='0';	
		clk <= '0';
		-- le o arquivo rom.out para a memoria 	
		WAIT FOR 1 PS;
		read_file <='1';
		WAIT FOR 1 PS; 
		clk <= '1';		
		WAIT FOR 1 PS;
		read_file <='0';
		clk <= '0';
		WAIT FOR 1 PS;

		index := 0;

		while (index < dim) loop
			-- le a posicao da memoriadada por 'index' e coloca em DATA_TMP
			WE <= '0';
			ADRESS <= CONV_STD_LOGIC_VECTOR(index,10);
			clk <= '1';
			WAIT FOR 1 PS;	
			clk <= '0';		
			WAIT FOR 1 PS;
			DATA_TMP := Q;		
			-- calcula o novo valor a escrever na memoria (incrementa o valor)
			DATA <= DATA_TMP + 1;
			-- escreve a posicao de memoria	dada por 'index'
			WE <= '1';
			WAIT FOR 1 PS;		
			clk <= '1';
			WAIT FOR 1 PS;		
			WE <= '0';
			clk <= '0';	
			WAIT FOR 1 PS;				
			index := index +1;
		end loop;
		-- escreve a memoria no arquivo data.out
		write_file <='1';
		clk <= '1';
		WAIT FOR 1 PS;
		clk <= '0';	  
		write_file <='0';
	 	report "O arquivo data.out foi escrito." severity Warning;
		wait for 10 us;
	end process teste;	
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_ram of ram_tb is
	for TB_ARCHITECTURE
		for MEMB : ram
			use entity work.ram(ram_arch);
		end for;
	end for;
end TESTBENCH_FOR_ram;