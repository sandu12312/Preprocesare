
module Preprocess(
    input wire clk,
    input wire en,           
    input wire rst,   
    input wire [31:0] pkg,     
    input wire [31:0] in,    
    output reg data_avail,
    output reg [511:0] data_out  
       
);


module Registru(
    input wire clk,       
    input wire rst,       
    input wire en,        
    input wire [31:0] in, 
    output reg [31:0] out 
);
    // Initializez output-ul cu zero
initial begin
    out <= 0;
end
  
always @(negedge rst) //Cand intrarea reset este 0, setam output-ul cu zero

begin
  
    out <= 0;
    
end

    
always @(posedge clk)  //Cand clk este 1, se modifica output-ul in dependenta de intrarile enable si reset
 begin
        
    if (rst && en) //Daca reset si enable sunt 1, setam output-ul cu valoare de intrare(in)
    begin
        out = in;
    end
end
endmodule


module Decodificator(
    input en,             
    input [3:0] in,       
    output [15:0] out     
);
    assign out[0] = ((in == 4'b0000) && en);
    assign out[1] = ((in == 4'b0001) && en);
    assign out[2] = ((in == 4'b0010) && en);
    assign out[3] = ((in == 4'b0011) && en);
    assign out[4] = ((in == 4'b0100) && en);
    assign out[5] = ((in == 4'b0101) && en);
    assign out[6] = ((in == 4'b0110) && en);
    assign out[7] = ((in == 4'b0111) && en);
    assign out[8] = ((in == 4'b1000) && en);
    assign out[9] = ((in == 4'b1001) && en);
    assign out[10] = ((in == 4'b1010) && en);
    assign out[11] = ((in == 4'b1011) && en);
    assign out[12] = ((in == 4'b1100) && en);
    assign out[13] = ((in == 4'b1101) && en);
    assign out[14] = ((in == 4'b1110) && en);
    assign out[15] = ((in == 4'b1111) && en);
    //Output-urile sunt setate pe 1 daca numarul in si en sunt setate pe 1
endmodule


reg [4:0] k;   //Variabila k tine cont de cate ori pachetul de intrari a fost scris
wire [15:0] resultat_decodificare;   
Decodificator decoder(en, k[3:0], resultat_decodificare);     //Initializez modulul decoder pentru a decoda valoarea lui k
    
    
genvar j; //generez 16 registri pentru a crea un fisier de registri
wire [31:0] reg_file[0:15];
generate
    for (j=0; j<16; j=j+1)
     begin
        Registru aux_reg(clk, rst, resultat_decodificare[j], pkg, reg_file[j]);
    end
endgenerate
    
    
initial begin 
  
    k <= 0;  
    data_out <= 0;
    data_avail <= 0;
    
end
    
  
always @(negedge rst) //Cand reset este 0, setez outputul si cobor flagul la 0 si variabila k la 0
begin
  
    data_out <= 0;
    k <= 0;
    data_avail <= 0;
    
    
end
    

always @(posedge clk)    //Cand clk este 1, modifc variabilile k si data_avail in dependenta de reset si enable
 begin
        
    if (rst && en)
     begin
        k = k + 1;
            
        if (data_avail) //daca este setat deja il resetam la 0
        begin
            data_avail = 0;
        end
    end
 end
    
always @(negedge clk)       
 begin       
    if (k == 16) 
    begin
            //Concatenam reg_file in data_out
  
        data_out[511:480]=reg_file[15];
        data_out[479:448]=reg_file[14];
        data_out[447:416]=reg_file[13];
        data_out[415:384]=reg_file[12];
        data_out[383:352]=reg_file[11];
        data_out[351:320]=reg_file[10];
        data_out[319:288]=reg_file[9];
        data_out[287:256]=reg_file[8];
        data_out[255:224]=reg_file[7];
        data_out[223:192]=reg_file[6];
        data_out[191:160]=reg_file[5];
        data_out[159:128]=reg_file[4];
        data_out[127:96]=reg_file[3];
        data_out[95:64]=reg_file[2];
        data_out[63:32]=reg_file[1];
        data_out[31:0]=reg_file[0];
        
            // Ridicam flagul la 1
        data_avail <= 1;
        k <= 0;
    end
end
endmodule



module Preprocess_tb;

	// Inputs
	reg clk;
	reg [31:0] pkg;
	reg rst;
	reg en;

	// Outputs
	wire [511:0] data_out_actual;
	wire data_avail_actual;
	reg [511:0] data_out_expected;
	reg data_avail_expected;
	integer i;
	integer nr_tests, tests_passed;
	
	/* Modify these variables to change display options */
	/* MONITOR: 
		1 == Call the monitor function to see what your module does
		0 == Do not call the monitor function
		
		DISPLAY_FAILED:
		1 == Display expected vs actual for FAILED testcases
		0 == Do not display expected vs actual
		
		DISPLAY_PASSED:
		1 == Display PASSED test cases
		0 == Do not display PASSED test cases
	*/
	integer MONITOR = 1, DISPLAY_FAILED = 1, DISPLAY_PASSED = 0;
	// Instantiate the Unit Under Test (UUT)
	Preprocess uut (
		.clk(clk), 
		.pkg(pkg), 
		.rst(rst), 
		.en(en), 
		.data_out(data_out_actual), 
		.data_avail(data_avail_actual)
	);
	
	initial begin
		if(MONITOR) $monitor("Test %d: clk <= %b, pkg <= %x, rst <= %b, en <= %b, data_out <= %X, data_avail <= %b", nr_tests, clk, pkg, rst, en, data_out_actual, data_avail_actual);
		nr_tests = 0;
		tests_passed = 0;
	end
	initial begin
		// Initialize Inputs
		clk <= 0;
		pkg <= 0;
		rst <= 1;
		en <= 1;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1;
		pkg <= 32'h000004E8;
		clk <= 1;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1;
		clk <= 0;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1;
		en <= 1'b0;
		clk <= 1'b1;
		pkg <= 32'h000004E7;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1;
		clk <= 0;
		en <= 1;
		pkg <= 32'h000004E6;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1;
		en <= 0;
		clk <= 1;
		pkg <= 32'h000004E2;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1; 
		en <= 0;
		clk <= 1;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1;
		clk<=1;
		en <= 1;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1; 
		clk <= 1;
		en <= 1;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1; 
		rst <= 0;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1; 
		rst <= 1;
		data_out_expected <= 0;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		for(i=0; i < 33; i = i + 1) begin
			#1;
			clk <= ~clk;
			pkg <= pkg + 1'b1;
			data_out_expected <= 0;
			data_avail_expected <= 0;
			nr_tests <= nr_tests + 1;
		end
		#1;
		clk <= 0;
		pkg <= pkg + 1'b1;
		data_out_expected <= 512'h0000050200000500000004fe000004fc000004fa000004f8000004f6000004f4000004f2000004f0000004ee000004ec000004ea000004e8000004e6000004e4;
		data_avail_expected <= 1;
		nr_tests <= nr_tests + 1;
		
		#1;
		clk <= 1;
		pkg <= pkg + 1'b1;
		data_out_expected <= 512'h0000050200000500000004fe000004fc000004fa000004f8000004f6000004f4000004f2000004f0000004ee000004ec000004ea000004e8000004e6000004e4;
		data_avail_expected <= 1;
		nr_tests <= nr_tests + 1;
		
		#1; 
		clk <= 0;
		
		#1;
		clk <= 1'b1;
		en <= 1'b1;
		data_out_expected <= 512'h0000050200000500000004fe000004fc000004fa000004f8000004f6000004f4000004f2000004f0000004ee000004ec000004ea000004e8000004e6000004e4;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		#1;
		rst <= 0;
		data_out_expected <= 512'h0000050200000500000004fe000004fc000004fa000004f8000004f6000004f4000004f2000004f0000004ee000004ec000004ea000004e8000004e6000004e4;
		data_avail_expected <= 0;
		nr_tests <= nr_tests + 1;
		
		#1;
		$display("Tests Passed/Total Tests: %0d/%0d", tests_passed, nr_tests);
	end

	always @(nr_tests) begin
		if(nr_tests != 0) begin
			if(data_out_actual === data_out_expected && data_avail_actual === data_avail_expected) begin
				tests_passed = tests_passed + 1;
				if(DISPLAY_PASSED) $display("[DISPLAY PASSED] Test %d: data_out_expected = %X [PASSED], data_out_avail_expected = %b [PASSED]", nr_tests, data_out_expected, data_avail_expected);
			end
			else if(DISPLAY_FAILED) 
				$display("[DISPLAY FAILED] Test %d: data_out_expected = %X, data_out_actual = %X [%s], data_avail_expected = %X, data_avail_actual = %X [%s]", 
							nr_tests, data_out_expected, data_out_actual, data_out_actual === data_out_expected ? "PASSED": "FAILED", data_avail_expected, data_avail_actual, data_avail_actual === data_avail_expected ? "PASSED": "FAILED");
		end
	end   
endmodule

