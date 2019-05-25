module fpadder (
    input  [31:0] src1,
    input  [31:0] src2,
    output reg [31:0] out
);

    reg sign1;
    reg sign2;
    reg [7:0]exp1;
    reg [7:0]exp2;
    reg [47:0]frac1;
    reg [47:0]frac2;
    reg signAns;
    reg [7:0]expAns;
    reg [47:0]fracAns;

    reg [1:0]isBig;
    reg [7:0]expSub;
    reg zero;
    reg expDoubleZero;

    integer i;

    always @ (src1)
    begin
        frac1 = 0;
        frac2 = 0;
        fracAns = 0;
        zero = 0;
        sign1 = src1[31];
        exp1[7:0] = src1[30:23];
        frac1[45:23] = src1[22:0];
        expDoubleZero = 0;


        sign2 = src2[31];
        exp2[7:0] = src2[30:23];
        frac2[45:23] = src2[22:0];
        if(exp1 != 0)
            frac1[46] = 1;
        if(exp2 != 0)
            frac2[46] = 1;
        if(exp1==0 && exp2==0)
            expDoubleZero = 1;

        if(exp1 > exp2)
        begin
            isBig = 2'b01;
        end
        else if(exp1 < exp2)
        begin
            isBig = 2'b00;
        end
        else
        begin
            isBig = 2'b10;
        end

        case(isBig) //1: exp1 > exp2
            2'b00:begin //2 > 1
                expSub = exp2 - exp1;
                if(exp1==0)
                    expSub=expSub-1;
                frac1 = frac1 >> expSub;
                exp1 = exp2;
            end 
            2'b01:begin //1 > 2
                expSub = exp1 - exp2;
                if(exp2==0)
                    expSub=expSub-1;
                frac2 = frac2 >> expSub;
                exp2 = exp1;
            end 
            2'b10: begin
                expSub = 0;
            end 
            default: 
                expSub = 0;
        endcase

        if(sign1 == sign2) begin
            signAns = sign1;
            fracAns = frac1 + frac2;
            expAns = exp1;
        end
        else begin
            if(frac1 > frac2)begin
                expAns = exp1;
                signAns = sign1;
                fracAns = frac1 - frac2;
            end else if(frac2 > frac1) begin
                expAns = exp2;
                signAns = sign2;
                fracAns = frac2 - frac1;
            end else begin
                expAns = exp1;
                // if(expAns == 0)
                    zero = 1;
                fracAns = 0;
                signAns = 0;
            end
        end

        if(expDoubleZero == 1 && fracAns[46] == 1) begin //兩個EXP都是0的overflow
            out[31] = signAns;
            out[30:23] = expAns+1;
            out[22:0] = fracAns[45:23];
            if(fracAns[22] == 1) begin      
                // out = out + 1;
                if(fracAns[23] == 1 || fracAns[21:0] != 0)begin
                    out = out + 1;
                end
            end
        end else if(fracAns[47] == 1)begin //其餘的overflow
            out[31] = signAns;
            out[30:23] = expAns+1;
            out[22:0] = fracAns[46:24];
            if(fracAns[23] == 1)begin      
                if(fracAns[24] == 1 || fracAns[22:0] != 0)begin
                    out = out + 1;
                end
            end
        end else begin
            for ( i=0;  i<46; i=i+1) begin
                if (fracAns[46] != 1) begin
                    fracAns = fracAns << 1;
                    expAns = expAns - 1;
                end
            end
            

            out[31] = signAns;
            out[30:23] = expAns;
            out[22:0] = fracAns[45:23];
            if(fracAns[22] == 1) begin
                if(fracAns[23] == 1 || fracAns[21:0] != 0)begin
                    out = out + 1;
                end
            end

            
        end
        if(out[30:23] == 8'b11111111)begin
            out[22:0] = 0;
        end

        if(zero == 1) begin
            out = 0;
        end
          
    end	
endmodule
