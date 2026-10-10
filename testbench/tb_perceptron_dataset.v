`timescale 1ns / 1ps

module tb_perceptron_dataset;
    //  الإشارات (Inputs as reg, Outputs as wire) 
    parameter N_TB =8;
    reg clk;
    reg rst;
    reg start;
    reg [2:0] gate_flag;
   //  parameter N = 10;
  //  reg  state;
     wire done;
    // أسلاك لاستقبال الأوزان والانحياز من الموديول
     wire signed [(32*N_TB)-1:0] out_w_flattened;
     wire signed [31:0] out_b;
     wire [15:0]epoch;
     wire [3:0] state;
    // --- 3. ربط الموديول (Unit Under Test) ---
 perceptron_dataset #(
            .N(N_TB)
        ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
         .gate_flag(gate_flag),
        .done(done),
        // ربط المخارج الجديدة
       .out_w_flattened(out_w_flattened),
       .out_b(out_b),
       .epoch(epoch),
       .state(state)
    );

    // --- 4. توليد نبضات الساعة (Clock Generation) ---
   
   // تردد 100 ميجاهرتز (كل 10 نانو ثانية دورة كاملة)
     initial begin
     forever #5 clk=~clk; 
   end
    // --- 5. منطق الاختبار الرئيسي ---
    initial begin
        // أ. التهيئة الأولية
        clk = 0;
        rst = 0;   // تفعيل الريست في البداية
        start = 0;
        

        // ب. نبضة الريست (Reset)
        #10;
        rst = 1;   // إيقاف الريست
        #20;
     
 
                  
        start = 1;
        gate_flag = 3'd3;

        #10;

           wait(done==1); 
       @(posedge clk);
           $finish;

    end
endmodule