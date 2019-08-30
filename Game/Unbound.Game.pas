unit Unbound.Game;

interface

uses
  System.SysUtils,

  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.ICollections,
  Pengine.EventHandling,
  Pengine.Color,
  Pengine.Lua,
  Pengine.Lua.Header,
  Pengine.Interfaces,

  Unbound.Game.Serialization;

type

  EUnboundError = class(Exception);

  TWorld = class;
  TChunk = class;

  /// <summary>A block aligned position in a world.</summary>
  IBlockPosition = interface(ISerializable)
    function GetWorld: TWorld;
    function GetPosition: TIntVector3;
    procedure SetPosition(const Value: TIntVector3);
    function GetChunk: TChunk;

    property World: TWorld read GetWorld;
    property Position: TIntVector3 read GetPosition write SetPosition;
    property Chunk: TChunk read GetChunk;

  end;

  TBlockPosition = class(TInterfaceBase, IBlockPosition, ISerializable)
  private
    FWorld: TWorld;
    FPosition: TIntVector3;

    // IBlockPosition
    function GetWorld: TWorld;
    function GetPosition: TIntVector3;
    procedure SetPosition(const Value: TIntVector3);
    function GetChunk: TChunk;

  public
    constructor Create(AWorld: TWorld); overload;
    constructor Create(AWorld: TWorld; const APosition: TIntVector3); overload;

    // IBlockPosition
    property World: TWorld read GetWorld;
    property Position: TIntVector3 read GetPosition write SetPosition;
    property Chunk: TChunk read GetChunk;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  /// <summary>A location (position and rotation) in a world.</summary>
  IWorldLocation = interface(ISerializable)
    function GetWorld: TWorld;
    function GetLocation: TLocation3;
    procedure SetLocation(const Value: TLocation3);
    function GetChunk: TChunk;

    function Copy: IWorldLocation;
    procedure Assign(const AFrom: IWorldLocation);

    property World: TWorld read GetWorld;
    property Location: TLocation3 read GetLocation write SetLocation;
    property Chunk: TChunk read GetChunk;

  end;

  TWorldLocation = class(TInterfacedObject, IWorldLocation, ISerializable)
  private
    FWorld: TWorld;
    FLocation: TLocation3;

    function GetWorld: TWorld;
    function GetLocation: TLocation3;
    procedure SetLocation(const Value: TLocation3);
    function GetChunk: TChunk;

  public
    constructor Create(AWorld: TWorld); overload;
    constructor Create(AWorld: TWorld; ALocation: TLocation3); overload;
    destructor Destroy; override;

    function Copy: IWorldLocation;
    procedure Assign(const AFrom: IWorldLocation);

    property World: TWorld read GetWorld;
    property Location: TLocation3 read GetLocation write SetLocation;
    property Chunk: TChunk read GetChunk;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  /// <summary>A material, which chunk terrain is made up of.</summary>
  TTerrainMaterial = class(TInterfaceBase, ISerializable)
  private
    FColor: TColorRGBA;

  public
    function Copy: TTerrainMaterial;

    property Color: TColorRGBA read FColor;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TTerrainMaterialEditable = class(TTerrainMaterial)
  public
    procedure SetColor(AColor: TColorRGBA);

  end;

  /// <summary>The terrain which a chunk is made up of.</summary>
  TTerrain = class(TInterfaceBase, ISerializable)
  public const

    MaxVolume = $10000;

  private
    FSize: TIntVector3;
    FMaterials: IObjectList<TTerrainMaterial>;
    FData: array of Word;
    FOnChange: TEvent<TTerrain>;

    function PosToIndex(const APos: TIntVector3): Integer; inline;
    procedure Change; inline;

    function GetMaterials: IReadonlyList<TTerrainMaterial>;
    function GetMaterialIDAt(const APos: TIntVector3): Integer;
    procedure SetMaterialIDAt(const APos: TIntVector3; const Value: Integer);
    function GetMaterialAt(const APos: TIntVector3): TTerrainMaterial;
    procedure SetMaterialAt(const APos: TIntVector3; const Value: TTerrainMaterial);
    function GetOnChange: TEvent<TTerrain>.TAccess;

  public
    constructor Create(const ASize: TIntVector3);

    property Materials: IReadonlyList<TTerrainMaterial> read GetMaterials;
    function GetMaterialID(AMaterial: TTerrainMaterial): Integer;
    procedure RemoveUnusedMaterials;

    property Size: TIntVector3 read FSize;
    property MaterialIDAt[const APos: TIntVector3]: Integer read GetMaterialIDAt write SetMaterialIDAt;
    property MaterialAt[const APos: TIntVector3]: TTerrainMaterial read GetMaterialAt write SetMaterialAt; default;

    property OnChange: TEvent<TTerrain>.TAccess read GetOnChange;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  /// <summary>Block aligned models, which can take up multiple block spaces per model.</summary>
  TDesign = class(TInterfaceBase, ISerializable)
  public
    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  /// <summary>An entity, which can be placed and moved freely in the world.</summary>
  TEntity = class(TInterfaceBase, ISerializable)
  private
    FGUID: TGUID;
    FLocation: IWorldLocation;

    procedure SetLocation(const Value: IWorldLocation);

  public
    constructor Create(const ALocation: IWorldLocation);

    property GUID: TGUID read FGUID;
    property Location: IWorldLocation read FLocation write SetLocation;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer); virtual;

  end;

  /// <summary>A cuboid chunk of a world, made up of terrain, design and entities.</summary>
  TChunk = class(TInterfaceBase, ISerializable)
  private
    FWorld: TWorld;
    FChunkPos: TIntVector3;
    FTerrain: TTerrain;
    FDesign: TDesign;
    FEntities: IObjectList<TEntity>;

    function GetWorldPos: TIntVector3;
    function GetSize: TIntVector3;
    function GetEntities: IReadonlyList<TEntity>;

  public
    constructor Create(AWorld: TWorld; const AChunkPos, ASize: TIntVector3);
    destructor Destroy; override;

    property World: TWorld read FWorld;
    property ChunkPos: TIntVector3 read FChunkPos;
    property WorldPos: TIntVector3 read GetWorldPos;
    property Size: TIntVector3 read GetSize;

    property Terrain: TTerrain read FTerrain;
    property Design: TDesign read FDesign;
    property Entities: IReadonlyList<TEntity> read GetEntities;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TWorldGenerator = class;

  TWorldFeatureClass = class of TWorldFeature;

  /// <summary>A feature, that generates a chunk via the "Apply" method.</summary>
  TWorldFeature = class(TInterfaceBase, ISerializable)
  protected
    procedure Assign(AFrom: TWorldFeature); virtual; abstract;
    
  public
    constructor Create; virtual;

    class function CreateSame: TWorldFeature;
    function Copy: TWorldFeature;

    class function CreateTyped(AUBSMap: TUBSMap): TWorldFeature;
    class function GetName: string; virtual; abstract;

    procedure Serialize(ASerializer: TSerializer); virtual;

    procedure Apply(AChunk: TChunk); virtual; abstract;

  end;

  /// <summary>A list of world features, which get applied in order, making up a world generator.</summary>
  TWorldGenerator = class(TInterfaceBase, ISerializable)
  private
    FFeatures: IObjectList<TWorldFeature>;

    function CreateFeature(AUBSMap: TUBSMap): TWorldFeature;
    function GetFeatures: IReadonlyList<TWorldFeature>;

  public
    constructor Create;

    function Copy: TWorldGenerator; 

    procedure GenerateChunk(AChunk: TChunk);

    property Features: IReadonlyList<TWorldFeature> read GetFeatures;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TWorldGeneratorEditable = class(TWorldGenerator)
  public
    procedure AddFeature(AFeature: TWorldFeature);
    procedure RemoveFeature(AFeature: TWorldFeature);
    
  end;

  TGame = class;

  /// <summary>A close to infinite world, consisting of cuboid chunks.</summary>
  TWorld = class(TInterfaceBase, ISerializable)
  public const

    DefaultChunkSize: TIntVector3 = (X: 32; Y: 32; Z: 32);

  private
    FGame: TGame;
    FGenerator: TWorldGenerator;
    FChunks: IToObjectMap<TIntVector3, TChunk>;
    FChunkSize: TIntVector3;

    function GetChunks: IReadonlyMap<TIntVector3, TChunk>;

  public
    constructor Create(AGame: TGame); overload;
    constructor Create(AGame: TGame; AGenerator: TWorldGenerator); overload;

    property Game: TGame read FGame;
    property Generator: TWorldGenerator read FGenerator;
    property Chunks: IReadonlyMap<TIntVector3, TChunk> read GetChunks;
    property ChunkSize: TIntVector3 read FChunkSize;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  /// <summary>Contains game resources and behaviors.</summary>
  TGamePack = class(TInterfaceBase, ISerializable)
  private
    FName: string;
    FGUID: TGUID;
    // FVersion: TVersion;
    FDependencyGUIDs: IList<TGUID>;
    FMaterials: IObjectList<TTerrainMaterial>;
    FWorldGenerators: IObjectList<TWorldGenerator>;

    function GetDependencyGUIDs: IReadonlyList<TGUID>;
    function GetWorldGenerators: IReadonlyList<TWorldGenerator>;
    function GetMaterials: IReadonlyList<TTerrainMaterial>;

  public
    constructor Create;

    function Copy: TGamePack;

    property Name: string read FName;
    property GUID: TGUID read FGUID;
    property DependencyGUIDs: IReadonlyList<TGUID> read GetDependencyGUIDs;

    property WorldGenerators: IReadonlyList<TWorldGenerator> read GetWorldGenerators;

    property Materials: IReadonlyList<TTerrainMaterial> read GetMaterials;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  /// <summary>An editable version of TGamePack, which can be edited without the means of serialization.</summary>
  TGamePackEditable = class(TGamePack)
  public
    procedure SetName(AName: string);
    procedure GenerateNewGUID;

    procedure AddDependency(AGamePack: TGamePack);
    procedure RemoveDependency(AGamepack: TGamePack);

    procedure AddMaterial(AMaterial: TTerrainMaterial);
    procedure RemoveMaterial(AMaterial: TTerrainMaterial);

    procedure AddWorldGenerator(AGenerator: TWorldGenerator);
    procedure RemoveWorldGenerator(AGenerator: TWorldGenerator);

  end;

  /// <summary>A game, consisting of multiple worlds and global game settings.</summary>
  TGame = class(TInterfaceBase, ISerializable)
  private
    FLua: TLua;
    FGamePacks: IObjectList<TGamePack>;
    FWorlds: IObjectList<TWorld>;

    function CreateWorld: TWorld;

    function GetLuaState: TLuaState;
    function GetGamePacks: IReadonlyList<TGamePack>;
    function GetWorlds: IReadonlyList<TWorld>;

  public
    constructor Create;
    destructor Destroy; override;

    property Lua: TLua read FLua;
    property LuaState: TLuaState read GetLuaState;

    property GamePacks: IReadonlyList<TGamePack> read GetGamePacks;
    procedure AddGamePack(AGamePack: TGamePack);

    property Worlds: IReadonlyList<TWorld> read GetWorlds;
    function AddWorld(AGenerator: TWorldGenerator): TWorld;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  // TODO: Move this
  /// <summary>A special kind of entity, that reacts to physics.</summary>
  TPhysicsEntity = class(TEntity, ISerializable)
  private
    FVelocity: TVector3;

    procedure SetVelocity(const Value: TVector3);

  public
    property Velocity: TVector3 read FVelocity write SetVelocity;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer); override;

  end;

  /// <summary>A player entity, usually controlled by an actual player.</summary>
  TPlayer = class(TPhysicsEntity, ISerializable)
  private
    FName: string;

  public
    property Name: string read FName;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer); override;

  end;

