module i2s_axis_controler #(
    parameter D_WIDTH = 24
) (
    aresetn,
    aclk,
    ws,
    // left channel recived data from audio codec (master)
    l_data_recv_codec,
    m_axis_l_data_recv_codec,
    m_axis_l_ready_recv_codec,
    m_axis_l_valid_recv_codec,
    // right channel recived data from audio codec (master)
    r_data_recv_codec,
    m_axis_r_data_recv_codec,
    m_axis_r_ready_recv_codec,
    m_axis_r_valid_recv_codec,
    //left chnnel data to send to audio codec (slave)
    l_data_tr_to_codec,
    s_axis_l_data_tr_to_codec,
    s_axis_l_ready_tr_to_codec,
    s_axis_l_valid_tr_to_codec,
    //right chnnel data to send to audio codec (slave)
    r_data_tr_to_codec,
    s_axis_r_data_tr_to_codec,
    s_axis_r_ready_tr_to_codec,
    s_axis_r_valid_tr_to_codec

);

input wire aresetn;
input wire aclk;
input wire ws;

input wire[D_WIDTH - 1 : 0 ]    l_data_recv_codec;
output wire [D_WIDTH - 1 : 0]    m_axis_l_data_recv_codec;
input  wire                     m_axis_l_ready_recv_codec;
output reg                      m_axis_l_valid_recv_codec;

input wire  [D_WIDTH - 1 : 0 ]    r_data_recv_codec;
output wire [D_WIDTH - 1 : 0]    m_axis_r_data_recv_codec;
input  wire                     m_axis_r_ready_recv_codec;
output reg                      m_axis_r_valid_recv_codec;


output reg [D_WIDTH - 1 : 0]    l_data_tr_to_codec;
input  wire[D_WIDTH - 1 : 0]    s_axis_l_data_tr_to_codec;
output reg                      s_axis_l_ready_tr_to_codec;
input  wire                     s_axis_l_valid_tr_to_codec;

output reg [D_WIDTH - 1 : 0]    r_data_tr_to_codec;
input  [D_WIDTH - 1 : 0]        s_axis_r_data_tr_to_codec;
output reg                      s_axis_r_ready_tr_to_codec;
input  wire                     s_axis_r_valid_tr_to_codec;

// FSM moore - receive data from codec and further
localparam  FSM_IDLE =            4'b0001,
            FSM_DATA_VALID =      4'b0010,
            FSM_CHECK_FOR_READY = 4'b0100,
            FSM_WAIT_TOGGLE_WS  = 4'b1000;


//left channel recived from audio codec fsm 
reg [3:0] fsm_current_state_l_recv_codec , fsm_next_state_l_recv_codec;


always @(posedge aclk , negedge aresetn ) begin
    if (!aresetn) begin
        fsm_current_state_l_recv_codec <= FSM_IDLE;
    end else begin
        fsm_current_state_l_recv_codec <= fsm_next_state_l_recv_codec;          
        end

end

always @*
  begin
    case (fsm_current_state_l_recv_codec) 
        FSM_IDLE: 
          begin
            if(ws)
              fsm_next_state_l_recv_codec = FSM_DATA_VALID;
            else
              fsm_next_state_l_recv_codec = FSM_IDLE;
          end
        FSM_DATA_VALID:
          begin
            if(m_axis_l_ready_recv_codec)
              fsm_next_state_l_recv_codec = FSM_WAIT_TOGGLE_WS;
            else
              fsm_next_state_l_recv_codec = FSM_CHECK_FOR_READY;
          end
        FSM_CHECK_FOR_READY:
          begin
            if(m_axis_l_ready_recv_codec)
              fsm_next_state_l_recv_codec = FSM_WAIT_TOGGLE_WS;
            else
              fsm_next_state_l_recv_codec = FSM_CHECK_FOR_READY;
          end

        FSM_WAIT_TOGGLE_WS:
          begin
            if(ws)
              fsm_next_state_l_recv_codec = FSM_WAIT_TOGGLE_WS;
            else
              fsm_next_state_l_recv_codec = FSM_IDLE;
          end
        default: 
          fsm_next_state_l_recv_codec = FSM_IDLE;
    endcase
  end

  always@*
    begin
      case (fsm_current_state_l_recv_codec)
        FSM_IDLE:              m_axis_l_valid_recv_codec = 1'b0;
        FSM_DATA_VALID:        m_axis_l_valid_recv_codec = 1'b1;
        FSM_CHECK_FOR_READY:   m_axis_l_valid_recv_codec = 1'b1;
        FSM_WAIT_TOGGLE_WS:    m_axis_l_valid_recv_codec = 1'b0;
        default :              m_axis_l_valid_recv_codec = 1'b0;
      endcase
    end

