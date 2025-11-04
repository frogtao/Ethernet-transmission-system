/************************************************************\
**	Copyright (c) 2012-2025 Anlogic Inc.
**	All Right Reserved.
\************************************************************/
/************************************************************\
**	Build time: Oct 01 2025 21:40:26
**	TD version	:	6.2.168116
************************************************************/
module ChipWatcher_0
(
  input   [0:0]                 probe0,
  input   [7:0]                 probe1,
  input   [0:0]                 probe2,
  input   [0:0]                 probe3,
  input   [0:0]                 probe4,
  input                         clk
);

  ChipWatcher_f5cdf1b3d45f  ChipWatcher_f5cdf1b3d45f_Inst
  (
      .probe0(probe0),
      .probe1(probe1),
      .probe2(probe2),
      .probe3(probe3),
      .probe4(probe4),
      .clk(clk)
  );
endmodule
