library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity clkd is
Port ( clk: in STD_LOGIC:='0';
sel : in STD_LOGIC_VECTOR(4 downto 0);
wave_out: out STD_LOGIC_VECTOR(7 downto 0):="00000000");
end clkd;
architecture Behavioral of clkd is
signal clk_sig:STD_LOGIC:='0';
signal sin :STD_LOGIC_VECTOR(7 downto 0);
signal cos: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal tri: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal sta_00: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal sta_01: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal sta: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal exp_pos: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal exp_neg: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal exp: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal pulse: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal noise: STD_LOGIC_VECTOR(7 downto 0):="00000000";
signal clkout,ramp:STD_LOGIC_vector(7 downto 0):="00000000";
signal count_tri,count2_tri: integer := 0;
signal direction_tri : std_logic := '0';
signal count_00,count2_00 : integer := 0;
signal direction_00 : std_logic := '0';
signal count_01,count2_01 : integer := 0;
signal direction_01 : std_logic := '0';
signal PULSE_out: std_logic:='0';
signal cnt20,cnt40,cnt60,cnt80: std_logic;
signal  feed_back0,feed_back1,feed_back2,feed_back3,feed_back4,feed_back5,feed_back6,feed_back7 :std_logic:='0';
signal lfsr_reg0:std_logic_vector(2 downto 0):="111";
signal lfsr_reg1:std_logic_vector(2 downto 0):="110";
signal lfsr_reg2:std_logic_vector(2 downto 0):= "001";
signal lfsr_reg3:std_logic_vector(2 downto 0):="000";
signal lfsr_reg4:std_logic_vector(2 downto 0):="010";
signal lfsr_reg5:std_logic_vector(2 downto 0):="011";
signal lfsr_reg6:std_logic_vector(2 downto 0):="101";
signal lfsr_reg7:std_logic_vector(2 downto 0):="100";
signal prbs_out0,prbs_out1,prbs_out2,prbs_out3,prbs_out4,prbs_out5,prbs_out6,prbs_out7: std_logic:='0';
signal prbs_out01,prbs_out02,prbs_out03,prbs_out04,prbs_out05,prbs_out06,prbs_out07,prbs_out08: std_logic:='0';
type freq_syn_sin is array (0 to 71) of std_logic_vector(7 downto 0);
constant data_sin : freq_syn_sin:=(x"80",x"8B",x"96",x"A0",x"AB",x"B5",x"BF",
x"C9",x"D1",x"DA",x"E1",x"E8",x"EE",x"F3",x"F7",x"FB",x"FD", x"FE",x"FF"
,x"FE",x"FD",x"FB",x"F7",x"F3",x"EE",x"E8",x"E1",x"DA",x"D1",x"C9",x"BF"
,x"B5",x"AB",x"A0",x"96",x"8B",x"80",x"74",x"69",x"5F",x"54",x"4A",x"40"
,x"36",x"2E",x"25",x"1E",x"17",x"11",x"0C",x"08",x"04",x"02",x"01",x"00"
,x"01",x"02",x"04",x"08",x"0C",x"11",x"17",x"1E",x"25",x"2E",x"36",x"40"
,x"4A",x"54",x"5F",x"69",x"74");
type freq_syn_cos is array (0 to 71) of std_logic_vector(7 downto 0);
constant data_cos : freq_syn_cos:=(x"FF",x"FE",x"FD",x"FB",x"F7",x"F3",x"EE",x"E8",x"E1",x"DA",x"D1",x"C9",x"BF"
,x"B5",x"AB",x"A0",x"96",x"8B",x"80",x"74",x"69",x"5F",x"54",x"4A",x"40"
,x"36",x"2E",x"25",x"1E",x"17",x"11",x"0C",x"08",x"04",x"02",x"01",x"00"
,x"01",x"02",x"04",x"08",x"0C",x"11",x"17",x"1E",x"25",x"2E",x"36",x"40"
,x"4A",x"54",x"5F",x"69",x"74",x"80",x"8B",x"96",x"A0",x"AB",x"B5",x"BF" ,x"C9",x"D1",x"DA",x"E1",x"E8",x"EE",x"F3",x"F7",x"FB",x"FD", x"FE");

type freq_exp_pos is array (0 to 39) of std_logic_vector(7 downto 0);
constant data_pos : freq_exp_pos:= (x"03",x"04",x"05",x"06",x"07",x"08",x"09",x"0A",x"0B",x"0C",x"0D",x"0E",x"10",x"12",
                            x"14",x"16",x"18",x"1B",x"1E",x"21",x"24",x"28",x"2C",x"31",x"36",x"3C",x"42",x"49",
                            x"51",x"5A",x"63",x"6E",x"79",x"86",x"94",x"A4",x"B5",x"C9",x"DD",x"F5");
                           
type freq_exp_neg is array (0 to 39) of std_logic_vector(7 downto 0);
constant data_neg : freq_exp_neg:= (x"F5",x"DD",x"C9",x"B5",x"A4",x"94",x"86",x"79",x"6E",x"63",x"5A",x"51",x"49",x"42",
                            x"3C",x"36",x"31",x"2C",x"28",x"24",x"21",x"1E",x"1B",x"18",x"16",x"14",x"12",x"10",
                            x"0E",x"0D",x"0C",x"0B",x"0A",x"09",x"08",x"07",x"06",x"05",x"04",x"03");                          
