module ram0(
    // Read port
    input rdclk,
    input [8:0] rdaddr,
    output reg [63:0] do);

    (* ram_style = "block" *) reg [63:0] ram[0:511];


    genvar i;
    generate
        for (i=0; i<512; i=i+1)
        begin
            initial begin
                ram[i] <= i | i << 16 | i << 32 | i << 48;
            end
        end
    endgenerate

    always @ (posedge rdclk) begin
        do <= ram[rdaddr];
    end

endmodule

module top (
    input clk,
    input rx,
    output tx,
    input [15:0] sw,
    output [15:0] led
);
    reg nrst = 0;
    wire tx_baud_edge;
    wire rx_baud_edge;

    // Data in.
    wire [7:0] rx_data_wire;
    wire rx_data_ready_wire;

    // Data out.
    wire tx_data_ready;
    wire tx_data_accepted;
    wire [7:0] tx_data;

    assign led[14:0] = sw[14:0];
    assign led[15] = rx_data_ready_wire ^ sw[15];

    UART #(
        .COUNTER(25),
        .OVERSAMPLE(8)
    ) uart (
        .clk(clk),
        .rst(!nrst),
        .rx(rx),
        .tx(tx),
        .tx_data_ready(tx_data_ready),
        .tx_data(tx_data),
        .tx_data_accepted(tx_data_accepted),
        .rx_data(rx_data_wire),
        .rx_data_ready(rx_data_ready_wire)
    );

    wire [8:0] read_address;
    wire [63:0] read_data;

    wire [8:0] rom_read_address;
    reg [63:0] rom_read_data;

    always @(posedge clk) rom_read_data <= {4{7'd0, rom_read_address}};

    wire loop_complete;
    wire error_detected;
    wire [7:0] error_state;
    wire [8:0] error_address;
    wire [63:0] expected_data;
    wire [63:0] actual_data;

    ROM_TEST #(
        .ADDR_WIDTH(9),
        .DATA_WIDTH(64),
        .ADDRESS_STEP(1),
        .MAX_ADDRESS(511)
    ) dram_test (
        .rst(!nrst),
        .clk(clk),
        // Memory connection
        .read_data(read_data),
        .read_address(read_address),
        // INIT ROM connection
        .rom_read_data(rom_read_data),
        .rom_read_address(rom_read_address),
        // Reporting
        .loop_complete(loop_complete),
        .error(error_detected),
        .error_state(error_state),
        .error_address(error_address),
        .expected_data(expected_data),
        .actual_data(actual_data)
    );

    ram0 #(
    ) bram (
        // Read port
        .rdclk(clk),
        .rdaddr(read_address),
        .do(read_data)
    );

    ERROR_OUTPUT_LOGIC #(
        .DATA_WIDTH(64),
        .ADDR_WIDTH(9)
    ) output_logic (
        .clk(clk),
        .rst(!nrst),
        .loop_complete(loop_complete),
        .error_detected(error_detected),
        .error_state(error_state),
        .error_address(error_address),
        .expected_data(expected_data),
        .actual_data(actual_data),
        .tx_data(tx_data),
        .tx_data_ready(tx_data_ready),
        .tx_data_accepted(tx_data_accepted)
    );

    always @(posedge clk) begin
        nrst <= 1;
    end
endmodule
