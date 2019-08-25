unit UBSExplorer.RegistrySettings;

interface

uses
  System.Win.Registry,

  Winapi.Windows,

  Vcl.Themes,
  Vcl.Styles;

type

  TSettings = class
  public const

    RegistryPath = 'Software\UBS-Explorer';

  private
    FChanged: Boolean;
    FTheme: string;

    procedure Load;
    procedure Save;

    procedure Change;

    procedure SetTheme(const Value: string);

  public
    constructor Create;
    destructor Destroy; override;

    procedure InitDefaults;

    property Changed: Boolean read FChanged;
    property Theme: string read FTheme write SetTheme;

  end;

var
  Settings: TSettings;

implementation

{ TSettings }

procedure TSettings.Change;
begin
  FChanged := True;
end;

constructor TSettings.Create;
begin
  InitDefaults;
  Load;
end;

destructor TSettings.Destroy;
begin
  if Changed then
    Save;
  inherited;
end;

procedure TSettings.InitDefaults;
begin
  Theme := 'Carbon';
end;

procedure TSettings.Load;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if not Reg.OpenKey(RegistryPath, False) then
      Exit;

    Theme := Reg.ReadString('Theme');

  finally
    Reg.Free;
  end;
end;

procedure TSettings.Save;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if not Reg.Openkey(RegistryPath, True) then
      Exit;

    Reg.WriteString('Theme', Theme);

  finally
    Reg.Free;
  end;
end;

procedure TSettings.SetTheme(const Value: string);
begin
  if Theme = Value then
    Exit;
  FTheme := Value;
  TStyleManager.TrySetStyle(Theme);
  Change;
end;

initialization

Settings := TSettings.Create;

finalization

Settings.Free;

end.
