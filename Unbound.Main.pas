unit Unbound.Main;

interface

uses
  Pengine.GLForm,
  Pengine.JSON,

  Unbound.GameState;

type

  TfrmMain = class(TGLForm)
  private
    FGameState: TGameState;

  public
    procedure Init; override;
    procedure Finalize; override;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

{ TfrmMain }

procedure TfrmMain.Init;
begin
  FGameState := TGameState.Create;
end;

procedure TfrmMain.Finalize;
begin
  FGameState.Free;
end;

end.
