unit Unbound.GameState.Playing;

interface

uses
  Pengine.Color,

  Unbound.GameState,
  Unbound.Game,
  Unbound.Game.Renderer,
  Unbound.Game.Serialization;

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

{ TGameStatePlaying }

procedure TGameStatePlaying.DoLoad;
var
  TestGamePack: TGamePackEditable;
  UBSMap: TUBSMap;
  Material: TTerrainMaterialEditable;
  WorldGenerator: TWorldGeneratorEditable;
begin
  TestGamePack := TGamePackEditable.Create;
  TestGamePack.Rename('Test');
  TestGamePack.GenerateNewGUID;

  Material := TTerrainMaterialEditable.Create;
  Material.Recolor(ColorRGB(1, 0, 1));
  TestGamePack.AddMaterial(Material);
  Material.Free;

  WorldGenerator := TWorldGeneratorEditable.Create;
  // WorldGenerator.AddFeature();
  TestGamePack.AddWorldGenerator(WorldGenerator);
  WorldGenerator.Free;

  FGame := TGame.Create;
  FGame.AddGamePack(TestGamePack);
  TestGamePack.Free;

  UBSMap := TSerializer.Serialize(FGame);
  UBSMap.SaveToFile('TestGame.ubs');
  UBSMap.Free;

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
