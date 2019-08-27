unit Unbound.Game.Core;

interface

uses
  Unbound.Game;

type

  TGamePackCore = class(TGamePack)
  public const

    GUID: TGUID = '{F3EC8666-E968-45A4-A592-0DBE0E530B28}';

  public
    constructor Create;

  end;

implementation

{ TGamePackCore }

constructor TGamePackCore.Create;
begin
  inherited Create(TGamePackCore.GUID);
end;

end.