begin
p0:process(clk)
variable cnt:integer:=0;
begin
if rising_edge(clk) then
if(cnt=100)then --Value has to be chosen based on the
clk_sig<= not(clk_sig);--on-board clock rate.
cnt:=0;
else
cnt:= cnt + 1;
end if;
end if;
end process;
p1:process(clk)
variable cnt1:integer:=0;
begin
if rising_edge(clk) then
if cnt1=71 then
cnt1:=0;
else
sin<=data_sin(cnt1);
cnt1:=cnt1+1;
end if;
end if;
end process;
p2:process(clk)
variable cnt1:integer:=0;
begin
if rising_edge(clk) then
if cnt1=71 then
cnt1:=0;
else
cos<=data_cos(cnt1);
cnt1:=cnt1+1;
end if;
end if;
end process;
p3:process(clk)
begin
if rising_edge(clk) then
clkout<= clkout+"00000001";
end if;
ramp<=clkout;
end process;
p4:process(clk)
begin
if(rising_edge(clk)) then
    --"direction" signal determines the direction of counting - up or down
    if(count_tri = 254) then
        count_tri <= 0;
        if(direction_tri = '0') then
            direction_tri <= '1';
            count2_tri <= 126;
        else
            direction_tri <= '0';
            count2_tri <= 129;
        end if;
    else
        count_tri <= count_tri + 1;
    end if;
    if(direction_tri = '0') then
        if(count2_tri = 256) then
            count2_tri <= 0;
        else
            count2_tri <= count2_tri + 1; --up counts from 129 to 255 and then 0 to 127
        end if;
    else
        if(count2_tri = 256) then
            count2_tri <= 0;
        else
            count2_tri <= count2_tri - 1; --down counts from 126 to 0 and then 255 to 128
        end if;
    end if;    
end if;
tri <= conv_std_logic_vector(count2_tri,8);
end process;
p5: process(clk_sig)
begin
if(rising_edge(clk_sig)) then
    --"direction" signal determines the direction of counting - up or down
    if(count_00 = 8) then
        count_00 <= 0;
        if(direction_00 = '0') then
            direction_00 <= '1';
            count2_00 <= 8;
        else
            direction_00 <= '0';
            count2_00 <= 9;
        end if;
    else
        count_00 <= count_00 + 1;
    end if;
    if(direction_00 = '0') then
        if(count2_00 = 15) then
            count2_00 <= 0;
        else
            count2_00 <= count2_00 + 1; --up counts from 129 to 255 and then 0 to 127
        end if;
    else
        if(count2_00 = 15) then
            count2_00 <= 0;
        else
            count2_00 <= count2_00 - 1; --down counts from 126 to 0 and then 255 to 128
        end if;
    end if;
end if;
sta_00 <= conv_std_logic_vector(count2_00 ,8);
end process;
p6: process(clk_sig)
begin
  if(rising_edge(clk_sig)) then
    --"direction" signal determines the direction of counting - up or down
    if(count_01 =15) then
        count_01 <= 0;
      else
      count_01 <= count_01 + 1;
    end if;
    end if;
  sta_01 <= conv_std_logic_vector(count_01,8);
