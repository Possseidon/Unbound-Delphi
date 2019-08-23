unit UBSExplorer.Tab;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  System.UITypes,
  System.Types,

  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Controls,
  Vcl.ComCtrls,

  Pengine.EventHandling,
  Pengine.ICollections,

  Unbound.Game.Serialization,

  UBSExplorer.DataModule;

type

  TUBSTreeNode = class(TTreeNode)
  private
    FUBSValue: TUBSValue;

  public
    property UBSValue: TUBSValue read FUBSValue write FUBSValue;

  end;

  TfrmTab = class(TFrame)
    tvExplorer: TTreeView;
    procedure tvExplorerCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
  private
    FFilename: string;
    FFileTimestamp: TDateTime;
    FUBSValue: TUBSValue;
    FModified: Boolean;
    FOnFilenameChange: TEvent<TfrmTab>;

    procedure AddUBSValueToTreeView(AParent: TUBSTreeNode; AUBSValue: TUBSValue);
    function GetOnFilenameChange: TEvent<TfrmTab>.TAccess;

  public
    constructor Create(AOwner: TComponent; AUBSTag: TUBSTag); reintroduce; overload;
    constructor Create(AOwner: TComponent; AFilename: string); reintroduce; overload;
    destructor Destroy; override;

    property Filename: string read FFilename;
    property UBSValue: TUBSValue read FUBSValue;
    property Modified: Boolean read FModified;

    procedure UpdateTreeView;

    function Save: Boolean;
    function SaveAs: Boolean;

    function FileChanged: Boolean;
    procedure CheckFileChanged;

    function TryClose: Boolean;

    property OnFilenameChange: TEvent<TfrmTab>.TAccess read GetOnFilenameChange;

  end;

implementation

{$R *.dfm}

{ TfrmTab }

procedure TfrmTab.AddUBSValueToTreeView(AParent: TUBSTreeNode; AUBSValue: TUBSValue);
var
  Pair: TPair<string, TUBSValue>;
  Node: TUBSTreeNode;
  I: Integer;
  Value: TUBSValue;
begin
  case AUBSValue.GetTag of
    ubsMap:
      begin
        for Pair in TUBSMap(AUBSValue).Order do
        begin
          case Pair.Value.GetTag of
            ubsMap, ubsList:
              begin
                Node := tvExplorer.Items.AddChild(AParent, Format('%s: %s', [Pair.Key, Pair.Value.GetTagName]))
                  as TUBSTreeNode;
                Node.UBSValue := Pair.Value;
                AddUBSValueToTreeView(Node, Pair.Value);
              end
          else
            tvExplorer.Items.AddChildObject(AParent, Format('%s: %s', [Pair.Key, Pair.Value.ToString]), Pair.Value);
          end;
        end;
      end;
    ubsList:
      begin
        for I := 0 to TUBSList(AUBSValue).Items.MaxIndex do
        begin
          Value := TUBSList(AUBSValue).Items[I];
          case Value.GetTag of
            ubsMap, ubsList:
              begin
                Node := tvExplorer.Items.AddChildObject(AParent, Format('[%d] %s', [I, Value.GetTagName]), Value)
                  as TUBSTreeNode;
                Node.UBSValue := Value;
                AddUBSValueToTreeView(Node, Value);
              end
          else
            tvExplorer.Items.AddChildObject(AParent, Format('[%d] %s', [I, Value.ToString]), Value);
          end;
        end;
      end
  else
    tvExplorer.Items.AddChildObject(AParent, AUBSValue.ToString, AUBSValue);
  end;
end;

constructor TfrmTab.Create(AOwner: TComponent; AUBSTag: TUBSTag);
begin
  inherited Create(AOwner);
  FUBSValue := UBSClasses[AUBSTag].Create;
  UpdateTreeView;
end;

constructor TfrmTab.Create(AOwner: TComponent; AFilename: string);
begin
  inherited Create(AOwner);
  if not TFile.Exists(AFilename) then
    raise Exception.Create('File not found.');
  FFilename := AFilename;
  FFileTimestamp := TFile.GetLastWriteTime(AFilename);
  FUBSValue := TUBSValue.LoadFromFile(AFilename);
  UpdateTreeView;
end;

destructor TfrmTab.Destroy;
begin
  FUBSValue.Free;
  inherited;
end;

procedure TfrmTab.UpdateTreeView;
begin
  tvExplorer.Items.BeginUpdate;
  try
    tvExplorer.Items.Clear;
    AddUBSValueToTreeView(nil, UBSValue);
  finally
    tvExplorer.Items.EndUpdate;
  end;
end;

function TfrmTab.Save: Boolean;
begin
  if Filename.IsEmpty then
    if not SaveAs then
      Exit(False);
  Result := True;
  UBSValue.SaveToFile(Filename);
  FFileTimestamp := TFile.GetLastWriteTime(Filename);
  FModified := False;
end;

function TfrmTab.SaveAs: Boolean;
begin
  Result := dmData.dlgSave.Execute;
  if not Result then
    Exit;
  FFilename := dmData.dlgSave.FileName;
  FOnFilenameChange.Execute(Self);
  Result := Save;
end;

function TfrmTab.FileChanged: Boolean;
begin
  Result := not Filename.IsEmpty and (TFile.GetLastWriteTime(Filename) <> FFileTimestamp);
end;

function TfrmTab.GetOnFilenameChange: TEvent<TfrmTab>.TAccess;
begin
  Result := FOnFilenameChange.Access;
end;

procedure TfrmTab.CheckFileChanged;
begin
  if FileChanged and
    (MessageDlg('File contents changed. Do you want to reload?', mtConfirmation, mbYesNo, 0) = mrYes) then
  begin
    FUBSValue.Free;
    FUBSValue := TUBSValue.LoadFromFile(Filename);
  end;
end;

function TfrmTab.TryClose: Boolean;
begin
  Result := True;
  if Modified then
  begin
    case MessageDlg('Do you want to save your changes?', mtInformation, mbYesNoCancel, 0) of
      mrYes:
        Result := Save;
      mrCancel:
        Result := False;
    end;
  end;
  if Result then
    Parent.Free;
end;

procedure TfrmTab.tvExplorerCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := TUBSTreeNode;
end;

end.
