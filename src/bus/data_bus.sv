`include "common_defs.svh"

module data_bus(
    Bus_if.slave  cpu,
    Bus_if.master ram,
    Bus_if.master flash,
    Bus_if.master uart,
    Bus_if.master timer,
    Bus_if.master graphics,
    Bus_if.master ethernet,
    Bus_if.master gpio
);

    assign ram.data_wr = cpu.data_wr;
    assign ram.address = cpu.address[2 +: `RAM_ADDRESS_WIDTH];
    assign ram.mask = cpu.mask;

    // we do not write flash
    assign flash.data_wr = cpu.data_wr;
    assign flash.address = cpu.address[2 +: `FLASH_ADDRESS_WIDTH];
    assign flash.mask = cpu.mask;

    // uart and timer are always one-byte
    assign uart.data_wr = cpu.data_wr;
    assign uart.address = cpu.address[2 +: `UART_ADDRESS_WIDTH];

    assign timer.data_wr = cpu.data_wr;
    assign timer.address = cpu.address[2 +: `TIMER_ADDRESS_WIDTH];

    assign graphics.data_wr = cpu.data_wr;
    assign graphics.address = cpu.address[2 +: `GRAPHICS_ADDRESS_WIDTH];
    assign graphics.mask = cpu.mask;

    // TODO: NOT implemented
    assign ethernet.data_wr = cpu.data_wr;
    assign ethernet.address = cpu.address[2 +: `ETHERNET_ADDRESS_WIDTH];

    assign gpio.data_wr = cpu.data_wr;
    assign gpio.address = cpu.address[2 +: `GPIO_ADDRESS_WIDTH];
    assign gpio.mask    = cpu.mask;

    always_comb begin

        ram.read       = `ZERO_BIT;
        ram.write      = `ZERO_BIT;
        flash.read     = `ZERO_BIT;
        flash.write    = `ZERO_BIT;
        uart.read      = `ZERO_BIT;
        uart.write     = `ZERO_BIT;
        timer.read     = `ZERO_BIT;
        timer.write    = `ZERO_BIT;
        graphics.read  = `ZERO_BIT;
        graphics.write = `ZERO_BIT;
        ethernet.read  = `ZERO_BIT;
        ethernet.write = `ZERO_BIT;

        cpu.data_rd   = `ZERO_WORD;
        cpu.data_rd_2 = `ZERO_WORD; // we only process one word of r/w on dbus at every clock
        cpu.stall     = `ZERO_BIT;

        if (`MATCH_PREFIX(cpu.address, `RAM_ADDRESS_PREFIX)) begin
            ram.read    = cpu.read;
            ram.write   = cpu.write;
            cpu.data_rd = ram.data_rd;
            cpu.stall   = ram.stall;
        end else if (`MATCH_PREFIX(cpu.address, `FLASH_ADDRESS_PREFIX)) begin
            flash.read  = cpu.read;
            flash.write = cpu.write;
            cpu.data_rd = flash.data_rd;
            cpu.stall   = flash.stall;
        end else if (`MATCH_PREFIX(cpu.address, `UART_ADDRESS_PREFIX)) begin
            uart.read   = cpu.read;
            uart.write  = cpu.write;
            cpu.data_rd = uart.data_rd;
        end else if (`MATCH_PREFIX(cpu.address, `TIMER_ADDRESS_PREFIX)) begin
            timer.read  = cpu.read;
            timer.write = cpu.write;
            cpu.data_rd = timer.data_rd;
        end else if (`MATCH_PREFIX(cpu.address, `GRAPHICS_ADDRESS_PREFIX)) begin
            graphics.read  = cpu.read;
            graphics.write = cpu.write;
            cpu.data_rd    = graphics.data_rd;
        end else if (`MATCH_PREFIX(cpu.address, `ETHERNET_ADDRESS_PREFIX)) begin
            ethernet.read  = cpu.read;
            ethernet.write = cpu.write;
            cpu.data_rd    = ethernet.data_rd;
            cpu.stall      = ethernet.stall;
        end else if (`MATCH_PREFIX(cpu.address, `GPIO_ADDRESS_PREFIX)) begin
            gpio.read   = cpu.read;
            gpio.write  = cpu.write;
            cpu.data_rd = gpio.data_rd;
        end
    end

endmodule