assign m_axis_l_data_recv_codec = l_data_recv_codec; //because input change only if ws edge

//right channel recived from audio codec fsm 
reg [3:0] fsm_current_state_r_recv_codec , fsm_next_state_r_recv_codec;


always @(posedge aclk , negedge aresetn ) begin
    if (!aresetn) begin
        fsm_current_state_r_recv_codec <= FSM_IDLE;
    end else begin
        fsm_current_state_r_recv_codec <= fsm_next_state_r_recv_codec;          
        end

end

always @*
  begin
    case (fsm_current_state_r_recv_codec) 
        FSM_IDLE: 
          begin
            if(!ws)
              fsm_next_state_r_recv_codec = FSM_DATA_VALID;
            else
              fsm_next_state_r_recv_codec = FSM_IDLE;
          end
        FSM_DATA_VALID:
          begin
            if(m_axis_r_ready_recv_codec)
              fsm_next_state_r_recv_codec = FSM_WAIT_TOGGLE_WS;
            else
              fsm_next_state_r_recv_codec = FSM_CHECK_FOR_READY;
          end
        FSM_CHECK_FOR_READY:
          begin
            if(m_axis_r_ready_recv_codec)
              fsm_next_state_r_recv_codec = FSM_WAIT_TOGGLE_WS;
            else
              fsm_next_state_r_recv_codec = FSM_CHECK_FOR_READY;
          end

        FSM_WAIT_TOGGLE_WS:
          begin
            if(!ws)
              fsm_next_state_r_recv_codec = FSM_WAIT_TOGGLE_WS;
            else
              fsm_next_state_r_recv_codec = FSM_IDLE;
          end
        default: 
          fsm_next_state_r_recv_codec = FSM_IDLE;
    endcase
  end

  always@*
    begin
      case (fsm_current_state_r_recv_codec)
        FSM_IDLE:              m_axis_r_valid_recv_codec = 1'b0;
        FSM_DATA_VALID:        m_axis_r_valid_recv_codec = 1'b1;
        FSM_CHECK_FOR_READY:   m_axis_r_valid_recv_codec = 1'b1;
        FSM_WAIT_TOGGLE_WS:    m_axis_r_valid_recv_codec = 1'b0;
        default :              m_axis_r_valid_recv_codec = 1'b0;
      endcase
    end

assign m_axis_r_data_recv_codec = r_data_recv_codec; //because input change only if ws edge

//end of receiving data from codec and send further part


//FSM moore - transmit data from pipline to codec

localparam  FSM_TR_IDLE =             3'b001,
            FSM_TR_SET_READY  =       3'b010,
            FSM_TR_WAIT_FOR_TRIGGER = 3'b100;



//left channel transmit sample to audio codec fsm 
reg [2:0] fsm_current_state_l_tr_codec , fsm_next_state_l_tr_codec;

always @(posedge aclk , negedge aresetn ) begin
    if (!aresetn) begin
        fsm_current_state_l_tr_codec <= FSM_TR_IDLE;
    end else begin
        fsm_current_state_l_tr_codec <= fsm_next_state_l_tr_codec;          
        end

end

