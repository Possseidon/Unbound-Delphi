program UBSExplorer;



uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Vcl.ComCtrls,
  UBSExplorer.Main in 'UBSExplorer.Main.pas' {Form1},
  UBSExplorer.Tab in 'UBSExplorer.Tab.pas' {frmTab: TFrame};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  TStyleManager.TrySetStyle('Carbon');

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

