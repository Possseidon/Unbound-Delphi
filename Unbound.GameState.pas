unit Unbound.GameState;

interface

uses
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
var
  UBSData: TUBSMap;
begin
  FGame := TGame.Create;
  FGame.AddWorld;
  UBSData := TSerializer.Serialize(FGame);
end;

end.