implementation

uses
  Unbound.Game.WorldFeatures;

{ TBlockPosition }

function TBlockPosition.GetWorld: TWorld;
begin
  Result := FWorld;
end;

function TBlockPosition.GetPosition: TIntVector3;
begin
  Result := FPosition;
end;

procedure TBlockPosition.SetPosition(const Value: TIntVector3);
begin
  FPosition := Value;
end;

function TBlockPosition.GetChunk: TChunk;
begin
  raise ENotImplemented.Create('TBlockPosition.GetChunk');
end;

constructor TBlockPosition.Create(AWorld: TWorld);
begin
  FWorld := AWorld;
end;

constructor TBlockPosition.Create(AWorld: TWorld; const APosition: TIntVector3);
begin
  FWorld := AWorld;
  FPosition := APosition;
end;

procedure TBlockPosition.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define('Position', FPosition);
end;

{ TWorldFeature }

function TWorldFeature.Copy: TWorldFeature;
begin
  Result := CreateSame;
  Result.Assign(Self);
end;

constructor TWorldFeature.Create;
begin
  // nothing
end;

class function TWorldFeature.CreateSame: TWorldFeature;
begin
  Result := Create;
end;

class function TWorldFeature.CreateTyped(AUBSMap: TUBSMap): TWorldFeature;
var
  FeatureType: string;
  FeatureClass: TWorldFeatureClass;