always @*
  begin
    case (fsm_current_state_l_tr_codec) 
        FSM_TR_IDLE: 
          begin
            if(ws)
              fsm_next_state_l_tr_codec = FSM_TR_SET_READY;
            else
              fsm_next_state_l_tr_codec = FSM_TR_IDLE;
          end
        FSM_TR_SET_READY:
          begin
            if(s_axis_l_valid_tr_to_codec)
              fsm_next_state_l_tr_codec = FSM_TR_WAIT_FOR_TRIGGER;
            else
              fsm_next_state_l_tr_codec = FSM_TR_SET_READY;
          end
        FSM_TR_WAIT_FOR_TRIGGER:
          begin
            if(ws)
              fsm_next_state_l_tr_codec = FSM_TR_WAIT_FOR_TRIGGER;
            else
              fsm_next_state_l_tr_codec = FSM_TR_IDLE;
          end

       
        default: 
          fsm_next_state_l_tr_codec = FSM_TR_IDLE;
    endcase
  end

always@*
  begin
    case (fsm_current_state_l_tr_codec)
      FSM_TR_IDLE:              s_axis_l_ready_tr_to_codec = 1'b0;
      FSM_TR_SET_READY:        s_axis_l_ready_tr_to_codec = 1'b1;
      FSM_TR_WAIT_FOR_TRIGGER:   s_axis_l_ready_tr_to_codec = 1'b0;
      default :              s_axis_l_ready_tr_to_codec = 1'b0;
    endcase
  end

//handshaking occur
always @(posedge aclk , negedge aresetn) begin
  if (!aresetn) begin
        l_data_tr_to_codec <= {D_WIDTH{1'b0}}; //if reset set output to 0
    end 
  else if(s_axis_l_ready_tr_to_codec && s_axis_l_valid_tr_to_codec) begin
        l_data_tr_to_codec <= s_axis_l_data_tr_to_codec;          
   end
  else begin
       // latch data
    end
end


//right channel transmit sample to audio codec fsm 
reg [2:0] fsm_current_state_r_tr_codec , fsm_next_state_r_tr_codec;

always @(posedge aclk , negedge aresetn ) begin
    if (!aresetn) begin
        fsm_current_state_r_tr_codec <= FSM_TR_IDLE;
    end else begin
        fsm_current_state_r_tr_codec <= fsm_next_state_r_tr_codec;          
        end

end

always @*
  begin
    case (fsm_current_state_r_tr_codec) 
        FSM_TR_IDLE: 
          begin
            if(!ws)
              fsm_next_state_r_tr_codec = FSM_TR_SET_READY;
            else
              fsm_next_state_r_tr_codec = FSM_TR_IDLE;
          end
        FSM_TR_SET_READY:
          begin
            if(s_axis_r_valid_tr_to_codec)
              fsm_next_state_r_tr_codec = FSM_TR_WAIT_FOR_TRIGGER;
            else
              fsm_next_state_r_tr_codec = FSM_TR_SET_READY;
          end
        FSM_TR_WAIT_FOR_TRIGGER:
          begin
            if(!ws)
              fsm_next_state_r_tr_codec = FSM_TR_WAIT_FOR_TRIGGER;
            else
              fsm_next_state_r_tr_codec = FSM_TR_IDLE;
          end

       
        default: 
          fsm_next_state_r_tr_codec = FSM_TR_IDLE;
    endcase
  end

always@*
  begin
    case (fsm_current_state_r_tr_codec)
      FSM_TR_IDLE:              s_axis_r_ready_tr_to_codec = 1'b0;
      FSM_TR_SET_READY:        s_axis_r_ready_tr_to_codec = 1'b1;
      FSM_TR_WAIT_FOR_TRIGGER:   s_axis_r_ready_tr_to_codec = 1'b0;
      default :              s_axis_r_ready_tr_to_codec = 1'b0;
    endcase
  end

//handshaking occur
always @(posedge aclk , negedge aresetn) begin
  if (!aresetn) begin
        r_data_tr_to_codec <= {D_WIDTH{1'b0}}; //if reset set output to 0
    end 
  else if(s_axis_r_ready_tr_to_codec && s_axis_r_valid_tr_to_codec) begin
        r_data_tr_to_codec <= s_axis_r_data_tr_to_codec;          
   end
  else begin
       // latch data
    end
end

endmodule