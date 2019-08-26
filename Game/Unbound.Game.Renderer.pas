unit Unbound.Game.Renderer;

interface

uses
  Pengine.Camera,
  Pengine.VAO,
  Pengine.GLState,
  Pengine.ResourceManager,
  Pengine.GLProgram,
  Pengine.ICollections,
  Pengine.GLEnums,
  Pengine.MarchingCubes,
  Pengine.Vector,
  Pengine.IntMaths,
  Pengine.Color,
  Pengine.EventHandling,
  
  Unbound.Shaders,
  Unbound.Game;

type

  TChunkRenderable = class(TRenderable)
  private
    FChunk: IChunk;
    FTerrainShader: IResource<TGLProgram>;
    FTerrainChanged: Boolean;
    FTerrainVAO: TVAOMutable<TTerrainShader.TData>;
    FTerrainChangeSubscription: IEventSubscription;

    procedure TerrainChanged;
    procedure BuildTerrainVAO;

  public
    constructor Create(AGLState: TGLState; const AChunk: IChunk);

    property Chunk: IChunk read FChunk;

    procedure Render; override;

  end;

  TGameRenderer = class
  private
    FGame: IGame;
    FCamera: TCamera;

  public
    constructor Create(const AGame: IGame);
    destructor Destroy; override;

    property Camera: TCamera read FCamera;

  end;

implementation

{ TChunkRenderable }

procedure TChunkRenderable.BuildTerrainVAO;

  function Mix(F: Single; A, B: TColorRGB): TColorRGB;
  begin
    Result := A + F * (B - A);
  end;

  function ColorAt(const ATerrain: ITerrain; APos: TIntVector3; AOffset: TVector3): TColorRGB;
  begin
    Result := 
      Mix(AOffset.Z, 
      Mix(AOffset.Y, 
      Mix(AOffset.X, ATerrain[APos { +         0 } ].Color, ATerrain[APos + IVec3(1, 0, 0)].Color), 
      Mix(AOffset.X, ATerrain[APos + IVec3(0, 1, 0)].Color, ATerrain[APos + IVec3(1, 1, 0)].Color)), 
      Mix(AOffset.Y, 
      Mix(AOffset.X, ATerrain[APos + IVec3(0, 0, 1)].Color, ATerrain[APos + IVec3(1, 0, 1)].Color), 
      Mix(AOffset.X, ATerrain[APos + IVec3(0, 1, 1)].Color, ATerrain[APos + IVec3(1, 1, 1)].Color)));
  end;

var
  Data: TTerrainShader.TData;
  VBOData: IList<TTerrainShader.TData>;
  Terrain: ITerrain;
  P: TIntVector3;
  Plane: TPlane3;
  TexCoord: TVector2;
  Corners: TCorners3;
  Corner: TCorner3;
begin
  Terrain := Chunk.Terrain;
  for P in Terrain.Size - 1 do
  begin
    Corners := [];
    for Corner := Low(TCorner3) to High(TCorner3) do
      if Terrain[P + Corner3Pos[Corner]] <> nil then
        Include(Corners, Corner);

    for Plane in TMarchingCubes.GetTriangles(Corners) do
    begin
      for TexCoord in TriangleTexCoords do
      begin
        Data.Pos := Plane[TexCoord];
        Data.Color := ColorAt(Terrain, P, Data.Pos);
        VBOData.Add(Data);
      end;
    end;
  end;
  FTerrainVAO.VBO.Generate(VBOData.Count, buDynamicDraw, VBOData.DataPointer);
  FTerrainChanged := False;
end;

constructor TChunkRenderable.Create(AGLState: TGLState; const AChunk: IChunk);
begin
  FChunk := AChunk;
  FTerrainShader := TTerrainShader.Get(AGLState);
  FTerrainVAO := TVAOMutable<TTerrainShader.TData>.Create(FTerrainShader.Data);
  FTerrainChangeSubscription := AChunk.Terrain.OnChange.Subscribe(TerrainChanged);
end;

procedure TChunkRenderable.Render;
begin
  if FTerrainChanged then
    BuildTerrainVAO;
  FTerrainVAO.Render;
end;

procedure TChunkRenderable.TerrainChanged;
begin
  FTerrainChanged := True;
end;

{ TGameRenderer }

constructor TGameRenderer.Create(const AGame: IGame);
begin
  FGame := AGame;
  FCamera := TCamera.Create(75, 1, 0.01, 1000);
end;

destructor TGameRenderer.Destroy;
begin
  FCamera.Free;
  inherited;
end;

end.
