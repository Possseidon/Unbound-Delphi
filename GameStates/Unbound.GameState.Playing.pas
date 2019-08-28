unit Unbound.GameState.Playing;

interface

uses
  Unbound.GameState,
  Unbound.Game,
  Unbound.Game.Renderer;

type

  TGameStatePlaying = class(TGameState)
  private
    FGame: TGame;
    FRenderer: TGameRenderer;

  protected
    procedure DoLoad; override;
    procedure DoUnload; override;

  public
    procedure Render; override;

  end;

implementation

uses
  Unbound.Game.Vanilla;

{ TGameStatePlaying }

procedure TGameStatePlaying.DoLoad;
begin
  FGame := TGame.Create;
  FRenderer := TGameRenderer.Create(FGame);
end;

procedure TGameStatePlaying.DoUnload;
begin
  FRenderer.Free;
  FGame.Free;
end;

procedure TGameStatePlaying.Render;
begin
  FRenderer.Camera.Render;
end;

end.
