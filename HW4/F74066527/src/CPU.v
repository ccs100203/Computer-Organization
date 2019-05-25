// Please include verilog file if you write module in other file

module CPU(
    input clk,
    input rst,
    output reg instr_read, // whether the instruction should be read in IM
    output reg [31:0] instr_addr, // the instruction address in IM
    input  [31:0] instr_out, //read instruction from instruction memory
    output reg data_read, //whether the data should be read in DM
    output reg data_write, //whether the data should be wrote in DM
    output reg [31:0] data_addr, // the data address in DM
    output reg [31:0] data_in, //the data which will be wrote into DM
    input  [31:0] data_out // the data send from DM
);

reg[31:0] arr[31:0];
reg[31:0] rs1, rs2, imm, PC;
reg[4:0] shamt;
reg[4:0] temp;
integer idx;
initial begin
    temp = 0;
    PC = 0;
    data_write = 0;
    data_read = 0;
    instr_addr = 0;
    for(idx=0; idx <32; idx = idx +1)begin
      arr[idx] = 0;
    end
end

always @(posedge clk) begin
    
    if(data_read == 1)begin
        arr[temp] = data_out;
    end
    
    instr_read = 1;
    data_write = 0;
    data_read = 0;
    
    if(rst == 1)begin
        PC = 0;
        instr_addr = 0;
        data_write = 0;
        data_read = 0;
        for(idx=0; idx <32; idx = idx +1)begin
            arr[idx] = 0;
        end
    end
    // $display("PC %h", instr_addr);
    // $display("ins %h", instr_out);
    
    // PC = PC + 4;
    rs1 = arr[instr_out[19:15]];
    rs2 = arr[instr_out[24:20]];
    // arr[0] = 0;
    // $display("%h", arr[5]);
    

    //R-type
    case ({instr_out[6:0], instr_out[31:25], instr_out[14:12]}) 
        17'b01100110000000000: arr[instr_out[11:7]] = $signed(rs1) + $signed(rs2); //add
        17'b01100110100000000: arr[instr_out[11:7]] = $signed(rs1) - $signed(rs2); //sub
        17'b01100110000000001: arr[instr_out[11:7]] = rs1 << rs2[4:0]; //sll
        17'b01100110000000010: arr[instr_out[11:7]] = ($signed(rs1) < $signed(rs2))? 1:0; //slt
        17'b01100110000000011: arr[instr_out[11:7]] = (rs1 < rs2)? 1:0; //sltu
        17'b01100110000000100: arr[instr_out[11:7]] = rs1 ^ rs2; //xor
        17'b01100110000000101: arr[instr_out[11:7]] = rs1 >> rs2[4:0]; //srl
        17'b01100110100000101: arr[instr_out[11:7]] = $signed(rs1) >>> rs2[4:0]; //sra
        17'b01100110000000110: arr[instr_out[11:7]] = rs1 | rs2; //or
        17'b01100110000000111: arr[instr_out[11:7]] = rs1 & rs2; //and
    endcase
    if(instr_out[6:0] ==7'b0110011) begin 
        PC = PC + 4;
        arr[0] = 0;
        // $display("%h", arr[5]);
        // $display("%b", instr_out);
    end

    //I-type
    imm = 0;
    imm[11:0] = instr_out[31:20];
    // if(imm[11] == 1) imm[31:12] = (2**20)-1;
    if(imm[11] == 1) imm[31:12] = 20'b11111111111111111111;
    shamt = instr_out[24:20];
    case ({instr_out[6:0], instr_out[14:12]})
        10'b0000011010: begin //lw
            arr[0] = 0;
            data_read=1;
            data_addr = $signed(rs1) + $signed(imm);
            // arr[instr_out[11:7]] = data_out;
            temp = instr_out[11:7];
            arr[0] = 0;
            // $display("PC %h", instr_addr);
            // $display("ins %h", instr_out);
            // $display("data_out %h", data_out);
            // $display("t0 %h", arr[5]);
            // $display("t1 %h", arr[6]);
            // $display("imm %h", imm);
            // $display("sp %h", arr[2]);
            // $display(" ");
        end
        10'b0010011000: arr[instr_out[11:7]] = $signed(rs1) + $signed(imm); //addi
        10'b0010011010: arr[instr_out[11:7]] = ($signed(rs1) < $signed(imm))? 1:0; //slti
        10'b0010011011: arr[instr_out[11:7]] = (rs1 < imm)? 1:0; //sltiu
        10'b0010011100: arr[instr_out[11:7]] = rs1 ^ imm; //xori
        10'b0010011110: arr[instr_out[11:7]] = rs1 | imm; //ori
        10'b0010011111: arr[instr_out[11:7]] = rs1 & imm; //andi
        10'b0010011001: arr[instr_out[11:7]] = rs1 << shamt; //slli
        10'b1100111000: begin //jalr
            arr[instr_out[11:7]] = PC+4;
            PC = imm + rs1;
            arr[0] = 0;
            // PC[0] = 0;
        end
        10'b0010011101: begin
            case (instr_out[31:25])
                7'b0000000: arr[instr_out[11:7]] = rs1 >> shamt; //srli
                7'b0100000: arr[instr_out[11:7]] = $signed(rs1) >>> shamt; //srai
            endcase
        end
    endcase
    if(instr_out[6:0] ==7'b0000011 ||instr_out[6:0] == 7'b0010011) begin 
        PC = PC + 4;
        arr[0] = 0;
        // $display("%h", arr[5]);
        // $display("%b", instr_out);
    end

    //S-type
    imm = 0;
    imm[11:5] = instr_out[31:25];
    imm[4:0] = instr_out[11:7];
    if(imm[11] == 1) imm[31:12] = 20'b11111111111111111111;
    case ({instr_out[6:0], instr_out[14:12]})
        10'b0100011010:begin
            data_write = 1;
            data_addr = $signed(rs1) + $signed(imm);
            data_in = rs2;
            PC = PC + 4;
        end
    endcase

    //B-type
    imm = 0;
    imm[12] = instr_out[31];
    imm[10:5] = instr_out[30:25];
    imm[4:1] = instr_out[11:8];
    imm[11] = instr_out[7];
    if(imm[12] == 1) imm[31:13] = 19'b1111111111111111111;
    case ({instr_out[6:0], instr_out[14:12]})
        10'b1100011000: PC = (rs1 == rs2)? $signed(PC) + $signed(imm) : PC+4; //beq
        10'b1100011001: PC = (rs1 != rs2)? $signed(PC) + $signed(imm) : PC+4; //bne
        10'b1100011100: PC = ($signed(rs1) < $signed(rs2))? $signed(PC) + $signed(imm) : PC+4; //blt
        10'b1100011101: PC = ($signed(rs1) >= $signed(rs2))? $signed(PC) + $signed(imm) : PC+4; //bge
        10'b1100011110: PC = (rs1 < rs2)? $signed(PC) + $signed(imm) : PC+4; //bltu
        10'b1100011111: PC = (rs1 >= rs2)? $signed(PC) + $signed(imm) : PC+4; //bgeu
    endcase

    //U-type
    imm = 0;
    imm[31:12] = instr_out[31:12];
    case (instr_out[6:0])
        7'b0010111: arr[instr_out[11:7]] = $signed(PC) + $signed(imm); //auipc
        7'b0110111: arr[instr_out[11:7]] = imm; //lui
    endcase
    if(instr_out[6:0] == 7'b0110111 || instr_out[6:0] == 7'b0010111)begin
        PC = PC + 4;
        arr[0] = 0;
    end

    //J-type
    imm = 0;
    imm[20] = instr_out[31];
    imm[10:1] = instr_out[30:21];
    imm[11] = instr_out[20];
    imm[19:12] = instr_out[19:12];
    if(imm[20] == 1) imm[31:21] = 11'b11111111111;
    case (instr_out[6:0])
        7'b1101111: begin //jal
            arr[instr_out[11:7]] = PC+4;
            PC = $signed(PC) + $signed(imm);
            // $display("imm  %b", imm);
            arr[0] = 0;
        end 
    endcase

    arr[0] = 0;
    instr_addr = PC;
    // if(instr_out == 8'h01d30333)begin
    //     $display("PC %h", PC);
    //     $display("ins %h", instr_out);
    //     $display("t0 %h", arr[5]);
    //     $display("t1 %h", arr[6]);
    //     $display("t2 %h", arr[7]);
    //     $display("t3 %h", arr[28]);
    //     $display("t4 %h", arr[29]);
    //     $display("t5 %h", arr[30]);
    //     $display("imm %h", imm);
    //     $display("WTF");
    // end
end


endmodule