begin
  FeatureType := AUBSMap['FeatureType'].Cast<TUBSString>.Value;
  for FeatureClass in WorldFeatureClasses do
    if FeatureClass.GetName = FeatureType then
      Exit(FeatureClass.Create);
  raise EUnboundError.CreateFmt('Invalid World-Feature type: %s', [FeatureType]);
end;

procedure TWorldFeature.Serialize(ASerializer: TSerializer);
begin
  ASerializer.WriteOnly('FeatureType', GetName);
end;

{ TWorldGenerator }

function TWorldGenerator.CreateFeature(AUBSMap: TUBSMap): TWorldFeature;
begin
  Result := TWorldFeature.CreateTyped(AUBSMap);
end;

function TWorldGenerator.GetFeatures: IReadonlyList<TWorldFeature>;
begin
  Result := FFeatures.ReadonlyList;
end;

constructor TWorldGenerator.Create;
begin
  FFeatures := TObjectList<TWorldFeature>.Create;
end;

function TWorldGenerator.Copy: TWorldGenerator;
var
  Feature: TWorldFeature;
begin
  Result := TWorldGenerator.Create;
  for Feature in Features do
    Result.FFeatures.Add(Feature.Copy);
end;

procedure TWorldGenerator.GenerateChunk(AChunk: TChunk);
var
  Feature: TWorldFeature;