end process;
p7: process(clk_sig)
variable cnt1:integer:=0;
begin
if rising_edge(clk_sig) then
if cnt1=39 then
cnt1:=0;
else
exp_pos<=data_pos(cnt1);
cnt1:=cnt1+1;
end if;
end if;
end process;
p8:process(clk_sig)
variable cnt1:integer:=0;
begin
if rising_edge(clk_sig) then
if cnt1=39 then
cnt1:=0;
else
exp_neg<=data_neg(cnt1);
cnt1:=cnt1+1;
end if;
end if;
end process;
p9: process(clk_sig) --Duty Cycle section
variable cnt1:integer:=1;
begin
if rising_edge(clk_sig) then
if (cnt1=2) then
cnt20<='0';
cnt1:=cnt1+1;
elsif (cnt1=4) then
cnt40<='0';
cnt1:=cnt1+1;
elsif (cnt1=6) then
cnt60<='0';
cnt1:=cnt1+1;
elsif (cnt1=8) then
cnt80<='0';
cnt1:=cnt1+1;
elsif (cnt1=10) then
cnt20<='1';
cnt40<='1';
cnt60<='1';
cnt80<='1';
cnt1:=1;
else
cnt1:=cnt1+1;
end if;
end if;
end process;
p10: process(cnt20,cnt40,cnt60,cnt80,sel)
begin
case sel(4 downto 3) is
when "00" => PULSE_OUT<= cnt20;
when "01" => PULSE_OUT<= cnt40;
when "10" => PULSE_OUT<= cnt60;
when "11" => PULSE_OUT<= cnt80;
when others =>PULSE_OUT<= '1' ;
end case;
end process;
p11: process( pulse_out)
begin
if pulse_out='1' then
pulse<="00001000";
elsif pulse_out='0' then
pulse<="00000000";
end if;
end process;
p12:process(clk_sig)
begin
if rising_edge(clk_sig) then
feed_back0<=(lfsr_reg0(1) xor lfsr_reg0(0));
end if;
if falling_edge(clk_sig) then
lfsr_reg0<= (feed_back0 & lfsr_reg0(2 downto 1));
prbs_out0<=lfsr_reg0(2);
end if;
end process;
p13:process(clk_sig)
begin
if rising_edge(clk_sig) then
feed_back1<=(lfsr_reg1(1) xor lfsr_reg1(0));
end if;
if falling_edge(clk_sig) then
lfsr_reg1<= (feed_back1 & lfsr_reg1(2 downto 1));
prbs_out1<=lfsr_reg1(1);
end if;
end process;
p14:process(clk_sig)
begin
if rising_edge(clk_sig) then
feed_back2<=(lfsr_reg2(1) xor lfsr_reg2(0));
end if;
if falling_edge(clk_sig) then
lfsr_reg2<= (feed_back2 & lfsr_reg2(2 downto 1));
prbs_out2<=lfsr_reg2(2);
end if;
end process;
p15:process(clk_sig)
begin
if rising_edge(clk_sig) then
feed_back3<=(lfsr_reg3(1) xor lfsr_reg3(0));
end if;
if falling_edge(clk_sig) then
lfsr_reg3<= (feed_back3 & lfsr_reg3(2 downto 1));
prbs_out3<=lfsr_reg3(0);
end if;
end process;
p16:process(clk_sig)
begin
if rising_edge(clk_sig) then
feed_back4<=(lfsr_reg4(1) xor lfsr_reg4(0));
end if;
if falling_edge(clk_sig) then
lfsr_reg4<= (feed_back4 & lfsr_reg4(2 downto 1));
prbs_out4<=lfsr_reg4(2);
end if;
end process;
p17:process(clk_sig)
begin
if rising_edge(clk_sig) then
feed_back5<=(lfsr_reg5(1) xor lfsr_reg5(0));
end if;
if falling_edge(clk_sig) then
lfsr_reg5<= (feed_back5 & lfsr_reg5(2 downto 1));
prbs_out5<=lfsr_reg5(2);
end if;
end process;
p18:process(clk_sig)
begin
if rising_edge(clk_sig) then
feed_back6<=(lfsr_reg6(1) xor lfsr_reg6(0));
end if;
if falling_edge(clk_sig) then
lfsr_reg6<= (feed_back6 & lfsr_reg6(2 downto 1));
prbs_out6<=lfsr_reg6(1);
end if;
end process;
p19:process(clk_sig)
begin
if rising_edge(clk_sig) then
feed_back7<=(lfsr_reg7(1) xor lfsr_reg7(0));
end if;
if falling_edge(clk_sig) then
lfsr_reg7<= (feed_back7 & lfsr_reg7(2 downto 1));
prbs_out7<=lfsr_reg7(0);
end if;
end process;
p20: process(prbs_out0,prbs_out1,prbs_out2,prbs_out3,prbs_out4,prbs_out5,prbs_out6,prbs_out7)
begin
prbs_out01<=prbs_out0 xor prbs_out7 xor prbs_out4 xor prbs_out5;
prbs_out02<=prbs_out1 xor prbs_out4  xor prbs_out0 ;
prbs_out03<=prbs_out2 xor prbs_out6  xor prbs_out1;
prbs_out04<=prbs_out3 xor prbs_out5 xor prbs_out6;
prbs_out05<=prbs_out01 xor prbs_out03 xor prbs_out1 ;
prbs_out06<=prbs_out02 xor prbs_out05 xor prbs_out5  ;
prbs_out07<=prbs_out04 xor prbs_out06 xor prbs_out4 xor prbs_out05;
prbs_out08<=prbs_out01 xor prbs_out07 xor prbs_out06 xor prbs_out04;
noise<= prbs_out01 & prbs_out07 & prbs_out02 & prbs_out03 & prbs_out06 & prbs_out05 & prbs_out04 & prbs_out08;
end process;
p21:process(sta_00,sta_01)
begin
case sel(4 downto 3) is
when "00" => sta<=sta_00;
when "01" => sta<=sta_01;
when others => sta<="00000000";
end case;
end process;
p22:process(exp_pos,exp_neg)
begin
case sel(4 downto 3) is
when "00" => exp<=exp_pos;
when "01" => exp<=exp_neg;
when others => exp<="00000000";
end case;
end process;
p23: process (sel, sin,cos,tri,sta,noise, pulse, exp,ramp)
begin
case sel(2 downto 0) is
when "000" => wave_out<=sin;
when "001" => wave_out<=cos;
when "010" => wave_out<=ramp;
when "011" => wave_out<=tri;
when "100" => wave_out<=sta;
when "101" => wave_out<=exp;
when "110" => wave_out<=pulse;
when "111" => wave_out<=noise;
when others => wave_out<="00000000";
end case;
end process;
end Behavioral;