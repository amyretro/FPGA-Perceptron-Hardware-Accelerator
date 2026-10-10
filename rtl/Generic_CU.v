[30/09/2026 6:27 pm] Souad Alkalili: `timescale 1ns / 1ps
module Generic_CU #(
    parameter DATASET_SIZE =256,
    parameter N = 8
)(
    input wire clk,
    input wire start,
    input wire rst,
    input wire error_flag,
    output reg [7:0] CV,
    output reg [$clog2(DATASET_SIZE)-1:0] sample_idx, 
    output reg [$clog2(N)-1:0] bit_counter,
    output reg done,
    output reg [15:0] epoch 
);

    reg epoch_error;
    reg error_stable; // إشارة مستقرة للخطأ

    // الحالات المعدلة لتشمل الانتظار
    localparam IDLE       = 4'd0,
               FETCH      = 4'd1,
               LOAD       = 4'd2,
               SETUP      = 4'd3,  
               SUM        = 4'd4,  
               SHIFT      = 4'd5,  
               WAIT_SUM   = 4'd6, // حالة انتظار لاستقرار المجموع النهائي
               CHECK      = 4'd7,  
               UPDATE     = 4'd8,  
               NEXT       = 4'd9;

    reg [3:0] state, next;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next;
    end

    // منطق الانتقالات (Next State Logic)
    always @(*) begin
        case(state)
            IDLE: next = (start && !done) ? FETCH : IDLE;
            FETCH:    next = LOAD;
            LOAD:     next = SETUP;
            SETUP:    next = SUM;
            SUM:      next = SHIFT;
            SHIFT:    next = (bit_counter == N-1) ? WAIT_SUM : SUM; 
            WAIT_SUM: next = CHECK; // دورة لضمان أن الـ sum_reg استقر تماماً
            CHECK:    next = (error_flag) ? UPDATE : NEXT;
            UPDATE:   next = NEXT; 
           NEXT: if (sample_idx == DATASET_SIZE-1)
                      next = (epoch_error || error_flag) ? FETCH : IDLE;
                  else
                      next = FETCH;
            default:  next = IDLE;
        endcase
    end

    // التحكم في الإشارات (Output Logic)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            CV <= 8'b0000_0000; sample_idx <= 0; bit_counter <= 0;
            epoch_error <= 0; error_stable <= 0; done <= 0; epoch <= 0;
        end else begin
            case(state)
              IDLE: begin 
                CV <= 8'b0000_0000; // إلغاء إشارة التصفير التلقائي أثناء الانتظار
                bit_counter <= 0; 
                end
                
                FETCH: begin 
                    CV <= 8'b1000_0000; // enabl_lut
                    bit_counter <= 0;
                end

                LOAD: begin
                    CV <= 8'b0100_0001; // enable_sample + reset_sum
                end

                SETUP: begin
                    CV <= 8'b0000_0010; // load_bias_to_sum
                end

                SUM: begin
                    CV <= 8'b0001_1000; // enable_sum + select_x
                end

                SHIFT: begin
                    CV <= 8'b0010_0000; // enabl_shift
                    bit_counter <= bit_counter + 1;
                end

                WAIT_SUM: begin
                    CV <= 0; // توقف تام للسماح للـ Comparator بالاستقرار
                end

                CHECK: begin
                    error_stable <= error_flag; // قنص قيمة الخطأ الحقيقية
                    if (error_flag) epoch_error <= 1;
                end

                UPDATE: begin
                    CV <= 8'b0000_0100; // نبضة التحديث (select_bw)
                end
     NEXT: begin
                                    CV <= 8'b0000_0000; 
                                    
                                    if (sample_idx == DATASET_SIZE - 1) begin
                                       
                                        if (!epoch_error && !error_flag) begin
                                            done <= 1;  
                                        end else begin 
                                            sample_idx  <= 0; 
                                            epoch_error <= 0; 
                                            epoch       <= epoch + 1; 
                                        end
                                    end else begin
                                        sample_idx <=
[30/09/2026 6:27 pm] Souad Alkalili: sample_idx + 1; 
                                    end
                                end 
            endcase
        end
    end
endmodule