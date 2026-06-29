module HazardDetectionUnit (
    input Forwarding_EN,
    input [3:0] src1,
    input [3:0] src2,
    input Two_src,
    input [3:0] EXE_Dest,
    input [3:0] MEM_Dest,
    input EXE_WB_EN,
    input MEM_WB_EN,
    input EXE_MEM_R_EN,
    output Detected_Hazard
);

    wire src1_matches_exe;
    wire src2_matches_exe;
    wire src1_matches_mem;
    wire src2_matches_mem;
    wire hazard_with_exe;
    wire hazard_with_mem;
    wire load_use_hazard;

    assign src1_matches_exe = (EXE_Dest != 4'd15) && (src1 == EXE_Dest);
    assign src2_matches_exe = Two_src && (EXE_Dest != 4'd15) && (src2 == EXE_Dest);
    assign src1_matches_mem = (MEM_Dest != 4'd15) && (src1 == MEM_Dest);
    assign src2_matches_mem = Two_src && (MEM_Dest != 4'd15) && (src2 == MEM_Dest);

    assign hazard_with_exe = EXE_WB_EN && (src1_matches_exe || src2_matches_exe);
    assign hazard_with_mem = MEM_WB_EN && (src1_matches_mem || src2_matches_mem);
    assign load_use_hazard = EXE_MEM_R_EN && hazard_with_exe;

    assign Detected_Hazard = Forwarding_EN ? load_use_hazard : (hazard_with_exe || hazard_with_mem);

endmodule
