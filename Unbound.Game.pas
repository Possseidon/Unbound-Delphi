unit Unbound.Game;

interface

uses
  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.ICollections,

  Unbound.Game.Serialization;

type

  // Interfaces

  IWorld = interface;

  IChunk = interface
    function GetWorld: IWorld;
    function GetOffset: TIntVector3;
    function GetSize: TIntVector3;

    property World: IWorld read GetWorld;
    property Offset: TIntVector3 read GetOffset;
    property Size: TIntVector3 read GetSize;

    function Serializable: ISerializable;

  end;

  IWorldLocation = interface

    function Serializable: ISerializable;

  end;

  IWorld = interface

    function Serializable: ISerializable;

  end;

  IWorldGenerator = interface
    procedure GenerateChunk(AChunk: IChunk);

    function Serializable: ISerializable;

  end;

  // Implementations

  TGame = class;
  TWorld = class;

  TChunk = class(TInterfacedObject, IChunk)
  private
    FWorld: TWorld;
    FOffset: TIntVector3;
    FSize: TIntVector3;

  public
    constructor Create(AWorld: TWorld; AOffset: TIntVector3);

    property World: TWorld read FWorld;
    property Offset: TIntVector3 read FOffset;
    property Size: TIntVector3 read FSize;

    // property Blocks
    // property Entities

  end;

  TWorldLocation = class(TInterfacedObject, IWorldLocation)
  private
    FWorld: TWorld;
    FLocation: TLocation3;

  public
    property World: TWorld read FWorld;
    property Location: TLocation3 read FLocation;

    property Chunk: TChunk read GetChunk;

  end;

  TWorld = class(TInterfacedObject, IWorld)
  private
    FGame: TGame;
    FChunks: IMap<TIntVector3, TChunk>;

  public
    constructor Create(AGame: TGame; AGenerator: IWorldGenerator);

  end;

  TEntity = class(TInterfacedObject, IEntity)
  private
    FGUID: TGUID;
    FLocation: TWorldLocation;

  public
    constructor Create;
    destructor Destroy; override;

    property GUID: TGUID read FGUID;
    property Location: TWorldLocation read FLocation;

  end;

  TPhysicsEntity = class(TEntity, IPhysicsEntity, IEntity)
  private
    FVelocity: TVector3;
    // TODO: Collision info
    // TODO: Render Info

  public
    property Velocity: TVector3 read FVelocity write SetVelocity;

  end;

  TPlayer = class(TPhysicsEntity, IPlayer, IPhysicsEntity, IEntity)
  private
    FName: string;

  public

  end;

  TGame = class(TInterfacedObject, IGame)
  private
    // TODO: Version
    FWorlds: IList<TWorld>;

  public
    constructor Create;

  end;

implementation

end.
