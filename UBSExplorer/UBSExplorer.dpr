program UBSExplorer;

uses
  Vcl.Forms,
  UBSExplorer.Main in 'UBSExplorer.Main.pas' {Form1},
  UBSExplorer.Tab in 'UBSExplorer.Tab.pas' {frmTab: TFrame},
  UBSExplorer.EditValueDialog in 'UBSExplorer.EditValueDialog.pas' {dlgEditValue},
  UBSExplorer.DataModule in 'UBSExplorer.DataModule.pas' {dmData: TDataModule},
  UBSExplorer.RegistrySettings in 'UBSExplorer.RegistrySettings.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdlgEditValue, dlgEditValue);
  Application.CreateForm(TdmData, dmData);
  Application.Run;

end.
