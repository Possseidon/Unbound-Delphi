unit Unbound.Game;

interface

uses
  System.SysUtils,

  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.ICollections,

  Unbound.Game.Serialization;

type

  // --- Interfaces ---

  IGame = interface;
  IWorld = interface;
  IChunk = interface;

  /// <summary>A block aligned position in a world.</summary>
  IBlockPosition = interface(ISerializable)
    function GetWorld: IWorld;
    function GetPosition: TIntVector3;
    procedure SetPosition(const Value: TIntVector3);
    function GetChunk: IChunk;

    property World: IWorld read GetWorld;
    property Position: TIntVector3 read GetPosition write SetPosition;
    property Chunk: IChunk read GetChunk;

  end;

  /// <summary>A location (position and rotation) in a world.</summary>
  IWorldLocation = interface(ISerializable)
    function GetWorld: IWorld;
    function GetLocation: TLocation3;
    procedure SetLocation(const Value: TLocation3);
    function GetChunk: IChunk;

    function Copy: IWorldLocation;
    procedure Assign(const AFrom: IWorldLocation);

    property World: IWorld read GetWorld;
    property Location: TLocation3 read GetLocation write SetLocation;
    property Chunk: IChunk read GetChunk;

  end;

  /// <summary>A material, which chunk terrain is made up of.</summary>
  ITerrainMaterial = interface(ISerializable)

  end;

  /// <summary>The terrain which a chunk is made up of.</summary>
  ITerrain = interface(ISerializable)
    function GetMaterials: IReadonlyList<ITerrainMaterial>;
    function GetSize: TIntVector3;
    function GetMaterialIDAt(APos: TIntVector3): Integer;
    procedure SetMaterialIDAt(APos: TIntVector3; const Value: Integer);
    function GetMaterialAt(APos: TIntVector3): ITerrainMaterial;
    procedure SetMaterialAt(APos: TIntVector3; const Value: ITerrainMaterial);

    property Materials: IReadonlyList<ITerrainMaterial> read GetMaterials;
    function GetMaterialID(AMaterial: ITerrainMaterial): Integer;
    procedure RemoveUnusedMaterials;

    property Size: TIntVector3 read GetSize;
    property MaterialIDAt[APos: TIntVector3]: Integer read GetMaterialIDAt write SetMaterialIDAt;
    property MaterialAt[APos: TIntVector3]: ITerrainMaterial read GetMaterialAt write SetMaterialAt; default;

  end;

  /// <summary>Block aligned models, which can take up multiple block spaces per model.</summary>
  IDesign = interface(ISerializable)

  end;

  /// <summary>An entity, which can be placed and moved freely in the world.</summary>
  IEntity = interface(ISerializable)
    function GetGUID: TGUID;
    function GetLocation: IWorldLocation;
    procedure SetLocation(const Value: IWorldLocation);

    property GUID: TGUID read GetGUID;
    property Location: IWorldLocation read GetLocation write SetLocation;

  end;

  /// <summary>A cuboid chunk of a world, made up of terrain, design and entities.</summary>
  IChunk = interface(ISerializable)
    function GetWorld: IWorld;
    function GetChunkPos: TIntVector3;
    function GetWorldPos: TIntVector3;
    function GetSize: TIntVector3;
    function GetTerrain: ITerrain;
    function GetDesign: IDesign;
    function GetEntities: IReadonlyList<IEntity>;

    property World: IWorld read GetWorld;
    property ChunkPos: TIntVector3 read GetChunkPos;
    property WorldPos: TIntVector3 read GetWorldPos;
    property Size: TIntVector3 read GetSize;

    property Terrain: ITerrain read GetTerrain;
    property Design: IDesign read GetDesign;
    property Entities: IReadonlyList<IEntity> read GetEntities;

  end;

  IWorldGenerator = interface;

  /// <summary>A feature, that generates a chunk via the "Apply" method.</summary>
  IWorldFeature = interface(ISerializable)
    function GetGenerator: IWorldGenerator;

    property Generator: IWorldGenerator read GetGenerator;

    procedure Apply(const AChunk: IChunk);

  end;

  /// <summary>A list of world features, which get applied in order, making up a world generator.</summary>
  IWorldGenerator = interface(ISerializable)
    function GetFeatures: IReadonlyList<IWorldFeature>;

    procedure GenerateChunk(const AChunk: IChunk);

    property Features: IReadonlyList<IWorldFeature> read GetFeatures;

  end;

  /// <summary>A close to infinite world, consisting of cuboid chunks.</summary>
  IWorld = interface(ISerializable)
    function GetGame: IGame;
    function GetGenerator: IWorldGenerator;
    function GetChunks: IReadonlyMap<TIntVector3, IChunk>;
    function GetChunkSize: TIntVector3;

    property Game: IGame read GetGame;
    property Generator: IWorldGenerator read GetGenerator;
    property Chunks: IReadonlyMap<TIntVector3, IChunk> read GetChunks;
    property ChunkSize: TIntVector3 read GetChunkSize;

  end;

  // TODO: Split GamePack up, when necessary
  /// <summary>Contains game resources and behaviors.</summary>
  IGamePack = interface(ISerializable)
    function GetGUID: TGUID;
    function GetMaterials: IReadonlyList<ITerrainMaterial>;

    property GUID: TGUID read GetGUID;
    property Materials: IReadonlyList<ITerrainMaterial> read GetMaterials;

  end;

  /// <summary>A game, consisting of multiple worlds and global game settings.</summary>
  IGame = interface(ISerializable)
    function GetGamePacks: IReadonlyList<IGamePack>;
    function GetWorlds: IReadonlyList<IWorld>;

    property GamePacks: IReadonlyList<IGamePack> read GetGamePacks;

    property Worlds: IReadonlyList<IWorld> read GetWorlds;
    function AddWorld(AGenerator: IWorldGenerator): IWorld;

  end;

  // TODO: Move this
  /// <summary>A special kind of entity, that reacts to physics.</summary>
  IPhysicsEntity = interface(IEntity)
    function GetVelocity: TVector3;
    procedure SetVelocity(const Value: TVector3);

    property Velocity: TVector3 read GetVelocity write SetVelocity;

  end;

  /// <summary>A player entity, usually controlled by an actual player.</summary>
  IPlayer = interface(IPhysicsEntity)
    function GetName: string;

    property Name: string read GetName;

  end;

  // --- Implementations ---

  TWorldFeatureClass = class of TWorldFeature;

  TWorldFeature = class(TInterfacedObject, IWorldFeature, ISerializable)
  private
    [Weak]
    FGenerator: IWorldGenerator;

    function GetGenerator: IWorldGenerator;

  public
    constructor Create(const AGenerator: IWorldGenerator);
    class function CreateTyped(const AGenerator: IWorldGenerator; AUBSMap: TUBSMap): IWorldFeature;
    class function GetName: string; virtual; abstract;

    property Generator: IWorldGenerator read GetGenerator;

    procedure Serialize(ASerializer: TSerializer);

    procedure Apply(const AChunk: IChunk); virtual; abstract;

  end;

  TWorldGenerator = class(TInterfacedObject, IWorldGenerator, ISerializable)
  private
    FFeatures: IList<IWorldFeature>;

    function CreateFeature(AUBSMap: TUBSMap): IWorldFeature;

    function GetFeatures: IReadonlyList<IWorldFeature>;

  public
    constructor Create;

    procedure GenerateChunk(const AChunk: IChunk);

    property Features: IReadonlyList<IWorldFeature> read GetFeatures;

    procedure Serialize(ASerializer: TSerializer);

  end;

  TWorld = class;

  TTerrainMaterial = class(TInterfacedObject, ITerrainMaterial, ISerializable)
  public
    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TTerrain = class(TInterfacedObject, ITerrain, ISerializable)
  public const

    MaxVolume = $10000;

  private
    FSize: TIntVector3;
    FMaterials: IList<ITerrainMaterial>;
    FData: array of Word;

    function PosToIndex(const APos: TIntVector3): Integer; inline;

    // ITerrain
    function GetMaterials: IReadonlyList<ITerrainMaterial>;
    function GetSize: TIntVector3;
    function GetMaterialIDAt(APos: TIntVector3): Integer;
    procedure SetMaterialIDAt(APos: TIntVector3; const Value: Integer);
    function GetMaterialAt(APos: TIntVector3): ITerrainMaterial;
    procedure SetMaterialAt(APos: TIntVector3; const Value: ITerrainMaterial);

  public
    constructor Create(const ASize: TIntVector3);

    // ITerrain
    property Materials: IReadonlyList<ITerrainMaterial> read GetMaterials;
    function GetMaterialID(AMaterial: ITerrainMaterial): Integer;
    procedure RemoveUnusedMaterials;

    property Size: TIntVector3 read GetSize;
    property MaterialIDAt[APos: TIntVector3]: Integer read GetMaterialIDAt write SetMaterialIDAt;
    property MaterialAt[APos: TIntVector3]: ITerrainMaterial read GetMaterialAt write SetMaterialAt; default;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TChunk = class(TInterfacedObject, IChunk, ISerializable)
  private
    [Weak]
    FWorld: IWorld;
    FChunkPos: TIntVector3;
    FTerrain: ITerrain;
    FDesign: IDesign;
    FEntities: IList<IEntity>;

    // IChunk
    function GetSize: TIntVector3;
    function GetWorld: IWorld;
    function GetTerrain: ITerrain;
    function GetChunkPos: TIntVector3;
    function GetWorldPos: TIntVector3;
    function GetDesign: IDesign;
    function GetEntities: IReadonlyList<IEntity>;

  public
    constructor Create(const AWorld: IWorld; const AChunkPos, ASize: TIntVector3);

    // IChunk
    property World: IWorld read GetWorld;
    property ChunkPos: TIntVector3 read GetChunkPos;
    property WorldPos: TIntVector3 read GetWorldPos;
    property Size: TIntVector3 read GetSize;

    property Terrain: ITerrain read GetTerrain;
    property Design: IDesign read GetDesign;
    property Entities: IReadonlyList<IEntity> read GetEntities;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TWorldLocation = class(TInterfacedObject, IWorldLocation, ISerializable)
  private
    [Weak]
    FWorld: IWorld;
    FLocation: TLocation3;

    // IWorldLocation
    function GetWorld: IWorld;
    function GetLocation: TLocation3;
    procedure SetLocation(const Value: TLocation3);
    function GetChunk: IChunk;

  public
    constructor Create(const AWorld: IWorld);
    destructor Destroy; override;

    // IWorldLocation
    function Copy: IWorldLocation;
    procedure Assign(const AFrom: IWorldLocation);

    property World: IWorld read GetWorld;
    property Location: TLocation3 read GetLocation write SetLocation;
    property Chunk: IChunk read GetChunk;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TGame = class;

  TWorld = class(TInterfacedObject, IWorld, ISerializable)
  public const

    DefaultChunkSize: TIntVector3 = (X: 32; Y: 32; Z: 32);

  private
    [Weak]
    FGame: IGame;
    FGenerator: IWorldGenerator;
    FChunks: IMap<TIntVector3, IChunk>;
    FChunkSize: TIntVector3;

    function CreateGenerator: IWorldGenerator;

    // IWorld
    function GetChunks: IReadonlyMap<TIntVector3, IChunk>;
    function GetGame: IGame;
    function GetGenerator: IWorldGenerator;
    function GetChunkSize: TIntVector3;

  public
    constructor Create(const AGame: TGame); overload;
    constructor Create(const AGame: TGame; const AGenerator: IWorldGenerator); overload;

    // IWorld
    property Game: IGame read GetGame;
    property Generator: IWorldGenerator read GetGenerator;
    property Chunks: IReadonlyMap<TIntVector3, IChunk> read GetChunks;
    property ChunkSize: TIntVector3 read GetChunkSize;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TEntity = class(TInterfacedObject, IEntity, ISerializable)
  private
    FGUID: TGUID;
    FLocation: IWorldLocation;

    // IEntity
    function GetGUID: TGUID;
    function GetLocation: IWorldLocation;
    procedure SetLocation(const Value: IWorldLocation);

  public
    constructor Create(const ALocation: IWorldLocation);

    // IEntity
    property GUID: TGUID read GetGUID;
    property Location: IWorldLocation read GetLocation write SetLocation;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer); virtual;

  end;

  TPhysicsEntity = class(TEntity, IPhysicsEntity, IEntity, ISerializable)
  private
    FVelocity: TVector3;

    // IPhysicsEntity
    function GetVelocity: TVector3;
    procedure SetVelocity(const Value: TVector3);

  public
    // IPhysicsEntity
    property Velocity: TVector3 read GetVelocity write SetVelocity;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer); override;

  end;

  TPlayer = class(TPhysicsEntity, IPlayer, IPhysicsEntity, IEntity, ISerializable)
  private
    FName: string;

    // IPlayer
    function GetName: string;

  public
    // IPlayer
    property Name: string read GetName;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer); override;

  end;

  TGamePack = class(TInterfacedObject, IGamePack, ISerializable)
  private
    FGUID: TGUID;
    FMaterials: IList<ITerrainMaterial>;

    // IGamePack
    function GetGUID: TGUID; virtual; abstract;
    function GetMaterials: IReadonlyList<ITerrainMaterial>;

  public
    constructor Create; overload;
    constructor Create(AGUID: TGUID); overload;

    // IGamePack
    property GUID: TGUID read GetGUID;
    property Materials: IReadonlyList<ITerrainMaterial> read GetMaterials;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

  TGame = class(TInterfacedObject, IGame, ISerializable)
  private
    FGamePacks: IList<IGamePack>;
    FWorlds: IList<IWorld>;

    function CreateWorld: IWorld;

    // IGame
    function GetGamePacks: IReadonlyList<IGamePack>;
    function GetWorlds: IReadonlyList<IWorld>;

  public
    constructor Create;

    // IGame
    property GamePacks: IReadonlyList<IGamePack> read GetGamePacks;

    property Worlds: IReadonlyList<IWorld> read GetWorlds;
    function AddWorld(AGenerator: IWorldGenerator): IWorld;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