begin
  for Feature in Features do
    Feature.Apply(AChunk);
end;

procedure TWorldGenerator.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define<TWorldFeature>('Features', FFeatures, CreateFeature);
end;

{ TTerrainMaterial }

function TTerrainMaterial.Copy: TTerrainMaterial;
begin
  Result := TTerrainMaterial.Create;
  Result.FColor := Color;
end;

procedure TTerrainMaterial.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define('Color', FColor);
end;

{ TTerrain }

function TTerrain.PosToIndex(const APos: TIntVector3): Integer;
begin
  Result := (APos.X * Size.Y + APos.Y) * Size.Z + APos.Z;
end;

function TTerrain.GetMaterials: IReadonlyList<TTerrainMaterial>;
begin
  Result := FMaterials.ReadonlyList;
end;

function TTerrain.GetMaterialIDAt(const APos: TIntVector3): Integer;
begin
  Result := FData[PosToIndex(APos)];
end;

procedure TTerrain.SetMaterialIDAt(const APos: TIntVector3; const Value: Integer);
var
  Index: Integer;
begin
  Index := PosToIndex(APos);
  if FData[Index] = Value then
    Exit;
  FData[Index] := Value;
  Change;
end;

function TTerrain.GetMaterialAt(const APos: TIntVector3): TTerrainMaterial;
begin
  Result := FMaterials[MaterialIDAt[APos]];
end;

procedure TTerrain.SetMaterialAt(const APos: TIntVector3; const Value: TTerrainMaterial);
begin
  MaterialIDAt[APos] := GetMaterialID(Value);
end;

function TTerrain.GetOnChange: TEvent<TTerrain>.TAccess;
begin
  Result := FOnChange.Access;
end;

procedure TTerrain.Change;
begin
  FOnChange.Execute(Self);
end;

constructor TTerrain.Create(const ASize: TIntVector3);
begin
  Assert(ASize.Volume <= MaxVolume, Format('Terrain volume must be at most %d.', [MaxVolume]));
  FSize := ASize;
end;

function TTerrain.GetMaterialID(AMaterial: TTerrainMaterial): Integer;
begin
  Result := FMaterials.IndexOf(AMaterial);
  if Result = -1 then
  begin
    FMaterials.Add(AMaterial);
    Result := FMaterials.MaxIndex;
  end;
end;

procedure TTerrain.RemoveUnusedMaterials;
var
  UsedIDs: ISet<Word>;
  I, J: Integer;
begin
  UsedIDs := TSet<Word>.Create(FData);
  for I := FMaterials.MaxIndex downto 0 do
  begin
    if not UsedIDs.Contains(FData[I]) then
    begin
      FMaterials.RemoveAt(I);
      for J := 0 to Length(FData) do
        if FData[J] > I then
          Dec(FData[J]);
    end;
  end;
