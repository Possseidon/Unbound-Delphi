unit Unbound.Game.WorldFeatures;

interface

uses
  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.Noise,
  Pengine.ICollections,
  Pengine.Interfaces,
  Pengine.Random,

  Unbound.Game,
  Unbound.Game.Serialization;

type

  TNoise2 = class(TInterfaceBase, IGradientSource2, ISerializable)
  private
    FPerlinNoise: TPerlinNoise2;
    FSeed: Integer;
    FFactor: TVector2;
    FOffset: TVector2;
    FBias: Single;

    function GetValue(APos: TVector2): Single;

    // IGradientSource2
    function GetGradient(APos: TIntVector2): TVector2;
    function GetBounds: TIntBounds2;

  public
    constructor Create;
    destructor Destroy; override;

    function Copy: TNoise2;

    property PerlinNoise: TPerlinNoise2 read FPerlinNoise;

    property Seed: Integer read FSeed;
    property Factor: TVector2 read FFactor;
    property Offset: TVector2 read FOffset;
    property Bias: Single read FBias;

    property Values[APos: TVector2]: Single read GetValue; default;

    // IGradientSource2
    property Gradients[APos: TIntVector2]: TVector2 read GetGradient; 
    property Bounds: TIntBounds2 read GetBounds;
    function HasBounds: Boolean;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TNoise2Editable = class(TNoise2)
  public
    procedure SetSeed(ASeed: Integer);
    procedure SetFactor(AFactor: TVector2);
    procedure SetOffset(AOffset: TVector2);
    procedure SetBias(ABias: Single);

  end;

  TMaterialPool = class(TInterfaceBase, ISerializable)
  public type

    TEntry = class(TInterfaceBase, ISerializable)
    private
      FMaterial: TTerrainMaterial;
      FWeight: Single;

    public
      function Copy: TEntry;
    
      property Material: TTerrainMaterial read FMaterial;
      property Weight: Single read FWeight;

      // ISerializable
      procedure Serialize(ASerialize: TSerializer);

    end;

    TEntryEditable = class(TEntry)
    public
      procedure SetMaterial(AMaterial: TTerrainMaterial);
      procedure SetWeight(AWeight: Single);
    
    end;

  private
    FSeed: Integer;
    FEntries: ISortedObjectList<TEntry>;
    FTotalWeight: Single;

    procedure UpdateTotalWeight;

    function GetEntries: IReadonlyList<TEntry>;
    function GetMaterial(APos: TIntVector3): TTerrainMaterial;

  public
    constructor Create;

    function Copy: TMaterialPool;

    property Seed: Integer read FSeed;
    property Entries: IReadonlyList<TEntry> read GetEntries;
    property TotalWeight: Single read FTotalWeight;

    property Materials[APos: TIntVector3]: TTerrainMaterial read GetMaterial; default;

    // ISerializable
    procedure Serialize(ASerialize: TSerializer);

  end;

  TMaterialPoolEditable = class(TMaterialPool)

  end;

  TWorldFeatureTerrain = class(TWorldFeature)
  protected
    procedure CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3); virtual; abstract;

  public
    procedure Apply(AChunk: TChunk); override;

  end;

  TWorldFeatureHeightmap = class(TWorldFeatureTerrain)
  private
    FNoises: IObjectList<TNoise2>;

    function GetNoises: IReadonlyList<TNoise2>;

  protected
    procedure Assign(AFrom: TWorldFeature); override;

    procedure CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3); override;

  public
    constructor Create; override;

    class function GetName: string; override;

    property Noises: IReadonlyList<TNoise2> read GetNoises;

    procedure Serialize(ASerializer: TSerializer); override;

  end;

  TWorldFeatureHeightmapEditable = class(TWorldFeatureHeightmap)
  public
    procedure AddNoise(ANoise: TNoise2);
    procedure RemoveNoise(ANoise: TNoise2);

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

{ TNoise2 }

function TNoise2.GetValue(APos: TVector2): Single;
begin
  Result := FPerlinNoise[APos];
end;

function TNoise2.GetGradient(APos: TIntVector2): TVector2;
var
  Rand: TRandom;
begin
  Rand := TRandom.FromSeed((Int64(TDefault.Hash(APos)) shl 32) or Seed);
  Result.Create(Rand.NextSingle, Rand.NextSingle);
end;

function TNoise2.GetBounds: TIntBounds2;
begin
  Result := IBounds2(0);
end;

constructor TNoise2.Create;
begin
  FPerlinNoise := TPerlinNoise2.Create;
  FPerlinNoise.GradientSource := Self;
  FFactor := 1;
end;

destructor TNoise2.Destroy;
begin
  FPerlinNoise.Free;
  inherited;
end;

function TNoise2.Copy: TNoise2;
begin
  Result := TNoise2.Create;
  Result.FSeed := Seed;
  Result.FFactor := Factor;
  Result.FOffset := Offset;
  Result.FBias := Bias;
end;

function TNoise2.HasBounds: Boolean;
begin
  Result := False;
end;

procedure TNoise2.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define('Seed', FSeed);
  ASerializer.Define('Factor', FFactor);
  ASerializer.Define('Offset', FOffset);
  ASerializer.Define('Bias', FBias);
end;

{ TNoise2Editable }

procedure TNoise2Editable.SetSeed(ASeed: Integer);
begin
  FSeed := ASeed;
end;

procedure TNoise2Editable.SetFactor(AFactor: TVector2);
begin
  FFactor := AFactor;
end;

procedure TNoise2Editable.SetOffset(AOffset: TVector2);
begin
  FOffset := AOffset;
end;

procedure TNoise2Editable.SetBias(ABias: Single);
begin
  FBias := ABias;
end;

{ TMaterialPool.TEntry }

function TMaterialPool.TEntry.Copy: TEntry;
begin
  Result := TEntry.Create;
  Result.FMaterial := Material;
  Result.FWeight := Weight;
end;

procedure TMaterialPool.TEntry.Serialize(ASerialize: TSerializer);
begin
  // TODO: Only reference via name, maybe add something for that into TSerializer directly
  // ASerialize.Define('Material', FMaterial);
  ASerialize.Define('Weight', FWeight);
end;

{ TMaterialPool.TEntryEditable }

procedure TMaterialPool.TEntryEditable.SetMaterial(AMaterial: TTerrainMaterial);
begin
  FMaterial := AMaterial;
end;

procedure TMaterialPool.TEntryEditable.SetWeight(AWeight: Single);
begin
  FWeight := AWeight;
end;

{ TMaterialPool }

function TMaterialPool.Copy: TMaterialPool;
var
  Entry: TEntry;
begin
  Result := TMaterialPool.Create;
  Result.FSeed := Seed;
  for Entry in Entries do
    Result.FEntries.Add(Entry.Copy);
end;

constructor TMaterialPool.Create;
begin
  FEntries := TSortedObjectList<TEntry>.Create;
  FEntries.Compare := function(A, B: TEntry): Boolean
    begin
      Result := A.Weight > B.Weight;
    end;
end;

function TMaterialPool.GetEntries: IReadonlyList<TEntry>;
begin
  Result := FEntries.ReadonlyList;
end;

function TMaterialPool.GetMaterial(APos: TIntVector3): TTerrainMaterial;
var
  Value: Single;
  Entry: TEntry;
begin
  Value := TRandom.FromSeed((Int64(TDefault.Hash(APos)) shl 32) or Cardinal(Seed)).NextSingle * FTotalWeight;
  for Entry in Entries do
  begin
    Value := Value - Entry.Weight;
    if Value < 0 then
      Exit(Entry.Material);
  end;
  Exit(Entries.Last.Material);
end;

procedure TMaterialPool.Serialize(ASerialize: TSerializer);
begin
  ASerialize.Define('Seed', FSeed);
  ASerialize.Define<TEntry>('Entries', FEntries);
  if ASerialize.Mode = smUnserialize then
    UpdateTotalWeight;
end;

procedure TMaterialPool.UpdateTotalWeight;
var
  Entry: TEntry;
begin
  FTotalWeight := 0;
  for Entry in Entries do
    FTotalWeight := FTotalWeight + Entry.Weight;
end;

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

procedure TWorldFeatureHeightmap.Assign(AFrom: TWorldFeature);
var
  Typed: TWorldFeatureHeightmap;
  Noise: TNoise2;
begin
  Typed := AFrom as TWorldFeatureHeightmap;
  for Noise in Typed.Noises do
    FNoises.Add(Noise.Copy);  
end;

procedure TWorldFeatureHeightmap.CalculateBlock(ATerrain: TTerrain; const AChunkPos: TIntVector3);
begin

end;

constructor TWorldFeatureHeightmap.Create;
begin
  inherited;
  FNoises := TObjectList<TNoise2>.Create;
end;

class function TWorldFeatureHeightmap.GetName: string;
begin
  Result := 'Heightmap';
end;

function TWorldFeatureHeightmap.GetNoises: IReadonlyList<TNoise2>;
begin
  Result := FNoises.ReadonlyList;
end;

procedure TWorldFeatureHeightmap.Serialize(ASerializer: TSerializer);
begin
  inherited;
  ASerializer.Define<TNoise2>('Noises', FNoises);
end;

{ TWorldFeatureHeightmapEditable }

procedure TWorldFeatureHeightmapEditable.AddNoise(ANoise: TNoise2);
begin
  FNoises.Add(ANoise.Copy);
end;

procedure TWorldFeatureHeightmapEditable.RemoveNoise(ANoise: TNoise2);
begin
  FNoises.Remove(ANoise)
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
