unit Unbound.Game.WorldFeatures;

interface

uses
  Pengine.IntMaths,

  Unbound.Game;

type

  TWorldFeatureTerrain = class(TWorldFeature)
  protected
    procedure CalculateBlock(AChunk: TChunk; const AChunkPos: TIntVector3); virtual; abstract;

  public
    procedure Apply(AChunk: TChunk); override;

  end;

  TWorldFeatureHeightmap = class(TWorldFeatureTerrain)
  protected
    procedure CalculateBlock(AChunk: TChunk; const AChunkPos: TIntVector3); override;

  public
    class function GetName: string; override;

  end;

  TWorldFeatureNoise = class(TWorldFeatureTerrain)
  protected
    procedure CalculateBlock(AChunk: TChunk; const AChunkPos: TIntVector3); override;

  public
    class function GetName: string; override;

  end;

  TWorldFeatureStructure = class(TWorldFeatureTerrain)
  protected
    procedure CalculateBlock(AChunk: TChunk; const AChunkPos: TIntVector3); override;

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
  X, Y, Z: Integer;
begin
  // Use nested loop for better performance
  for X := 0 to AChunk.Size.X do
    for Y := 0 to AChunk.Size.X do
      for Z := 0 to AChunk.Size.X do
        CalculateBlock(AChunk, IVec3(X, Y, Z));
end;

{ TWorldFeatureHeightmap }

procedure TWorldFeatureHeightmap.CalculateBlock(AChunk: TChunk; const AChunkPos: TIntVector3);
begin

end;

class function TWorldFeatureHeightmap.GetName: string;
begin
  Result := 'Heightmap';
end;

{ TWorldFeatureNoise }

procedure TWorldFeatureNoise.CalculateBlock(AChunk: TChunk; const AChunkPos: TIntVector3);
begin

end;

class function TWorldFeatureNoise.GetName: string;
begin
  Result := 'Noise';
end;

{ TWorldFeatureStructure }

procedure TWorldFeatureStructure.CalculateBlock(AChunk: TChunk; const AChunkPos: TIntVector3);
begin

end;

class function TWorldFeatureStructure.GetName: string;
begin
  Result := 'Structure';
end;

end.
