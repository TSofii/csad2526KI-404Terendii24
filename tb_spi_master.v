`timescale 1ns / 1ps

module tb_spi_master;

    // Вхідні сигнали для модуля
    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;

    // Вихідні сигнали від модуля
    wire mosi;
    wire sck;
    wire cs_n;
    wire busy;

    // Підключення нашого модуля (Unit Under Test)
    spi_master uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .mosi(mosi),
        .sck(sck),
        .cs_n(cs_n),
        .busy(busy)
    );

    // Генерація тактового сигналу (Clock)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Період 10нс = 100 МГц
    end

    // Сценарій тестування
    initial begin
        // 1. Початковий стан
        rst = 1;
        start = 0;
        data_in = 0;

        // Чекаємо 100 нс і знімаємо Reset
        #100;
        rst = 0;
        #20;

        // 2. Тест 1: Передаємо число 0xA5 (10100101)
        data_in = 8'hA5;
        start = 1;      // Натискаємо "Старт"
        #10;            // Тримаємо 1 такт
        start = 0;      // Відпускаємо

        // Чекаємо, поки модуль звільниться (busy стане 0)
        wait(busy == 0);
        #100;

        // 3. Тест 2: Передаємо число 0x3C (00111100)
        data_in = 8'h3C;
        start = 1;
        #10;
        start = 0;

        wait(busy == 0);
        #100;

        // Кінець тесту
        $finish;
    end
      
endmodule