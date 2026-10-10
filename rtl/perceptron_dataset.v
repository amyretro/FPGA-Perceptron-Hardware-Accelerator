UPDATE_B: begin
                    if (prediction != T[sample_idx]) 
                    begin
                        any_error_in_epoch <= 1;
                        if (T[sample_idx]) b <= b + RL;
                        else               b <= b - RL;
                        
                        i_counter <= 0;
                        state <= UPDATE_W; // ننتقل لتحديث الأوزان واحداً تلو الآخر
                    end else begin
                        state <= NEXT_SAMPLE;
                    end
                end

                UPDATE_W: begin
                    if (i_counter < N) begin
                        if (X[sample_idx][i_counter]) begin
                            if (T[sample_idx]) w[i_counter] <= w[i_counter] + RL;
                            else               w[i_counter] <= w[i_counter] - RL;
                        end
                        i_counter <= i_counter + 1;
                    end else begin
                        state <= NEXT_SAMPLE;
                    end
                end

            NEXT_SAMPLE: begin
                    if (sample_idx < DATASET-1) begin
                        // الانتقال للعينة التالية داخل نفس الإيبوك
                        sample_idx <= sample_idx + 1;
                        i_counter <= 0;
                        sum <= b;
                        state <= SUMMATION;
                    end else begin
                        // نهاية الإيبوك: التحقق هل حدث أي خطأ خلال الـ 64 عينة كاملة؟
                        if (any_error_in_epoch) begin
                            // إذا وجد ولو خطأ واحد، ابدأ إيبوك جديد
                            state <= INIT_EPOCH;
                        end else begin
                            // إذا مر الإيبوك بالكامل (كل العينات صحيحة) توقف فوراً
                            is_converged <= 1;
                            i_counter <= 0;
                            state<=DONE_ST;
                          
                        end
                    end
                end

             
                    // تفريغ الأوزان في المخرج المسطح تدريجياً لمنع مشاكل التوقيت
                  
                DONE_ST: begin
                  if (i_counter < N) begin
                                      out_w_flattened[i_counter*32 +: 32] <= w[i_counter];
                                      i_counter <= i_counter + 1;
                                  end
                                  if(i_counter==N)
                                   begin
                                      out_b <= b;
                                       done <= 1;
                                      
                                  end
                
                   
                    if (!start) state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule