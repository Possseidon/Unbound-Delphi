unit Unbound.GameState.Playing;

interface

uses
  Pengine.Color,

  Unbound.GameState,
  Unbound.Game,
  Unbound.Game.Renderer,
  Unbound.Game.Serialization,
  Unbound.Game.WorldFeatures;

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
  Feature: TWorldFeatureHeightmapEditable;
  Noise: TNoise2Editable;
begin
  Material := TTerrainMaterialEditable.Create;
  Material.SetColor(ColorRGB(1, 0, 1));

  Noise := TNoise2Editable.Create;
  Noise.SetSeed(42);

  Feature := TWorldFeatureHeightmapEditable.Create;
  Feature.AddNoise(Noise);

  WorldGenerator := TWorldGeneratorEditable.Create;
  WorldGenerator.AddFeature(Feature);

  TestGamePack := TGamePackEditable.Create;
  TestGamePack.SetName('Test');
  TestGamePack.GenerateNewGUID;
  TestGamePack.AddMaterial(Material);
  TestGamePack.AddWorldGenerator(WorldGenerator);

  FGame := TGame.Create;
  FGame.AddGamePack(TestGamePack);

  WorldGenerator.Free;
  Feature.Free;
  Material.Free;
  Noise.Free;
  TestGamePack.Free;

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
