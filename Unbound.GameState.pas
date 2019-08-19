unit Unbound.GameState;

interface

uses
  System.Diagnostics,
  System.SysUtils,

  Pengine.IntMaths,

  Unbound.Game,
  Unbound.Game.Serialization;

type

  TGameState = class
  public type

    TTransition = class

    end;

  private
    FGame: IGame;

  public
    constructor Create;

  end;

implementation

{ TGameState }

constructor TGameState.Create;
begin
  FGame := TGame.Create;
  FGame.AddWorld(TWorldGenerator.Create);
end;

end.