end;

procedure TTerrain.Serialize(ASerializer: TSerializer);
begin

end;

{ TDesign }

procedure TDesign.Serialize(ASerializer: TSerializer);
begin

end;

{ TChunk }

function TChunk.GetWorldPos: TIntVector3;
begin
  Result := FChunkPos * Size;
end;

function TChunk.GetSize: TIntVector3;
begin
  Result := World.ChunkSize;
end;

function TChunk.GetEntities: IReadonlyList<TEntity>;
begin
  Result := FEntities.ReadonlyList;
end;

constructor TChunk.Create(AWorld: TWorld; const AChunkPos, ASize: TIntVector3);
begin
  FWorld := AWorld;
  FChunkPos := AChunkPos;
  FTerrain := TTerrain.Create(Size);
end;

destructor TChunk.Destroy;
begin
  FTerrain.Free;
  FDesign.Free;
  inherited;
end;

procedure TChunk.Serialize(ASerializer: TSerializer);
begin
  // TODO
end;

{ TWorldLocation }

function TWorldLocation.GetWorld: TWorld;
begin
  Result := FWorld;
end;

function TWorldLocation.GetLocation: TLocation3;
begin
  Result := FLocation;
end;

procedure TWorldLocation.SetLocation(const Value: TLocation3);
begin
  FLocation.Assign(Value);
end;

function TWorldLocation.GetChunk: TChunk;
begin
  raise ENotImplemented.Create('Calculate Chunk from location.');
end;

constructor TWorldLocation.Create(AWorld: TWorld);
begin
  FWorld := AWorld;
  FLocation := TLocation3.Create;
end;

destructor TWorldLocation.Destroy;
begin
  FLocation.Free;
  inherited;
end;

function TWorldLocation.Copy: IWorldLocation;
begin
  Result := TWorldLocation.Create(World);
  Result.Location.Assign(Location);
end;

constructor TWorldLocation.Create(AWorld: TWorld; ALocation: TLocation3);
begin
  Create(AWorld);
  FLocation.Assign(ALocation);
end;

procedure TWorldLocation.Assign(const AFrom: IWorldLocation);
begin
  FWorld := AFrom.World;
  Location.Assign(AFrom.Location);
end;

procedure TWorldLocation.Serialize(ASerializer: TSerializer);
begin
  // TODO
end;

{ TWorld }

function TWorld.GetChunks: IReadonlyMap<TIntVector3, TChunk>;
begin
  Result := FChunks.ReadonlyMap;
end;

constructor TWorld.Create(AGame: TGame);
begin
  FGame := AGame;
  FChunks := TToObjectMap<TIntVector3, TChunk>.Create;
  FChunkSize := DefaultChunkSize;
end;

constructor TWorld.Create(AGame: TGame; AGenerator: TWorldGenerator);
begin
  Create(AGame);
  FGenerator := AGenerator;
end;

procedure TWorld.Serialize(ASerializer: TSerializer);
begin
  // TODO: Reference stuff, see other comment, use Generator reference from GamePack
  // ASerializer.Define('Generator', FGenerator, CreateGenerator);
end;

{ TEntity }

procedure TEntity.SetLocation(const Value: IWorldLocation);
begin
  FLocation.Assign(Value);
end;

constructor TEntity.Create(const ALocation: IWorldLocation);
begin
  FGUID := TGUID.NewGuid;
  FLocation := ALocation.Copy;
end;

procedure TEntity.Serialize(ASerializer: TSerializer);
begin
  // TODO
end;

{ TPhysicsEntity }

procedure TPhysicsEntity.SetVelocity(const Value: TVector3);
begin
  FVelocity := Value;
end;

procedure TPhysicsEntity.Serialize(ASerializer: TSerializer);
begin
  inherited;
  // TODO
end;

{ TPlayer }

procedure TPlayer.Serialize(ASerializer: TSerializer);
begin
  inherited;
  ASerializer.Define('Name', FName);
end;

{ TGamePack }

function TGamePack.GetDependencyGUIDs: IReadonlyList<TGUID>;
begin
  Result := FDependencyGUIDs.ReadonlyList;
end;

function TGamePack.GetWorldGenerators: IReadonlyList<TWorldGenerator>;
begin
  Result := FWorldGenerators.ReadonlyList;
end;

function TGamePack.GetMaterials: IReadonlyList<TTerrainMaterial>;
begin
  Result := FMaterials.ReadonlyList;
