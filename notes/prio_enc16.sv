//===========================================================
// Module: prio_enc16
// Description: 16-to-4 Priority Encoder
// Complete the code below the "add your code here" lines
//===========================================================

module prio_enc16 (
    input  logic A0,  A1,  A2,  A3,
    input  logic A4,  A5,  A6,  A7,
    input  logic A8,  A9,  A10, A11,
    input  logic A12, A13, A14, A15,
    output logic V,
    output logic Q3, Q2, Q1, Q0
);

// Outputs of the four 4-bit encoders (encoder0..encoder3)
logic v0, v1, v2, v3;
logic q0_1, q0_0; // group0 (A0..A3)
logic q1_1, q1_0; // group1 (A4..A7)
logic q2_1, q2_0; // group2 (A8..A11)
logic q3_1, q3_0; // group3 (A12..A15)

// Group select (which 4-bit group wins)
logic s1, s0;
