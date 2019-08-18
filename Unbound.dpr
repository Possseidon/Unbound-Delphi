program Unbound;

uses
  Vcl.Forms,
  Unbound.Main in 'Unbound.Main.pas' {frmMain},
  Unbound.Game in 'Unbound.Game.pas',
  Unbound.GameState in 'Unbound.GameState.pas',
  Unbound.InputManager in 'Unbound.InputManager.pas',
  Unbound.Shaders in 'Unbound.Shaders.pas',
  Unbound.Game.Serialization in 'Unbound.Game.Serialization.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