implementation

uses
  Unbound.Game.WorldFeatures;

{ TWorldFeature }

function TWorldFeature.GetGenerator: IWorldGenerator;
begin
  Result := FGenerator;
end;

constructor TWorldFeature.Create(const AGenerator: IWorldGenerator);
begin
  FGenerator := AGenerator;
end;

class function TWorldFeature.CreateTyped(const AGenerator: IWorldGenerator; AUBSMap: TUBSMap): IWorldFeature;
var
  FeatureType: string;
  FeatureClass: TWorldFeatureClass;
begin
  FeatureType := AUBSMap['FeatureType'].Cast<TUBSString>.Value;
  for FeatureClass in WorldFeatureClasses do
    if FeatureClass.GetName = FeatureType then
      Exit(FeatureClass.Create(AGenerator));
end;

procedure TWorldFeature.Serialize(ASerializer: TSerializer);
begin
  ASerializer.WriteOnly('FeatureType', GetName);
end;

{ TWorldGenerator }

function TWorldGenerator.CreateFeature(AUBSMap: TUBSMap): IWorldFeature;
begin
  Result := TWorldFeature.CreateTyped(Self, AUBSMap);
end;

function TWorldGenerator.GetFeatures: IReadonlyList<IWorldFeature>;
begin
  Result := FFeatures.ReadonlyList;
