unit Unbound.GameState.Playing;

interface

uses
  Unbound.GameState,
  Unbound.Game,
  Unbound.Game.Renderer;

type

  TGameStatePlaying = class(TGameState)
  private
    FGame: IGame;
    FRenderer: TGameRenderer;
    FVanilla: IGamePack;

  protected
    procedure DoLoad; override;
    procedure DoUnload; override;

  end;

implementation

uses
  Unbound.Game.Vanilla;

{ TGameStatePlaying }

procedure TGameStatePlaying.DoLoad;
begin
  FGame := TGame.Create;
  FVanilla := TGamePackVanilla.Create;
  FGame.AddGamePack(FVanilla);
  FRenderer := TGameRenderer.Create(FGame);
end;

procedure TGameStatePlaying.DoUnload;
begin
  FRenderer.Free;
  FVanilla := nil;
  FGame := nil;
end;

end.
