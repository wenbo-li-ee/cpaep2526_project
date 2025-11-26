//-----------------------------
// Multi-Port Memory Module
// 
// Description:
// This module implements a multi-port memory with parameterizable
// data width, number of ports, and memory depth. It supports simultaneous
// read and write operations across multiple ports.
//
// Parameters:
// - DataWidth : Width of each data word.
// - DataDepth : Depth of the memory (number of addressable locations).
// - AddrWidth : Width of the address bus, calculated based on DataDepth.
//
// Ports:
// - clk_i        : Clock input.
// - rst_ni       : Active-low reset input.
// - mem_addr_i   : Array of address inputs for each port.
// - mem_we_i     : Array of write enable signals for each port.
// - mem_wr_data_i: Array of data inputs for write operations.
// - mem_rd_data_o: Array of data outputs for read operations.
//-----------------------------

module single_port_memory #(
    parameter int unsigned DataWidth = 8,
    parameter int unsigned DataDepth = 4096,
    parameter int unsigned AddrWidth = (DataDepth <= 1) ? 1 : $clog2(DataDepth)

) (
    input  logic                        clk_i,
    input  logic                        rst_ni,
    input  logic        [AddrWidth-1:0] mem_addr_i,
    input  logic                        mem_we_i,
    input  logic signed [DataWidth-1:0] mem_wr_data_i,
    output logic signed [DataWidth-1:0] mem_rd_data_o
);

  // Memory array
  logic signed [DataWidth-1:0] memory[DataDepth];

  // Memory read access
  always_comb begin
    mem_rd_data_o = memory[mem_addr_i];
  end

  // Memory write access
  always_ff @(posedge clk_i) begin
    // Write when write enable is asserted
    if (mem_we_i) begin
      memory[mem_addr_i] <= mem_wr_data_i;
    end
  end
endmodule
