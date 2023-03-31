library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.all;
--use ieee.numeric_std.ALL;
use ieee.std_logic_arith.ALL;

entity draw_trex is
	generic(
		H_counter_size: natural:= 10;
		V_counter_size: natural:= 10
	);
	port(
		clk: in std_logic;
		jump: in std_logic;
		abajo: in std_logic;
		pixel_x: in integer;
		pixel_y: in integer;
		rgbDrawColor: out std_logic_vector(11 downto 0) := (others => '0')
	);
end draw_trex;

architecture arch of draw_trex is
	constant PIX : integer := 16;
	constant PIX2 : integer := 32;
	constant COLS : integer := 40;
	constant T_FAC : integer := 100000;
	constant cactusSpeed : integer := 40;
	constant nubeSpeed: integer := 3;
	
	signal cloudX_1: integer := 40;
	signal cloudY_1: integer := 8;
	signal cloud2X_2: integer := 64;
	signal cloud2Y_2: integer := 64;
	
	
	-- T-Rex
	signal trexX: integer := 8;
	signal trexY: integer := 24;
	signal saltando: std_logic := '0';	
	signal agachado: std_logic := '0';
	
	-- Cactus	
	signal cactusX_1: integer := COLS;
	signal cactusY: integer := 24;
	
	--nube 
	signal nubeX_1: integer := COLS-5;
	
	
	
-- Sprites
type sprite_block is array(0 to 15, 0 to 15) of integer range 0 to 1;
constant cloud: sprite_block:=(  (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 5
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 6
									 (0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0), -- 7
									 (0,0,0,0,0,1,1,0,0,0,1,1,1,1,0,0), -- 8	
									 (0,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1), -- 9
									 (1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1), -- 10
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 11
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15
									 



											 
									 



constant trex_2: sprite_block:=((0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 0 
									(0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1), -- 1 
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 2
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 3
									(0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0), -- 4
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0), -- 5
									(0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 6
									(1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 7
									(1,1,0,0,1,1,1,1,1,1,1,0,0,1,0,0), -- 8
									(1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
									(0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 10
									(0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 11
									(0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
		 							(0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0), -- 13
									(0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0), -- 14
									(0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0));-- 15	

constant cactus: sprite_block :=((0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,1,0,1,1,1,0,1,0,0,0,0), -- 4
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 5
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 6
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 7
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 8
									 (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 9
									 (0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0), -- 10
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 11
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0));-- 15					
						
type sprite_block2 is array(0 to 15, 0 to 15) of integer range 0 to 1;
constant trex_down: sprite_block:=((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),-- 15		
									(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),-- 15		
									(0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0),-- 15		
									(0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0),-- 15		
									(0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0),-- 15		
									(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0),-- 15		
									(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0),-- 15		
									(1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0),-- 15		
									(1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,0),-- 15		
									(1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0),-- 15		
									(1,1,1,1,1,1,0,0,1,0,1,0,1,1,1,0),-- 15		
									(0,1,1,0,0,1,1,0,0,0,1,0,1,1,1,0),-- 15		
									(0,1,0,0,0,0,1,0,0,0,1,0,1,1,1,0),-- 15		
									(1,1,0,0,0,0,1,1,0,0,1,0,1,1,1,0),-- 15		
									(1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0));-- 15		
							
									 
type color_arr is array(0 to 1) of std_logic_vector(11 downto 0);									 
constant sprite_color : color_arr := ("000000000000", "001111110000");

begin
	draw_objects: process(clk, pixel_x, pixel_y)	
	
	variable sprite_x : integer := 0;
	variable sprite_y : integer := 0;
	variable sprite_x2 : integer := 0;
	variable sprite_y2 : integer := 0;
	
	begin			
		if(clk'event and clk='1') then		
			-- Dibuja el fondo
			rgbDrawColor <= "0000" & "0000" & "0000";
					
			-- Dibuja el suelo
			if(pixel_y = 400 or pixel_y = 401) then
				rgbDrawColor <= "1100" & "1100" & "1100";		
			end if;
			
			sprite_x := pixel_x mod PIX;
			sprite_y := pixel_y mod PIX;
			sprite_x2 := pixel_x mod PIX2;
			sprite_y2 := pixel_y mod PIX2;
			
							
			-- Nube 1
			if ((pixel_x / PIX = 1) and (pixel_y / PIX = 3)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;	
			
			-- Nube 2
			if ((pixel_x / PIX = 27) and (pixel_y / PIX = 8)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;			
			
			-- Nube 3
			if ((pixel_x / PIX = 13) and (pixel_y / PIX = 12)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;			
			
			-- Nube 4
			if ((pixel_x / PIX = nubeX_1) and (pixel_y / PIX = 14)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;			
			
			-- Nube 5
			if ((pixel_x / PIX = nubeX_1) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;			
			
			
						
			-- Cactus1
			if ((pixel_x / PIX = cactusX_1) and (pixel_y / PIX = cactusY)) then 
				rgbDrawColor <= sprite_color(cactus(sprite_y, sprite_x));
			end if;				
						
						
			-- T-Rex
			if(abajo='0')then
				if (saltando = '1') then
					if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
						rgbDrawColor <= sprite_color(trex_2(sprite_y, sprite_x));			
					end if;
				else
					if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
						rgbDrawColor <= sprite_color(trex_2(sprite_y, sprite_x));			
					end if;
				end if;
			else	
				if (pixel_x / PIX = trexX) and (pixel_y / PIX = trexY) then
					rgbDrawColor <= sprite_color(trex_down(sprite_y, sprite_x));
				end if;	
			end if;
		end if;
	end process;
	
	actions: process(clk, jump)	
		variable cactusCount: integer := 0;
		variable nubeCount: integer := 0;
		
		
	begin		
			
			if(clk'event and clk = '1') then
			
			-- Salto
			if(jump = '1') then
				saltando <= '1';
				if (trexY > 20) then
					trexY <= trexY - 1;
				else
					saltando <= '0';
				end if;
			else
			   saltando <= '0';
				if (trexY < 24) then
					trexY <= trexY + 1;
				end if;
			end if;		
			
			
			
			
			-- Movimiento del Cactus
			-- Cactus Movement
			if (cactusCount >= T_FAC * cactusSpeed) then
				if (cactusX_1 <= 0) then
					cactusX_1 <= COLS;				
				else
					cactusX_1 <= cactusX_1 - 1;					
				end if;
				cactusCount := 0;
			end if;
			cactusCount := cactusCount + 1;
			
			-- Movimiento del Cactus
			-- Cactus Movement
			if (nubeCount >= T_FAC * cactusSpeed) then
				if (nubeX_1 <= 0) then
					nubeX_1 <= COLS;				
				else
					nubeX_1 <= cactusX_1 - 1;					
				end if;
				nubeCount := 0;
			end if;
			nubeCount := nubeCount + 1;
			
			
			
			end if;
	end process;
	
end arch;