end;

constructor TGamePack.Create;
begin
  FDependencyGUIDs := TList<TGUID>.Create;
  FMaterials := TObjectList<TTerrainMaterial>.Create;
  FWorldGenerators := TObjectList<TWorldGenerator>.Create;
end;

function TGamePack.Copy: TGamePack;
var
  Material: TTerrainMaterial;
  WorldGenerator: TWorldGenerator;
begin
  Result := TGamePack.Create;
  Result.FName := Name;
  Result.FGUID := GUID;
  Result.FDependencyGUIDs.AddRange(DependencyGUIDs);
  for Material in Materials do
    Result.FMaterials.Add(Material.Copy);
  for WorldGenerator in WorldGenerators do
    Result.FWorldGenerators.Add(WorldGenerator.Copy);
end;

procedure TGamePack.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define('Name', FName);
  ASerializer.Define('GUID', FGUID);
  ASerializer.Define('DependencyGUIDs', FDependencyGUIDs);
  ASerializer.Define<TTerrainMaterial>('Materials', FMaterials);
  ASerializer.Define<TWorldGenerator>('WorldGenerators', FWorldGenerators);
end;

{ TGamePackEditable }

procedure TGamePackEditable.SetName(AName: string);
begin
  FName := AName;
end;

procedure TGamePackEditable.GenerateNewGUID;
begin
  FGUID := TGUID.NewGuid;
end;

procedure TGamePackEditable.AddDependency(AGamePack: TGamePack);
begin
  FDependencyGUIDs.Add(AGamePack.GUID);
end;

procedure TGamePackEditable.RemoveDependency(AGamepack: TGamePack);
begin
  FDependencyGUIDs.Remove(AGamePack.GUID);
end;

procedure TGamePackEditable.AddMaterial(AMaterial: TTerrainMaterial);
begin
  FMaterials.Add(AMaterial.Copy);
end;

procedure TGamePackEditable.RemoveMaterial(AMaterial: TTerrainMaterial);
begin
  FMaterials.Remove(AMaterial);
end;

procedure TGamePackEditable.AddWorldGenerator(AGenerator: TWorldGenerator);
begin
  FWorldGenerators.Add(AGenerator.Copy);  
end;

procedure TGamePackEditable.RemoveWorldGenerator(AGenerator: TWorldGenerator);
begin
  FWorldGenerators.Remove(AGenerator);
end;

{ TGame }

function TGame.CreateWorld: TWorld;
begin
  Result := TWorld.Create(Self);
end;

function TGame.GetLuaState: TLuaState;
begin
  Result := FLua.L;
end;

function TGame.GetGamePacks: IReadonlyList<TGamePack>;
begin
  Result := FGamePacks.ReadonlyList;
end;

function TGame.GetWorlds: IReadonlyList<TWorld>;
begin
  Result := FWorlds.ReadonlyList;
end;

constructor TGame.Create;
begin
  FLua := TLua.Create;
  FGamePacks := TObjectList<TGamePack>.Create;
  FWorlds := TObjectList<TWorld>.Create;
end;

destructor TGame.Destroy;
begin
  FLua.Free;
  inherited;
end;

procedure TGame.AddGamePack(AGamePack: TGamePack);
var
  Generator: TWorldGenerator;
begin
  AGamePack := AGamePack.Copy;
  FGamePacks.Add(AGamePack);
  for Generator in AGamePack.WorldGenerators do
    AddWorld(Generator);
end;

function TGame.AddWorld(AGenerator: TWorldGenerator): TWorld;
begin
  Result := TWorld.Create(Self, AGenerator);
  FWorlds.Add(Result);
end;

procedure TGame.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define<TGamePack>('GamePacks', FGamePacks);
  ASerializer.Define<TWorld>('Worlds', FWorlds, CreateWorld);
end;

{ TTerrainMaterialEditable }

procedure TTerrainMaterialEditable.SetColor(AColor: TColorRGBA);
begin
  FColor := AColor;
end;

{ TWorldGeneratorEditable }

procedure TWorldGeneratorEditable.AddFeature(AFeature: TWorldFeature);
begin
  FFeatures.Add(AFeature.Copy);
end;

procedure TWorldGeneratorEditable.RemoveFeature(AFeature: TWorldFeature);
begin
  FFeatures.Remove(AFeature);
end;

end.
