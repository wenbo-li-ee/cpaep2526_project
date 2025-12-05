//--------------------------
// Useful functions for testing
//--------------------------
function automatic void gemm_golden(
  // input  logic [AddrWidth-1:0] M,
  // input  logic [AddrWidth-1:0] K,
  // input  logic [AddrWidth-1:0] N,

  input  logic [AddrWidth-1:0] M_size_u,
  input  logic [AddrWidth-1:0] K_size_u,
  input  logic [AddrWidth-1:0] N_size_u,

  input  logic [AddrWidth-1:0] NumPE_M,
  input  logic [AddrWidth-1:0] NumIp_K,
  input  logic [AddrWidth-1:0] NumPE_N,

  input  logic signed [ InMemWidth-1:0] A_i [DataDepth],
  input  logic signed [ InMemWidth-1:0] B_i [DataDepth],
  output logic signed [OutMemWidth-1:0] Y_o [DataDepth]
);
  int unsigned M = M_size_u*NumPE_M;
  int unsigned K = K_size_u*NumIp_K;
  int unsigned N = N_size_u*NumPE_N;
  int unsigned m, n, k;
  int signed acc;
  logic signed [InDataWidth-1:0] element_A [DataDepth];
  logic signed [InDataWidth-1:0] element_B [DataDepth];
  logic signed [OutDataWidth-1:0] Y_o_temp [DataDepth];

  int unsigned address, a_row, a_col, b_row, b_col;

  for (address = 0; address < M_size_u*K_size_u; address++) begin
    for (a_row = 0; a_row < NumPE_M; a_row++) begin
      for (a_col = 0; a_col < NumIp_K; a_col++) begin
        element_A[address*NumPE_M*NumIp_K + a_row*NumIp_K + a_col] = A_i[address][(a_row*NumIp_K + a_col)*InDataWidth +: InDataWidth];
      end
    end
  end

  for (address = 0; address < K_size_u*N_size_u; address++) begin
    for (b_col = 0; b_col < NumPE_N; b_col++) begin
      for (b_row = 0; b_row < NumIp_K; b_row++) begin
        element_B[address*NumPE_N*NumIp_K + b_col*NumIp_K + b_row] = B_i[address][(b_col*NumIp_K + b_row)*InDataWidth +: InDataWidth];
      end
    end
  end

  for (m = 0; m < M; m++) begin
    for (n = 0; n<N; n++) begin
      acc = 0;
      for (k = 0; k < K; k++) begin
        acc += $signed(element_A[m*K + k]) * $signed(element_B[k*N + n]);
      end
      Y_o_temp[m*N + n] = acc;
    end
  end

  for (address = 0; address < M_size_u*N_size_u; address++) begin
    for (m = 0; m < NumPE_M; m++) begin
      for (n = 0; n < NumPE_N; n++) begin
        Y_o[address][(m*NumPE_N + n)*OutDataWidth +: OutDataWidth] = Y_o_temp[address*NumPE_M*NumPE_N + m*NumPE_N + n];
      end
    end
  end



endfunction