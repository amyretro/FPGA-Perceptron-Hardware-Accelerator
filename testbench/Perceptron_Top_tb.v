`timescale 1ns / 1ps

module Perceptron_Top_tb;

    parameter N_TB = 8;                         // عدد مدخلات النموذج
    parameter DATASET_SIZE_TB = 256;            // حجم عينات الداتا سيت لـ 10 مدخلات
    parameter WIDTH_TB = 32;                     // الحجم الإجمالي للكلمة (32 بت)
    parameter SHIFT_TB = 26;                     // عدد بتات الكسر
    
    reg start;
    reg clk;
    reg rst;

    wire error_flag;
    wire signed [WIDTH_TB-1:0] current_sum;       
    wire [$clog2(DATASET_SIZE_TB)-1:0] current_sample_idx;
    wire done;
    wire [15:0] epoch;
    wire signed [WIDTH_TB-1:0] out_b;            
    wire signed [(WIDTH_TB*N_TB)-1:0] out_w_flattened; // استقبال السلك الخارجي هنا

    // مصفوفة الأسلاك لغرض تفكي n وزان بشكل منفصل في الـ Waveform
    wire signed [WIDTH_TB-1:0] w [0:N_TB-1];

    genvar idx;
    generate
        for (idx = 0; idx < N_TB; idx = idx + 1) begin : weight_split
            assign w[idx] = out_w_flattened[idx * WIDTH_TB +: WIDTH_TB];
        end
    endgenerate

    Perceptron_Top #(
        .N(N_TB),
        .DATASET_SIZE(DATASET_SIZE_TB),          
        .WIDTH(WIDTH_TB),                        
        .SHIFT(SHIFT_TB)
    ) uut (
        .start(start),
        .clk(clk),
        .rst(rst),
        .error_flag(error_flag),
        .current_sum(current_sum),
        .current_sample_idx(current_sample_idx),
        .done(done),
        .epoch(epoch),
        .out_b(out_b),
        .out_w_flattened(out_w_flattened)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        rst = 1; // تفعيل الريست للتصفير الكامل في البداية
        start = 0;
        #100;
        rst = 0; // إلغاء الريست
        #100;
        start = 1; // نبضة البدء لتشغيل الـ CU
        #40;
        start = 0;
        $display("[SIMULATION START] Running Inputs Structural Perceptron Trainer...");

        fork : sim_monitor
            begin
                @(posedge done);
                $display("==========================================================");
                $display("[SUCCESS] Training Completed for n Inputs!");
                $display("Time of Convergence = %0t ns", $time);
                $display("Total Epochs taken  = %0d", epoch);
                $display("Final Bias (out_b)  = %0d", out_b);
                $display("==========================================================");
                #100;
                $finish;
            end
            begin
                #50000000; 
                $display("[TIMEOUT] Simulation stopped by safety guard.");
                $finish;
            end
        join
    end

    // شاشة المراقبة اللحظية داخل الـ Tcl Console لـ Vivado
    always @(current_sample_idx) begin
        if (!rst) begin
            $display("Time = %0t ns | Sample = %0d | Sum = %0d | Error = %b | Epoch = %0d", 
                     $time, current_sample_idx, current_sum, error_flag, epoch);
        end
    end

endmodule