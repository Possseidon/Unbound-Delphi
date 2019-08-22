program Unbound;

uses
  Vcl.Forms,
  Pengine.DebugConsole,
  Unbound.Main in 'Unbound.Main.pas' {frmMain},
  Unbound.Game in 'Game\Unbound.Game.pas',
  Unbound.GameState in 'GameStates\Unbound.GameState.pas',
  Unbound.InputManager in 'Unbound.InputManager.pas',
  Unbound.Shaders in 'Unbound.Shaders.pas',
  Unbound.Game.Serialization in 'Game\Unbound.Game.Serialization.pas',
  Unbound.Game.WorldFeatures in 'Game\Unbound.Game.WorldFeatures.pas',
  Unbound.GameState.MainMenu in 'GameStates\Unbound.GameState.MainMenu.pas',
  Unbound.GameState.Loading in 'GameStates\Unbound.GameState.Loading.pas',
  Unbound.GameState.Playing in 'GameStates\Unbound.GameState.Playing.pas',
  Unbound.Game.Renderer in 'Game\Unbound.Game.Renderer.pas',
  Unbound.Game.Vanilla in 'Game\Unbound.Game.Vanilla.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

