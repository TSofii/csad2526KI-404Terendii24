module spi_master (
    input wire clk,          // Системний тактовий сигнал
    input wire rst,          // Скидання (активний високий)
    input wire start,        // Сигнал початку передачі
    input wire [7:0] data_in,// Дані для передачі
    output reg mosi,         // Вихід даних (Master Out Slave In)
    output reg sck,          // Тактовий сигнал SPI
    output reg cs_n,         // Вибір пристрою (Chip Select, активний низький)
    output reg busy          // Прапорець зайнятості
);

    // Стани кінцевого автомата (FSM)
    localparam IDLE = 2'b00;
    localparam SETUP = 2'b01;
    localparam TRANS = 2'b10;

    reg [1:0] state;
    reg [2:0] bit_cnt;       // Лічильник бітів (0-7)
    reg [7:0] shift_reg;     // Зсувний регістр
    reg sck_enable;          // Дозвіл генерації SCK

    // Логіка переходів станів та лічильників
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            cs_n <= 1'b1;    // Неактивний (високий рівень)
            mosi <= 1'b0;
            sck <= 1'b0;
            busy <= 1'b0;
            bit_cnt <= 3'd0;
            shift_reg <= 8'd0;
            sck_enable <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    cs_n <= 1'b1;
                    busy <= 1'b0;
                    sck <= 1'b0;
                    if (start) begin
                        state <= SETUP;
                        shift_reg <= data_in; // Завантажуємо дані
                        busy <= 1'b1;
                    end
                end

                SETUP: begin
                    cs_n <= 1'b0;    // Активуємо Slave (низький рівень)
                    state <= TRANS;
                    bit_cnt <= 3'd7; // Починаємо з 7-го біта
                    mosi <= shift_reg[7]; // Виставляємо перший біт
                    sck_enable <= 1'b1;
                end

                TRANS: begin
                    if (sck_enable) begin
                        sck <= ~sck; // Генеруємо імпульс
                        if (sck) begin // На спаді SCK міняємо біт
                            if (bit_cnt == 0) begin
                                state <= IDLE;
                                sck_enable <= 1'b0;
                            end else begin
                                bit_cnt <= bit_cnt - 1;
                                mosi <= shift_reg[bit_cnt - 1];
                            end
                        end
                    end
                end
            endcase
        end
    end
endmodule