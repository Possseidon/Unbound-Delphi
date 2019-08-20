unit Unbound.Main;

interface

uses
  Pengine.GLForm,

  Unbound.GameState;

type

  TfrmMain = class(TGLForm)
  private
    FManager: TGameStateManager;

  public
    procedure Init; override;
    procedure Finalize; override;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  Unbound.GameState.Loading,
  Unbound.GameState.MainMenu,
  Unbound.GameState.Playing;

{ TfrmMain }

procedure TfrmMain.Init;
begin
  FManager := TGameStateManager.Create(Game);
  FManager.Add<TGameStateLoading>;
  FManager.Add<TGameStateMainMenu>;
  FManager.Add<TGameStatePlaying>;
  FManager[TGameStatePlaying].Load;
end;

procedure TfrmMain.Finalize;
begin
  FManager.Free;
end;

end.
