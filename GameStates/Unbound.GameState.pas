unit Unbound.GameState;

interface

uses
  System.SysUtils,

  Pengine.IntMaths,
  Pengine.GLGame,
  Pengine.ICollections;

type

  EGameState = class(Exception);

  TGameStateClass = class of TGameState;

  TGameStateManager = class;

  TGameState = class
  private
    FManager: TGameStateManager;
    FLoaded: Boolean;

    function GetManager: TGameStateManager;
    function GetGLGame: TGLGame;
    function GetLoaded: Boolean;
    procedure SetLoaded(const Value: Boolean);

  protected
    procedure DoLoad; virtual;
    procedure DoUnload; virtual;

  public
    constructor Create(const AManager: TGameStateManager);
    destructor Destroy; override;

    property Manager: TGameStateManager read GetManager;
    property GLGame: TGLGame read GetGLGame;

    property Loaded: Boolean read GetLoaded write SetLoaded;

    procedure Load;
    procedure Unload;

    procedure Update; virtual;
    procedure Render; virtual;

  end;

  TGameStateManager = class
  private
    FGLGame: TGLGame;
    FStates: IObjectList<TGameState>;

    function GetState(AStateClass: TGameStateClass): TGameState;

    procedure Update;
    procedure Render;

  public
    constructor Create(AGLGame: TGLGame);

    property GLGame: TGLGame read FGLGame;

    procedure AddState(AStateClass: TGameStateClass);
    property States[AStateClass: TGameStateClass]: TGameState read GetState; default;

    procedure Add<T: TGameState>; inline;
    function Get<T: TGameState>: T; inline;

  end;

implementation

{ TGameState }

function TGameState.GetManager: TGameStateManager;
begin
  Result := FManager;
end;

destructor TGameState.Destroy;
begin
  Unload;
  inherited;
end;

procedure TGameState.DoLoad;
begin
  // nothing
end;

procedure TGameState.DoUnload;
begin
  // nothing
end;

function TGameState.GetGLGame: TGLGame;
begin
  Result := Manager.GLGame;
end;

function TGameState.GetLoaded: Boolean;
begin
  Result := FLoaded;
end;

procedure TGameState.SetLoaded(const Value: Boolean);
begin
  if Value then
    Load
  else
    Unload;
end;

constructor TGameState.Create(const AManager: TGameStateManager);
begin
  FManager := AManager;
end;

procedure TGameState.Load;
begin
  if not Loaded then
  begin
    FLoaded := True;
    DoLoad;
  end;
end;

procedure TGameState.Unload;
begin
  if Loaded then
  begin
    FLoaded := False;
    DoUnload;
  end;
end;

procedure TGameState.Update;
begin
  // nothing
end;

procedure TGameState.Render;
begin
  // nothing
end;

{ TGameStateManager }

function TGameStateManager.Get<T>: T;
begin
  Result := T(States[T]);
end;

function TGameStateManager.GetState(AStateClass: TGameStateClass): TGameState;
var
  State: TGameState;
begin
  for State in FStates do
    if State is AStateClass then
      Exit(State);
  raise EGameState.Create('Game-State not registered.');
end;

procedure TGameStateManager.Update;
var
  State: TGameState;
begin
  for State in FStates do
    if State.Loaded then
      State.Update;
end;

procedure TGameStateManager.Render;
var
  State: TGameState;
begin
  for State in FStates do
    if State.Loaded then
      State.Render;
end;

procedure TGameStateManager.Add<T>;
begin
  AddState(T);
end;

procedure TGameStateManager.AddState(AStateClass: TGameStateClass);
begin
  FStates.Add(AStateClass.Create(Self));
end;

constructor TGameStateManager.Create(AGLGame: TGLGame);
begin
  FGLGame := AGLGame;
  FStates := TObjectList<TGameState>.Create;
  GLGame.OnUpdate.Add(Update);
  GLGame.OnRender.Add(Render);
end;

end.