end;

constructor TWorldGenerator.Create;
begin
  FFeatures := TList<IWorldFeature>.Create;
end;

procedure TWorldGenerator.GenerateChunk(const AChunk: IChunk);
var
  Feature: IWorldFeature;
begin
  for Feature in Features do
    Feature.Apply(AChunk);
end;

procedure TWorldGenerator.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define<IWorldFeature>('Features', FFeatures, CreateFeature);
end;

{ TTerrainMaterial }

procedure TTerrainMaterial.Serialize(ASerializer: TSerializer);
begin

end;

{ TTerrain }

function TTerrain.PosToIndex(const APos: TIntVector3): Integer;
begin
  Result := APos.X + Size.X * (APos.Y + Size.Y * APos.Z);
end;

function TTerrain.GetMaterials: IReadonlyList<ITerrainMaterial>;
begin
  Result := FMaterials.ReadonlyList;
end;

function TTerrain.GetSize: TIntVector3;
begin
  Result := FSize;
end;

function TTerrain.GetMaterialIDAt(APos: TIntVector3): Integer;
begin
  Result := FData[PosToIndex(APos)];
end;

procedure TTerrain.SetMaterialIDAt(APos: TIntVector3; const Value: Integer);
begin
  FData[PosToIndex(APos)] := Value;
