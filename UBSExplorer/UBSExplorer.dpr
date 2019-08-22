program UBSExplorer;



uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Vcl.ComCtrls,
  Main in 'Main.pas' {Form1};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  TStyleManager.TrySetStyle('Carbon');

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

