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

  protected
    procedure DoLoad; override;
    procedure DoUnload; override;

  end;

implementation

{ TGameStatePlaying }

procedure TGameStatePlaying.DoLoad;
begin
  FGame := TGame.Create;
  FRenderer := TGameRenderer.Create(FGame);
end;

procedure TGameStatePlaying.DoUnload;
begin
  FRenderer.Free;
  FGame := nil;
end;

end.
