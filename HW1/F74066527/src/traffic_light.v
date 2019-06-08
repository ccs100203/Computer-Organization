module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output reg R,
    output reg G,
    output reg Y
);

parameter [2:0] ST0 = 3'b000,ST1 = 3'b001, ST2 = 3'b010, ST3 = 3'b011, ST4 = 3'b100, ST5 = 3'b101, ST6 = 3'b110;
reg[2:0] nowST, nextST;
reg[10:0] count;
initial
begin
	nowST = ST0;
	nextST = ST0;
	count = 0;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
	begin
		nextST = ST0;
		count = 0;
	end
	if(pass && nowST != ST0)
	begin
		nextST = ST0;
		count = 0;
	end
	count = count + 11'd1;
	nowST = nextST;
end
/****************************************/
always@(count)
begin
	case (nowST)
	ST0:
	begin
	  if(count>=1024)
	  begin
	  	nextST = ST1;
		count = 0;
	  end
	  else
	  begin
	  	nextST = nowST;
		end
	end
	ST1:
	begin
	  if(count>=128)
	  begin
	  	nextST = ST2;
		count = 0;
	  end
	  else
	  begin
	  	nextST = nowST;
		end
	end
	ST2:
	begin
	  if(count>=128)
	  begin
	  	nextST = ST3;
		count = 0;
	  end
	  else
	  begin
	  	nextST = nowST;
		end
	end
	ST3:
	begin
	  if(count>=128)
	  begin
	  	nextST = ST4;
		count = 0;
	  end
	  else
	  begin
	  	nextST = nowST;
		end
	end
	ST4:
	begin
	  if(count>=128)
	  begin
	  	nextST = ST5;
		count = 0;
	  end
	  else
	  begin
	  	nextST = nowST;
		end
	end
	ST5:
	begin
	  if(count>=512)
	  begin
	  	nextST = ST6;
		count = 0;
	  end
	  else
	  begin
	  	nextST = nowST;
		end
	end
	ST6:
	begin
	  if(count>=1024)
	  begin
	  	nextST = ST0;
		count = 0;
	  end
	  else
	  begin
	  	nextST = nowST;
		end
	end
	  default: 
	  	nextST = nowST;
	endcase
end


always@(nowST)
begin
	if(nowST == ST0 || nowST == ST2 || nowST == ST4)//1G
	begin
		R = 1'b0;
		G = 1'b1;
		Y = 1'b0;
	end
	else if(nowST == ST1 || nowST == ST3)//2N
	begin
		R = 1'b0;
		G = 1'b0;
		Y = 1'b0;
	end
	else if(nowST == ST5)//6Y
	begin
		R = 1'b0;
		G = 1'b0;
		Y = 1'b1;
	end
	else if(nowST == ST6)//7R
	begin
		R = 1'b1;
		G = 1'b0;
		Y = 1'b0;
	end
	else
	begin
	  	R = 1'b0;
		G = 1'b1;
		Y = 1'b0;
	end
end

endmodule
