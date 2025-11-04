module led(
 input       clk50m,
 input                                 app_rx_data_valid       ,
 input                 [   7:   0]     app_rx_data             ,
 input  wire           [  15:   0]     app_rx_data_length      ,
 input                                 udp_rx_clk              ,
 input  wire                           reset                   ,
 output                                led ,
 output          [3:0] led_data_1 ,
 output          [15:0] dled                                    
 );

reg  [63:0]led_data;
    reg                [  15:   0]     cnt                         ;
    reg                [   1:   0]     state                       ;
    always @(posedge udp_rx_clk or negedge reset)
        begin
            if(!reset)  begin
            cnt   <=16'b0;
            end
            else if (app_rx_data_valid & cnt<(app_rx_data_length-1))begin
                        cnt<=cnt+1;
                    end
                    
            else if (app_rx_data_valid & cnt==(app_rx_data_length-1))
                        cnt<=16'b0;
                        
            else
                        cnt<=cnt;
                    end

    always @(posedge udp_rx_clk or negedge reset)
        begin
            if(!reset)
              led_data<=64'b0;
            else if (app_rx_data_valid)
            case (cnt)
                0:led_data[63:56]<=app_rx_data;
                1:led_data[55:48]<=app_rx_data;
                2:led_data[47:40]<=app_rx_data;
                3:led_data[39:32]<=app_rx_data;
                4:led_data[31:24]<=app_rx_data;
                5:led_data[23:16]<=app_rx_data;
                6:led_data[15:8] <=app_rx_data;
                7:led_data[7:0]  <=app_rx_data;
            endcase
                                                     
            else
            led_data <=led_data;
        end

assign led_data_1 = led_data[63:60];
//assign  dled    = led_data[55:40];


wire [3:0]seg_ctrl;
assign seg_ctrl = led_data[59:56];
    // assign             led   = led_data[63];
    
//--------------------scan seg-------------------------------------------------------//
	//output[6:0] dataout;
	//output[7:0] en;//COM使能输出

	reg[6:0] dataout;//各段数据输出
	reg[7:0] en;

	reg[15:0] cnt_scan;//扫描频率计数器
	reg[3:0] dataout_buf;

	always@(posedge clk50m or negedge  reset)
		begin
			if(!reset) 
				begin //低电平复位
					cnt_scan<=0;
				end
			else 
				begin
					cnt_scan<=cnt_scan+1'b1;
				end
		end

	always @(cnt_scan)//段码扫描频率
		begin 
		  case(cnt_scan[15:13])
				3'b000 :
					en = 8'b1111_1110;	
				3'b001 :
					en = 8'b1111_1101;
				3'b010 :
					en = 8'b1111_1011;
				3'b011 :
					en = 8'b1111_0111;
				3'b100 :
					en = 8'b1110_1111;
				3'b101 :
					en = 8'b1101_1111;
				3'b110 :
					en = 8'b1011_1111;
				3'b111 :
					en = 8'b0111_1111;
			default :
				en = 8'b1111_1110;
			endcase
		end
		
	always@(en) //对应COM信号给出各段数据，段码
		begin
			case(en)
				8'b1111_1110:
					dataout_buf=1;//输入将要显示的数字
				8'b1111_1101:
					dataout_buf=2;
				8'b1111_1011:
					dataout_buf=3;
				8'b1111_0111:
					dataout_buf=4;   
				8'b1110_1111:
					dataout_buf=5;   
				8'b1101_1111:
					dataout_buf=6;   
				8'b1011_1111:
					dataout_buf=7;   
				8'b0111_1111:
					dataout_buf=8;   
				default:
					dataout_buf=0;
			 endcase
		end

	always@(dataout_buf)	
		begin
			case(dataout_buf)  //将要显示的数字译成段码
					4'b0000	:	dataout	<=	7'b1000_000;//7'b0111_111;
					4'b0001	:	dataout	<=	7'b1111_001;//7'b0000_110;
					4'b0010	:	dataout	<=	7'b0100_100;//7'b1011_011;
					4'b0011	:	dataout	<=	7'b0110_000;//7'b1001_111;
					4'b0100	:	dataout	<=	7'b0011_001;//7'b1100_110;
					4'b0101	:	dataout	<=	7'b0010_010;//7'b1101_101;
					4'b0110	:	dataout	<=   7'b0000_010;//7'b1111_101;
					4'b0111	:	dataout	<=	7'b1111_000;//7'b0000_111;
					4'b1000	:	dataout	<=	7'b0000_000;//7'b1111_111;
					4'b1001	:	dataout	<=	7'b0010_000;//7'b1101_111;
					4'b1010	:	dataout	<=	7'b0001_000;//7'b1110_111;
					4'b1011	:	dataout	<=	7'b0000_011;//7'b1111_100;
					4'b1100	:	dataout	<=	7'b1000_110;//7'b0111_001;
					4'b1101	:	dataout	<=	7'b0100_001;//7'b1011_110;
					4'b1110	:	dataout	<=	7'b0000_110;//7'b1111_001;
					4'b1111	:	dataout	<=	7'b0001_110;//7'b1110_001;
					default	:	dataout	<=	7'b1000_000;//7'b0111_111;	
			 endcase
		end

//assign  dled    = led_data[55:40];
// seg_ctrl

assign  dled  = (seg_ctrl==4'hf) ? {en[0],en[1],en[2],en[3],en[4],en[5],en[6],en[7],1'b0,dataout[6:0]} : led_data[55:40]; 


// { dled[0] }	{ LOCATION = C15;  { dataout[0] }	{ LOCATION = C15;  
// { dled[1] }	{ LOCATION = C16;  { dataout[1] }	{ LOCATION = C16;  
// { dled[2] }	{ LOCATION = B6;   { dataout[2] }	{ LOCATION = B6; 
// { dled[3] }	{ LOCATION = A5;   { dataout[3] }	{ LOCATION = A5;  
// { dled[4] }	{ LOCATION = B5;   { dataout[4] }	{ LOCATION = B5;  
// { dled[5] }	{ LOCATION = A8;   { dataout[5] }	{ LOCATION = A8; 
// { dled[6] }	{ LOCATION = A7;   { dataout[6] }	{ LOCATION = A7; 
// { dled[7] }	{ LOCATION = A6;  
// { dled[8] }	{ LOCATION = F16;  { en[7] }	{ LOCATION = F16; 
// { dled[9] }	{ LOCATION = E16;  { en[6] }	{ LOCATION = E16;
// { dled[10] }	{ LOCATION = E12;  { en[5] }	{ LOCATION = E12;                                   
// { dled[11] }	{ LOCATION = E10;  { en[4] }	{ LOCATION = E10;
// { dled[12] }	{ LOCATION = C13;  { en[3] }	{ LOCATION = C13;
// { dled[13] }	{ LOCATION = F10;  { en[2] }	{ LOCATION = F10; 
// { dled[14] }	{ LOCATION = E11;  { en[1] }	{ LOCATION = E11;
// { dled[15] }	{ LOCATION = D11;  { en[0] }	{ LOCATION = D11;  




endmodule
