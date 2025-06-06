# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.binary import BinaryValue

@cocotb.test()
async def test_tt_um_8bit_counter(dut):
    dut._log.info("Starting enhanced testbench...")

    # Set up clock: 10 ns period (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # === INITIALIZATION ===
    dut.clk.value = 0
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Reset sequence
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # === COUNT FROM 0 to 0xFF ===
    dut._log.info("Counting from 0 to 0xFF")
    for i in range(256):
        await ClockCycles(dut.clk, 1)
        expected = (i + 1) % 256  # Counter increments after clock edge
        dut._log.info(f"Counter = {int(dut.uo_out.value):02x}")
        assert dut.uo_out.value == BinaryValue(expected, n_bits=8), f"Counter mismatch at {expected}: expected {expected:02x}, got {int(dut.uo_out.value):02x}"

    # === WRAP-AROUND OBSERVATION ===
    for i in range(5):
        await ClockCycles(dut.clk, 1)
        dut._log.info(f"Wrap-around: Counter = {int(dut.uo_out.value):02x}")
        expected = (i + 1) % 256
        assert dut.uo_out.value == BinaryValue(expected, n_bits=8), f"Counter mismatch after wrap-around at {i}: expected {i:02x}, got {int(dut.uo_out.value):02x}"

    # === LOAD NEW VALUE ===
    dut._log.info("Loading value 0x2b")
    dut.ui_in.value = 0x2b
    dut.uio_in.value = 0xFF  # Load signal asserted
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0x00  # Load deasserted
    assert dut.uo_out.value == BinaryValue(0x2b, n_bits=8), f"Counter mismatch after load: expected 0x2b, got {int(dut.uo_out.value):02x}"
    dut._log.info(f"Right after load: Counter = {int(dut.uo_out.value):02x}")
    await ClockCycles(dut.clk, 1)
    dut._log.info(f"After load: Counter = {int(dut.uo_out.value):02x}")

    # === CONTINUE COUNTING ===
    for i in range(10):
        await ClockCycles(dut.clk, 1)
        dut._log.info(f"Post-load counting: Counter = {int(dut.uo_out.value):02x}")

    # === DISABLE COUNTER ===
    dut._log.info("Disabling counter for 10 cycles")
    dut.ena.value = 0
    temp = int(dut.uo_out.value)
    for i in range(10):
        await ClockCycles(dut.clk, 1)
        dut._log.info(f"While disabled: Counter = {int(dut.uo_out.value):02x}")
        assert dut.uo_out.value == BinaryValue(temp, n_bits=8)

    # === RE-ENABLE COUNTER ===
    dut._log.info("Re-enabling counter")
    dut.ena.value = 1
    for i in range(10):
        await ClockCycles(dut.clk, 1)
        dut._log.info(f"After re-enable: Counter = {int(dut.uo_out.value):02x}")

    dut._log.info("Testbench complete.")