end;

function TTerrain.GetMaterialAt(APos: TIntVector3): ITerrainMaterial;
begin
  Result := FMaterials[MaterialIDAt[APos]];
end;

procedure TTerrain.SetMaterialAt(APos: TIntVector3; const Value: ITerrainMaterial);
begin
  MaterialIDAt[APos] := GetMaterialID(Value);
end;

constructor TTerrain.Create(const ASize: TIntVector3);
begin
  Assert(ASize.Volume <= MaxVolume, Format('Terrain volume must be at most %d.', [MaxVolume]));
  FSize := ASize;
end;

function TTerrain.GetMaterialID(AMaterial: ITerrainMaterial): Integer;
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

{ TChunk }

function TChunk.GetSize: TIntVector3;
begin
  Result := World.ChunkSize;
end;

function TChunk.GetWorld: IWorld;
begin
  Result := FWorld;
end;

function TChunk.GetTerrain: ITerrain;
begin
  Result := FTerrain;
end;

function TChunk.GetChunkPos: TIntVector3;
begin
  Result := FChunkPos;
end;

function TChunk.GetWorldPos: TIntVector3;
begin
  Result := FChunkPos * Size;
end;

function TChunk.GetDesign: IDesign;
begin
  Result := FDesign;
end;

function TChunk.GetEntities: IReadonlyList<IEntity>;
begin
  Result := FEntities.ReadonlyList;
