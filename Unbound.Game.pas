unit Unbound.Game;

interface

uses
  System.SysUtils,

  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.ICollections,

  Unbound.Game.Serialization;

type

  // Interfaces

  IWorld = interface;
  IGame = interface;

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

  IWorldGenerator = interface(ISerializable)
    function Copy: IWorldGenerator;

    procedure GenerateChunk(const AChunk: IChunk);

  end;

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
    function AddWorld: IWorld;

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

  // Implementations

  TGame = class;
  TWorld = class;

  TChunk = class(TInterfacedObject, IChunk, ISerializable)
  private
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
    FGame: IGame;
    FGenerator: IWorldGenerator;
    FChunks: IMap<TIntVector3, IChunk>;

    // IWorld
    function GetChunks: IReadonlyMap<TIntVector3, IChunk>;
    function GetGame: IGame;
    function GetGenerator: IWorldGenerator;

  public
    constructor Create(const AGame: TGame);

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
    function AddWorld: IWorld;

    // ISerializable
    procedure Serialize(ASerializer: TSerializer);

  end;

implementation

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

end;

{ TWorld }

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
end;

procedure TWorld.Serialize(ASerializer: TSerializer);
begin

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

end;

{ TPhysicsEntity }

function TPhysicsEntity.GetVelocity: TVector3;
begin
  Result := FVelocity;
end;

procedure TPhysicsEntity.SetVelocity(const Value: TVector3);
begin
  if Velocity = Value then
    Exit;
  FVelocity := Value;
end;

procedure TPhysicsEntity.Serialize(ASerializer: TSerializer);
begin
  inherited;

end;

{ TPlayer }

function TPlayer.GetName: string;
begin
  Result := FName;
end;

procedure TPlayer.Serialize(ASerializer: TSerializer);
begin
  inherited;
  // Define('Name', FName);
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

function TGame.AddWorld: IWorld;
begin
  Result := CreateWorld;
  FWorlds.Add(Result);
end;

constructor TGame.Create;
begin
  FWorlds := TList<IWorld>.Create;
end;

procedure TGame.Serialize(ASerializer: TSerializer);
begin
  ASerializer.DefineList<IWorld>('Worlds', FWorlds, CreateWorld);
end;

end.
