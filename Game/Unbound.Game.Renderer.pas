unit Unbound.Game.Renderer;

interface

uses
  Pengine.Camera,

  Unbound.Game;

type

  TChunkRenderable = class(TRenderable)
  private
    FChunk: IChunk;
    // FTerrainVAO: TVAO;

  public
    constructor Create(const AChunk: IChunk);

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

constructor TChunkRenderable.Create(const AChunk: IChunk);
begin
  FChunk := AChunk;
end;

procedure TChunkRenderable.Render;
begin

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
