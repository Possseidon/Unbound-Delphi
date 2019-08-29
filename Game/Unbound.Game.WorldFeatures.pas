unit Unbound.Game.WorldFeatures;

interface

uses
  Pengine.IntMaths,

  Unbound.Game;

type

  TWorldFeatureTerrain = class(TWorldFeature)
  protected
    procedure CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3); virtual; abstract;

  public
    procedure Apply(AChunk: TChunk); override;

  end;

  TWorldFeatureHeightmap = class(TWorldFeatureTerrain)
  protected
    procedure CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3); override;

  public
    class function GetName: string; override;

  end;

  TWorldFeatureNoise = class(TWorldFeatureTerrain)
  protected
    procedure CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3); override;

  public
    class function GetName: string; override;

  end;

  TWorldFeatureStructure = class(TWorldFeatureTerrain)
  protected
    procedure CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3); override;

  public
    class function GetName: string; override;

  end;

const

  WorldFeatureClasses: array [0 .. 2] of TWorldFeatureClass = (
    TWorldFeatureHeightmap,
    TWorldFeatureNoise,
    TWorldFeatureStructure
    );

implementation

{ TWorldFeatureTerrain }

procedure TWorldFeatureTerrain.Apply(AChunk: TChunk);
var
  X, Y, Z, SX, SY, SZ: Integer;
  Terrain: TTerrain;
begin
  // Use nested loop for better performance
  SX := AChunk.Size.X;
  SY := AChunk.Size.Y;
  SZ := AChunk.Size.Z;
  Terrain := AChunk.Terrain;
  for X := 0 to SX do
    for Y := 0 to SY do
      for Z := 0 to SZ do
        CalculateBlock(Terrain, IVec3(X, Y, Z));
end;

{ TWorldFeatureHeightmap }

procedure TWorldFeatureHeightmap.CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3);
begin

end;

class function TWorldFeatureHeightmap.GetName: string;
begin
  Result := 'Heightmap';
end;

{ TWorldFeatureNoise }

procedure TWorldFeatureNoise.CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3);
begin

end;

class function TWorldFeatureNoise.GetName: string;
begin
  Result := 'Noise';
end;

{ TWorldFeatureStructure }

procedure TWorldFeatureStructure.CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3);
begin

end;

class function TWorldFeatureStructure.GetName: string;
begin
  Result := 'Structure';
end;

end.
