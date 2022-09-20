module i2s_transceiver #(
    parameter  mclk_sclk_ratio = 4, //number of mclk periods per sclk period
              sclk_ws_ratio    = 64, //number of sclk periods per word select period
              d_width          = 24  //data width
) (
    reset_n,
    mclk,
    sclk,
    ws,
    sd_tx,
    sd_rx,
    l_data_tx,
    r_data_tx,
    l_data_rx,
    r_data_rx

);

input wire reset_n; //asynchronous active low reset
input wire mclk;  //master clock
output wire sclk; //serial clock (or bit clock)
output wire ws;  //word select (or left-right clock)
output reg sd_tx; //serial data transmit
input wire sd_rx; //serial data receive
input wire  [d_width-1:0] l_data_tx; //left channel data to transmit
input wire  [d_width-1:0] r_data_tx;  //right channel data to transmit
output reg  [d_width-1:0] l_data_rx; //left channel data received
output reg  [d_width-1:0] r_data_rx; //right channel data received


reg sclk_int ; //internal serial clock signal
reg ws_int ; //internal word select signal
reg [d_width-1:0] l_data_rx_int ; //internal left channel rx data buffer
reg [d_width-1:0] r_data_rx_int ; //internal right channel rx data buffer
reg [d_width-1:0] l_data_tx_int ;  //internal left channel tx data buffer
reg [d_width-1:0] r_data_tx_int ;  //internal right channel tx data buffer

integer  sclk_cnt = 0; //counter of master clocks during half period of serial clock
integer  ws_cnt = 0;  //counter of serial clock toggles during half period of word select



always @(posedge mclk , negedge reset_n ) begin
    
    if(!reset_n)
      begin
        sclk_cnt = 0;
        ws_cnt = 0;
        sclk_int <= 0;
        ws_int <= 0;
        l_data_rx_int <= 0;
        r_data_rx_int <= 0;
        l_data_tx_int <= 0;
        r_data_tx_int <= 0;
        sd_tx <= 0;
      end
    else
      begin
        if(sclk_cnt < mclk_sclk_ratio/2 -1)
          sclk_cnt = sclk_cnt +1;
        else
          begin
            sclk_cnt = 0;
            sclk_int <= ~ sclk_int;
            if( ws_cnt < sclk_ws_ratio -1)
              begin
                ws_cnt = ws_cnt +1;
                if( (sclk_int == 0) && (ws_cnt > 1) && (ws_cnt < d_width*2 +2) )
                  begin
                    if(ws_int == 1)
                      r_data_rx_int <= {r_data_rx_int[d_width-2 : 0],sd_rx} ;
                    else
                      l_data_rx_int <= {l_data_rx_int[d_width-2: 0] ,sd_rx} ;

                  end
                if(sclk_int == 1 && ws_cnt < (d_width*2 +3) )
                  begin
                    if(ws_int == 1)
                      begin
                        sd_tx <= r_data_tx_int[d_width-1];
                        r_data_tx_int <= {r_data_tx_int[d_width-2:0] , 1'b0};
                      end
                    else
                      begin
                        sd_tx <= l_data_tx_int[d_width-1];
                        l_data_tx_int <= {l_data_tx_int[d_width-2:0] , 1'b0};
                      end
                  end   
              end
            else
              begin
                ws_cnt = 0;
                ws_int <= ~ ws_int;
                r_data_tx_int <= r_data_tx;
                l_data_tx_int <= l_data_tx; 
                r_data_rx = r_data_rx_int;
                l_data_rx = l_data_rx_int; 
              end

          end

      end
    
end

assign sclk = sclk_int;
assign ws = ws_int;



    
endmodule