unit Unbound.Game.Vanilla;

interface

uses
  Pengine.ICollections,

  Unbound.Game;

type

  TGamePackVanilla = class(TGamePack)
  public const

    GUID: TGUID = '{B5423E56-8DFD-4D46-9510-5A4AD7F102DE}';

  public type

    TOverwoldGenerator = class(TWorldGenerator)

    end;

  private

  public
    constructor Create;

  end;

implementation

{ TGamePackVanilla }

constructor TGamePackVanilla.Create;
begin
  inherited Create(TGamePackVanilla.GUID);
end;

end.

