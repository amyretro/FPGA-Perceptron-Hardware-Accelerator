`timescale 1ns / 1ps

module Generic_LUT #(
    parameter N = 8,                            
    parameter DATASET_SIZE = 256                 
)(
    input wire clk,
    input wire rst,
    input wire enabl_lut,
    input wire [$clog2(DATASET_SIZE)-1:0] sample_index, 
    output reg [N-1:0] vector_x,                        
    output reg target
);
    
     reg [N:0] memory [0:DATASET_SIZE-1];
    initial begin
        $readmemb("C:/Users/HululIT/Downloads/SoftwareCode/dataset.txt", memory);
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            vector_x <= 0;
            target   <= 1'b0;
        end else if (enabl_lut) begin
            // البت الأقصى يساراً [4:1] هي المدخلات الأربعة، والبت الأخير [0] هو الـ target
            vector_x <= memory[sample_index][N:1];
            target   <= memory[sample_index][0];
        end
    end

endmodule`timescale 1ns / 1ps

module Generic_LUT #(
    parameter N = 8,                            
    parameter DATASET_SIZE = 256                 
)(
    input wire clk,
    input wire rst,
    input wire enabl_lut,
    input wire [$clog2(DATASET_SIZE)-1:0] sample_index, 
    output reg [N-1:0] vector_x,                        
    output reg target
);
    
     reg [N:0] memory [0:DATASET_SIZE-1];
    initial begin
        $readmemb("C:/Users/HululIT/Downloads/SoftwareCode/dataset.txt", memory);
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            vector_x <= 0;
            target   <= 1'b0;
        end else if (enabl_lut) begin
            // البت الأقصى يساراً [4:1] هي المدخلات الأربعة، والبت الأخير [0] هو الـ target
            vector_x <= memory[sample_index][N:1];
            target   <= memory[sample_index][0];
        end
    end

endmodule