end;

constructor TChunk.Create(const AWorld: IWorld; const AChunkPos, ASize: TIntVector3);
begin
  FWorld := AWorld;
  FChunkPos := AChunkPos;
  FTerrain := TTerrain.Create(Size);
end;

procedure TChunk.Serialize(ASerializer: TSerializer);
begin
  // TODO
end;

{ TWorldLocation }

function TWorldLocation.GetWorld: IWorld;
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

function TWorldLocation.GetChunk: IChunk;
begin
  raise ENotImplemented.Create('Calculate Chunk from location.');
end;

constructor TWorldLocation.Create(const AWorld: IWorld);
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

function TWorld.CreateGenerator: IWorldGenerator;
begin
  Result := TWorldGenerator.Create;
end;

function TWorld.GetChunks: IReadonlyMap<TIntVector3, IChunk>;
begin
  Result := FChunks.ReadonlyMap;
end;

function TWorld.GetChunkSize: TIntVector3;
begin
  Result := FChunkSize;
end;

function TWorld.GetGame: IGame;
begin
  Result := FGame;
end;

function TWorld.GetGenerator: IWorldGenerator;
begin
  Result := FGenerator;
end;

constructor TWorld.Create(const AGame: TGame);
begin
  FGame := AGame;
  FChunks := TMap<TIntVector3, IChunk>.Create;
  FChunkSize := DefaultChunkSize;
end;

constructor TWorld.Create(const AGame: TGame; const AGenerator: IWorldGenerator);
begin
  Create(AGame);
  FGenerator := AGenerator;
end;

procedure TWorld.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define<IWorldGenerator>('Generator', FGenerator, CreateGenerator);
end;

{ TEntity }

function TEntity.GetGUID: TGUID;
begin
  Result := FGUID;
end;

function TEntity.GetLocation: IWorldLocation;
begin
  Result := FLocation;
end;

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

function TPhysicsEntity.GetVelocity: TVector3;
begin
  Result := FVelocity;
end;

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

function TPlayer.GetName: string;
begin
  Result := FName;
end;

procedure TPlayer.Serialize(ASerializer: TSerializer);
begin
  inherited;
  ASerializer.Define('Name', FName);
end;

{ TGamePack }

function TGamePack.GetMaterials: IReadonlyList<ITerrainMaterial>;
begin
  Result := FMaterials.ReadonlyList;
end;

constructor TGamePack.Create;
begin
  Create(TGUID.NewGuid);
end;

constructor TGamePack.Create(AGUID: TGUID);
begin
  FGUID := AGUID;
  FMaterials := TList<ITerrainMaterial>.Create;
end;

procedure TGamePack.Serialize(ASerializer: TSerializer);
begin
  // ASerializer.Define('GUID', FGUID);
end;

{ TGame }

function TGame.CreateWorld: IWorld;
begin
  Result := TWorld.Create(Self);
end;

function TGame.GetGamePacks: IReadonlyList<IGamePack>;
begin
  Result := FGamePacks.ReadonlyList;
end;

function TGame.GetWorlds: IReadonlyList<IWorld>;
begin
  Result := FWorlds.ReadonlyList;
end;

constructor TGame.Create;
begin
  FWorlds := TList<IWorld>.Create;
end;

function TGame.AddWorld(AGenerator: IWorldGenerator): IWorld;
begin
  Result := TWorld.Create(Self, AGenerator);
  FWorlds.Add(Result);
end;

procedure TGame.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define<IWorld>('Worlds', FWorlds, CreateWorld);
end;

end.
