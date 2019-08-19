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

  IWorld = interface;

  IChunk = interface(ISerializable)
    function GetWorld: IWorld;
    function GetOffset: TIntVector3;
    function GetSize: TIntVector3;

    property World: IWorld read GetWorld;
    property Offset: TIntVector3 read GetOffset;
    property Size: TIntVector3 read GetSize;

  end;

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

  IWorldGenerator = interface;

  IWorldFeature = interface(ISerializable)
    function GetGenerator: IWorldGenerator;

    property Generator: IWorldGenerator read GetGenerator;

    procedure Apply(const AChunk: IChunk);

  end;

  IWorldGenerator = interface(ISerializable)
    function GetFeatures: IReadonlyList<IWorldFeature>;

    procedure GenerateChunk(const AChunk: IChunk);

    property Features: IReadonlyList<IWorldFeature> read GetFeatures;

  end;

  IGame = interface;

  IWorld = interface(ISerializable)
    function GetGame: IGame;
    function GetGenerator: IWorldGenerator;
    function GetChunks: IReadonlyMap<TIntVector3, IChunk>;

    property Game: IGame read GetGame;
    property Generator: IWorldGenerator read GetGenerator;
    property Chunks: IReadonlyMap<TIntVector3, IChunk> read GetChunks;

  end;

  IGame = interface(ISerializable)
    function GetWorlds: IReadonlyList<IWorld>;

    property Worlds: IReadonlyList<IWorld> read GetWorlds;
    function AddWorld(AGenerator: IWorldGenerator): IWorld;

  end;

  IEntity = interface(ISerializable)
    function GetGUID: TGUID;
    function GetLocation: IWorldLocation;
    procedure SetLocation(const Value: IWorldLocation);

    property GUID: TGUID read GetGUID;
    property Location: IWorldLocation read GetLocation write SetLocation;

  end;

  IPhysicsEntity = interface(IEntity)
    function GetVelocity: TVector3;
    procedure SetVelocity(const Value: TVector3);

    property Velocity: TVector3 read GetVelocity write SetVelocity;

  end;

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
    constructor Create(AGenerator: IWorldGenerator);
    class function CreateTyped(AGenerator: IWorldGenerator; AUBSMap: TUBSMap): IWorldFeature;
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

  TGame = class;
  TWorld = class;

  TChunk = class(TInterfacedObject, IChunk, ISerializable)
  private
    [Weak]
    FWorld: IWorld;
    FOffset: TIntVector3;
    FSize: TIntVector3;

    // IChunk
    function GetOffset: TIntVector3;
    function GetSize: TIntVector3;
    function GetWorld: IWorld;

  public
    constructor Create(const AWorld: IWorld; const AOffset: TIntVector3);

    // IChunk
    property World: IWorld read GetWorld;
    property Offset: TIntVector3 read GetOffset;
    property Size: TIntVector3 read GetSize;

    // property Blocks
    // property Entities

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

  TWorld = class(TInterfacedObject, IWorld, ISerializable)
  private
    [Weak]
    FGame: IGame;
    FGenerator: IWorldGenerator;
    FChunks: IMap<TIntVector3, IChunk>;

    function CreateGenerator: IWorldGenerator;

    // IWorld
    function GetChunks: IReadonlyMap<TIntVector3, IChunk>;
    function GetGame: IGame;
    function GetGenerator: IWorldGenerator;

  public
    constructor Create(const AGame: TGame); overload;
    constructor Create(const AGame: TGame; const AGenerator: IWorldGenerator); overload;

    // IWorld
    property Game: IGame read GetGame;
    property Generator: IWorldGenerator read GetGenerator;
    property Chunks: IReadonlyMap<TIntVector3, IChunk> read GetChunks;

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
    // TODO: Collision info
    // TODO: Render Info

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

  TGame = class(TInterfacedObject, IGame, ISerializable)
  private
    // TODO: Version
    FWorlds: IList<IWorld>;

    function CreateWorld: IWorld;

    // IGame
    function GetWorlds: IReadonlyList<IWorld>;

  public
    constructor Create;

    // IGame
    property Worlds: IReadonlyList<IWorld> read GetWorlds;
    function AddWorld(AGenerator: IWorldGenerator): IWorld;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

implementation

uses
  Unbound.WorldFeatures;

{ TChunk }

function TChunk.GetOffset: TIntVector3;
begin
  Result := FOffset;
end;

function TChunk.GetSize: TIntVector3;
begin
  Result := FSize;
end;

function TChunk.GetWorld: IWorld;
begin
  Result := FWorld;
end;

constructor TChunk.Create(const AWorld: IWorld; const AOffset: TIntVector3);
begin
  FWorld := AWorld;
  FOffset := AOffset;
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

constructor TWorld.Create(const AGame: TGame; const AGenerator: IWorldGenerator);
begin
  Create(AGame);
  FGenerator := AGenerator;
end;

function TWorld.CreateGenerator: IWorldGenerator;
begin
  Result := TWorldGenerator.Create;
end;

function TWorld.GetChunks: IReadonlyMap<TIntVector3, IChunk>;
begin
  Result := FChunks.ReadonlyMap;
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

{ TGame }

function TGame.CreateWorld: IWorld;
begin
  Result := TWorld.Create(Self);
end;

function TGame.GetWorlds: IReadonlyList<IWorld>;
begin
  Result := FWorlds.ReadonlyList;
end;

function TGame.AddWorld(AGenerator: IWorldGenerator): IWorld;
begin
  Result := TWorld.Create(Self, AGenerator);
  FWorlds.Add(Result);
end;

constructor TGame.Create;
begin
  FWorlds := TList<IWorld>.Create;
end;

procedure TGame.Serialize(ASerializer: TSerializer);
begin
  ASerializer.Define<IWorld>('Worlds', FWorlds, CreateWorld);
end;

{ TWorldFeature }

constructor TWorldFeature.Create(AGenerator: IWorldGenerator);
begin
  FGenerator := AGenerator;
end;

class function TWorldFeature.CreateTyped(AGenerator: IWorldGenerator; AUBSMap: TUBSMap): IWorldFeature;
var
  FeatureType: string;
  FeatureClass: TWorldFeatureClass;
begin
  FeatureType := AUBSMap['FeatureType'].Cast<TUBSString>.Value;
  for FeatureClass in WorldFeatureClasses do
    if FeatureClass.GetName = FeatureType then
      Exit(FeatureClass.Create(AGenerator));
end;

function TWorldFeature.GetGenerator: IWorldGenerator;
begin
  Result := FGenerator;
end;

procedure TWorldFeature.Serialize(ASerializer: TSerializer);
begin
  ASerializer.WriteOnly('FeatureType', GetName);
end;

{ TWorldGenerator }

function TWorldGenerator.GetFeatures: IReadonlyList<IWorldFeature>;
begin
  Result := FFeatures.ReadonlyList;
end;

constructor TWorldGenerator.Create;
begin
  FFeatures := TList<IWorldFeature>.Create;
end;

function TWorldGenerator.CreateFeature(AUBSMap: TUBSMap): IWorldFeature;
begin
  Result := TWorldFeature.CreateTyped(Self, AUBSMap);
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

end.
