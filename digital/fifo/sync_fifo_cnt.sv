module fifo_counter #(
    parameter WIDTH=8, 
    parameter DEPTH=32    
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             wr_en,
    input  logic             rd_en,
    input  logic [WIDTH-1:0] wr_data,
    output logic [WIDTH-1:0] rd_data,
    output logic             full,
    output logic             empty
);
    parameter PTR_DEPTH = $clog2(DEPTH);
    logic [$clog2(DEPTH+1)-1:0] counter = 1'd0; // Need to be able to represent or count to 32, which means you need more than 5 bits.
    logic [WIDTH-1:0] mem [DEPTH-1:0];
    logic [PTR_DEPTH-1:0] wr_ptr, rd_ptr;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= {(PTR_DEPTH)}{1'b0};
            rd_ptr <= {(PTR_DEPTH)}{1'b0};
            counter <= 0;
        end
        else begin
            // The double commented out counter because counter must only change one per clk. 
            // If you try to assign it multiple time only the last one is use the earlier ones are discarded.
            if (!full && wr_en) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
                // counter <= counter +1'b1;
            end
            if (!empty && rd_en) begin
                rd_data <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
                // counter <= counter - 1'b1;;
            end
            counter <= counter + (wr_en && !full) - (rd_en && !empty);
        end
    end

    always_comb begin
        empty = (counter == 0);
        full = (counter == DEPTH);
    end

endmodule